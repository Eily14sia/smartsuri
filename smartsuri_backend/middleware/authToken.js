const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const { sequelize, LogMaster, User } = require('../models/database');
const getLogger = require('../utils/logger');

dotenv.config();
const secretKey = process.env.JWT_SECRET_KEY;
const emailHost = process.env.EMAIL_HOST;
const emailPort = process.env.EMAIL_PORT;
const emailUser = process.env.EMAIL_USER;
const emailPass = process.env.EMAIL_PASS;
const emailFrom = process.env.EMAIL_FROM;

const logger = getLogger(__filename);

// In-memory storage for verification codes
const verificationCodes = new Map(); 
const temporaryUsers = new Map(); 

class AuthService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      host: emailHost,
      port: emailPort,
      auth: {
        user: emailUser,
        pass: emailPass,
      },
    });
  }

  authenticateToken(req, res, next) {
    const token = req.header('Authorization')?.split(' ')[1];
    if (!token) {
      logger.error('Access denied. No token provided.');
      return res.status(401).json({
        resultKey: false,
        errorMessage: 'Access denied. No token provided.',
        errorCode: 401,
      });
    }
  
    jwt.verify(token, secretKey, (err, user) => {
      if (err) {
        if (err.name === 'TokenExpiredError') {
          const { refreshToken } = req.body;
  
          if (!refreshToken) {
            return res.status(401).json({ 
              resultKey: false, 
              errorMessage: 'Refresh token required.', 
              errorCode: 401 
            });
          }
  
          jwt.verify(refreshToken, secretKey, (refreshErr, refreshPayload) => {
            if (refreshErr) {
              logger.error('Invalid refresh token.', { error: refreshErr.message });
              return res.status(403).json({
                resultKey: false,
                errorMessage: 'Invalid refresh token.',
                errorCode: 403,
              });
            }
            const newTokens = this.generateToken(refreshPayload);

            return res.status(200).json({
              resultKey: true,
              accessToken: newTokens.accessToken,
              refreshToken: newTokens.refreshToken,
            });
          });
        } else {
          logger.error('Invalid token.', { error: err.message });
          return res.status(403).json({
            resultKey: false,
            errorMessage: 'Invalid token.',
            errorCode: 403,
          });
        }
      } else {
        req.user = user;
        next();
      }
    });
  }
  
  generateToken(user) {
    const payload = {
      id: user.id,
      username: user.username,
      role_id: user.role_id,
    };

    const accessToken = jwt.sign(payload, secretKey, { expiresIn: '1h' });
    const refreshToken = jwt.sign(payload, secretKey, { expiresIn: '7d' });

    return { accessToken, refreshToken };
  }

  validateFields(data, requiredFields) {
    if (typeof data !== 'object' || data === null) {
      const errorMessage = 'Invalid data type';
      logger.error(errorMessage, { data });
      return {
        resultKey: false,
        errorMessage,
        errorCode: 400,
      };
    }

    for (const field of requiredFields) {
      if (!Object.prototype.hasOwnProperty.call(data, field) || data[field] === undefined || data[field] === null) {
        const errorMessage = `Missing required field: ${field}`;
        logger.error(errorMessage, { data });
        return {
          resultKey: false,
          errorMessage,
          errorCode: 400,
        };
      }
    }
    return null;
  }

  async createLogEntry(originalData, updatedData, tableName, user) {
    try {
      const changes = this.findChanges(originalData, updatedData);

      const transaction = await sequelize.transaction();
      await LogMaster.create(
        {
          tablename: tableName,
          requested_data: JSON.stringify(originalData),
          change_data: JSON.stringify(changes),
          isActive: true,
          created_by: user,
          updated_by: user,
          created_at: new Date(),
        },
        { transaction },
      );
      await transaction.commit();
    } catch (logError) {
      logger.error(`Error logging change: ${logError.message}`, { stack: logError.stack });
      throw logError;
    }
  }

  findChanges(original, updated) {
    const excludeFields = ['created_at', 'updated_at', 'created_by', 'deleted_at'];
    const changes = {};

    Object.keys(updated).forEach((key) => {
      if (!excludeFields.includes(key) && original[key] !== updated[key]) {
        changes[key] = updated[key];
      }
    });

    return changes;
  }

  async sendVerificationEmail(userEmail, verificationCode) {
    try {
      await this.transporter.sendMail({
        from: emailFrom,
        to: userEmail,
        subject: 'Email Verification Code',
        text: `Your verification code is: ${verificationCode}`,
      });
    } catch (error) {
      logger.error('Failed to send verification email', { error: error.message });
      throw new Error('Failed to send verification email');
    }
  }

  async generateAndSendVerificationCode(user) {
    const verificationCode = crypto.randomBytes(3).toString('hex').toUpperCase(); // Generate a 6-character code
    const expiry = new Date(Date.now() + 3600000); // 1 hour expiry

    // Store the code in the in-memory storage
    verificationCodes.set(user.email, { code: verificationCode, expiry });

    // Store user details temporarily
    temporaryUsers.set(user.email, user);

    await this.sendVerificationEmail(user.email, verificationCode);
  }

  async verifyCode(userEmail, code) {
    const entry = verificationCodes.get(userEmail);

    if (!entry || entry.code !== code || new Date() > entry.expiry) {
      throw new Error('Invalid or expired verification code');
    }

    // Remove the code from in-memory storage after successful verification
    verificationCodes.delete(userEmail);

    // Retrieve and remove the user from temporary storage
    const temporaryUser = temporaryUsers.get(userEmail);

    if (!temporaryUser) {
      throw new Error('No temporary user found');
    }

    temporaryUsers.delete(userEmail);

    // Return user data for the controller to handle database creation
    return temporaryUser;
  }

  async resendVerificationCode(email) {
    // Check if the email is in temporary users' storage
    if (!temporaryUsers.has(email)) {
      throw new Error('Email is not pending verification');
    }

    // Generate a new verification code
    const verificationCode = crypto.randomBytes(3).toString('hex').toUpperCase(); // 6-character code
    const expiry = new Date(Date.now() + 3600000); // 1 hour expiry

    // Update the existing verification code and expiry
    verificationCodes.set(email, { code: verificationCode, expiry });

    // Retrieve the user from temporary storage
    const user = temporaryUsers.get(email);

    // Send the new verification code via email
    await this.sendVerificationEmail(email, verificationCode);

    return verificationCode; // Optionally return the new code
  }

   async sendResetPasswordEmail(email, verificationCode) {
    const transporter = nodemailer.createTransport({
      service: 'gmail',  // Use your mail service provider
      auth: {
        user: process.env.EMAIL_USER,  // Your email
        pass: process.env.EMAIL_PASS,  // Your email password
      },
    });

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Email Password Reset Request Verification',
      text: `Your verification code is: ${verificationCode}`,
    };

    await transporter.sendMail(mailOptions);
  }
}

module.exports = new AuthService();
