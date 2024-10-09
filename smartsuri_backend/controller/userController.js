const { sequelize, User, LogMaster } = require('../models/database');
const { UniqueConstraintError, Op } = require('sequelize');
const bcrypt = require('bcrypt');
const dotenv = require('dotenv');
const AuthService = require('../middleware/authToken');
const getLogger = require('../utils/logger');

const nodemailer = require('nodemailer');
// In-memory storage for verification tokens
const verificationTokens = {};

// Configure nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail', 
  auth: {
    user: process.env.EMAIL_USER, 
    pass: process.env.EMAIL_PASS, 
    
  },
      tls: {
        rejectUnauthorized: false
      }
});

dotenv.config();
const logger = getLogger(__filename);

const saltRounds = 10;
// Define a Set to store temporary users
const temporaryUsers = new Set();

class UserController {
  static async createUser(req, res) {
    const { username, password, email, birthday, city, prof_img } = req.body;
    const requiredFields = ['username', 'password', 'email', 'birthday', 'city', 'prof_img'];
  
    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields);
    if (validationError) {
      return res.status(400).json(validationError);
    }
  
    try {
      // Check if the username or email already exists in the user table
      const existingUser = await User.findOne({
        where: {
          [Op.and]: [
            { username },
            { email }
          ]
        }
      });
  
      if (existingUser) {
        let errorMessage = 'User already registered';
        return res.status(400).json({
          resultKey: false,
          errorMessage,
          errorCode: 400
        });
      }
  
      // Check if the email is already in temporary storage
      const existingTempUser = temporaryUsers.has(email);
      if (existingTempUser) {
        return res.status(400).json({
          resultKey: false,
          errorMessage: 'Email already pending verification',
          errorCode: 400
        });
      }
  
      // Hash the password and store user in temporary storage
      const hashedPassword = await bcrypt.hash(password, saltRounds);
      const user = {
        username,
        email,
        password: hashedPassword,
        birthday,
        city,
        prof_img,
      };
  
      // Store user temporarily and generate verification code
      await AuthService.generateAndSendVerificationCode(user);
  
      return res.status(200).json({
        resultKey: true,
        message: 'Verification code sent to email.',
        resultCode: 200,
      });
    } catch (error) {
      logger.error(`Error creating user: ${error.message}`);
      return res.status(500).json({
        resultKey: false,
        errorMessage: 'Server error',
        errorCode: 500
      });
    }
  }
  
  static async verifyEmail(req, res) {
    const { email, code } = req.body;
  
    try {
      // Verify the code and get user data from in-memory storage
      const userData = await AuthService.verifyCode(email, code);
  
      // Create the user in the main table
      await User.create({
        username: userData.username,
        email: userData.email,
        password: userData.password,
        birthday: userData.birthday,
        city: userData.city,
        prof_img: userData.prof_img,
        isActive: true, // Set isActive to true upon verification
      });
  
      return res.status(200).json({
        resultKey: true,
        message: 'Email verified successfully',
        resultCode: 200,
      });
    } catch (error) {
      logger.error(`Error verifying email: ${error.message}`);
      return res.status(400).json({ resultKey: false, errorMessage: error.message, errorCode: 400 });
    }
  }

  static async updateUsername(req, res) {
    const userId = req.user.id;
    const {username} = req.body;

    let transaction;
    try {
      // Start transaction
      transaction = await sequelize.transaction();

      const user = await User.findByPk(userId, { transaction });
      if (!user) {
        return res.status(404).json({ resultKey: false, errorMessage: 'User not found', errorCode: 404 });
      }

      // Update the user using model update method
      await user.update(
        {
          username,
        },
        { transaction }
      );

      // Commit transaction
      await transaction.commit();

      // Fetch the updated user
      const updatedData = await User.findByPk(userId);

      return res.json({ resultKey: true, user: updatedData, resultCode: 200 });
    } catch (error) {
      // Rollback transaction if not committed
      if (transaction && transaction.finished !== 'commit') {
        await transaction.rollback();
      }

      logger.error(`Error updating user: ${error.message}`, { stack: error.stack });
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 });
    }
  }

  static async sendOTP(req, res) {
    const { email } = req.body;
    const requiredFields = ['email'];

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields);
    if (validationError) {
      return res.status(400).json(validationError);
    }

    try {
      // Generate a verification code
      const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();

      // Send email with verification code
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Your Verification Code',
        text: `Your verification code is: ${verificationCode}`,
      };

      await transporter.sendMail(mailOptions);

      // Store the verification code in the in-memory storage
      verificationTokens[email] = verificationCode;

      return res.status(200).json({ resultKey: true, message: 'Verification code sent to your email', resultCode: 200 });
    } catch (error) {
      logger.error(`Error during sending OTP: ${error.message}`);
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 });
    }
  }

  static async updateEmail(req, res) {
    const userId = req.user.id;
    const { email, code } = req.body;
    const requiredFields = ['email', 'code'];

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields);
    if (validationError) {
      return res.status(400).json(validationError);
    }

    // Check if the verification code matches
    if (verificationTokens[email] !== code) {
      return res.status(400).json({ resultKey: false, errorMessage: 'Invalid verification code', errorCode: 400 });
    }

    let transaction;
    try {
      // Start transaction
      transaction = await sequelize.transaction();

      const user = await User.findByPk(userId, { transaction });
      if (!user) {
        return res.status(404).json({ resultKey: false, errorMessage: 'User not found', errorCode: 404 });
      }

      // Update the user's email
      await user.update(
        {
          email,
        },
        { transaction }
      );

      // Commit transaction
      await transaction.commit();

      // Remove the verification code from in-memory storage
      delete verificationTokens[email];

      // Fetch the updated user
      const updatedData = await User.findByPk(userId);

      return res.json({ resultKey: true, user: updatedData, resultCode: 200 });
    } catch (error) {
      // Rollback transaction if not committed
      if (transaction && transaction.finished !== 'commit') {
        await transaction.rollback();
      }

      logger.error(`Error during updating email: ${error.message}`);
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 });
    }
  }

  static async updateProfileInfo(req, res) {
    const userId = req.user.id;
    const {birthday, city, prof_img} = req.body;

    let transaction;
    try {
      // Start transaction
      transaction = await sequelize.transaction();

      const user = await User.findByPk(userId, { transaction });
      if (!user) {
        return res.status(404).json({ resultKey: false, errorMessage: 'User not found', errorCode: 404 });
      }

      // Update the user using model update method
      await user.update(
        {
          birthday,
          city,
          prof_img
        },
        { transaction }
      );

      // Commit transaction
      await transaction.commit();

      // Fetch the updated user
      const updatedData = await User.findByPk(userId);

      return res.json({ resultKey: true, user: updatedData, resultCode: 200 });
    } catch (error) {
      // Rollback transaction if not committed
      if (transaction && transaction.finished !== 'commit') {
        await transaction.rollback();
      }

      logger.error(`Error updating user: ${error.message}`, { stack: error.stack });
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 });
    }

  }

  static async updatePassword(req, res) {
    const userId = req.user.id; 

    const { oldPassword, newPassword } = req.body;

    const requiredFields = ['oldPassword', 'newPassword'];

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields);
    if (validationError) {
      return res.status(400).json(validationError);
    }

    let transaction;
    try {
      // Start transaction
      transaction = await sequelize.transaction();

      const user = await User.findByPk(userId, { transaction });
      if (!user) {
        return res.status(404).json({ resultKey: false, errorMessage: 'User not found', errorCode: 404 });
      }

      // Check if the old password matches the current password in the database
      const isMatch = await bcrypt.compare(oldPassword, user.password);
      if (!isMatch) {
        return res.status(400).json({ resultKey: false, errorMessage: 'Old password is incorrect', errorCode: 400 });
      }

      // Hash the new password
      const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

      // Update the user using model update method
      await user.update(
        {
          password: hashedPassword,
        },
        { transaction }
      );

      // Commit transaction
      await transaction.commit();

      // Fetch the updated user
      const updatedData = await User.findByPk(userId);

      return res.json({ resultKey: true, user: updatedData, resultCode: 200 });
    } catch (error) {
      // Rollback transaction if not committed
      if (transaction && transaction.finished !== 'commit') {
        await transaction.rollback();
      }

      logger.error(`Error updating user: ${error.message}`, { stack: error.stack });
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 });
    }
  }
}

module.exports = UserController;
