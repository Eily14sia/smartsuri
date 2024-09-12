const { sequelize, User, LogMaster } = require('../models/database');  // Removed Role import
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const AuthService = require('../middleware/authToken');
const dotenv = require('dotenv');
const moment = require('moment');

dotenv.config();

const getLogger = require('../utils/logger');

const logger = getLogger(__filename);

class AuthController {
  static async login(req, res) {
    const { email, password } = req.body;
    const requiredFields = ['email', 'password'];

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields);
    if (validationError) {
      return res.status(400).json(validationError);
    }

    try {
      // Fetch user directly without including role
      const user = await User.findOne({ where: { email } });

      if (!user) {
        return res.status(401).json({ resultKey: false, errorMessage: 'Invalid email or password', errorCode: 401 });
      }

      if (!user.isActive) {
        return res.status(401).json({ resultKey: false, errorMessage: 'Account is inactive', errorCode: 401 });
      }

      const match = await bcrypt.compare(password, user.password);

      if (!match) {
        return res.status(401).json({ resultKey: false, errorMessage: 'Invalid email or password', errorCode: 401 });
      }

      // Generate and send verification code
      await AuthService.generateAndSendVerificationCode(user);

      return res.status(200).json({ resultKey: true, message: 'Verification code sent to your email', resultCode: 200 });
    } catch (error) {
      logger.error(`Error during login: ${error.message}`);
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 });
    }
  }

  static async verifyLoginCode(req, res) {
    const { email, code } = req.body;

    try {
      await AuthService.verifyCode(email, code);

      // Proceed with generating tokens or other login-related operations
      const user = await User.findOne({ where: { email } });
      const access_token = AuthService.generateToken(user);

      return res.json({
        resultKey: true,
        access_token: access_token,
        userinfo: {
          id: user.id,
          username: user.username,
          email: user.email,
          isActive: user.isActive,
          birthday: user.birthday,
          city: user.city,
          prof_img: user.prof_img,

        },
        resultCode: 200,
      });
    } catch (error) {
      logger.error(`Error verifying code: ${error.message}`);
      return res.status(400).json({ resultKey: false, errorMessage: error.message, errorCode: 400 });
    }
  }

  static async resendVerificationCode(req, res) {
    const { email } = req.body;

    // Validate required fields
    if (!email) {
      return res.status(400).json({
        resultKey: false,
        errorMessage: 'Email is required',
        errorCode: 400,
      });
    }

    try {
      // Call the AuthService method to resend the verification code
      await AuthService.resendVerificationCode(email);

      return res.status(200).json({
        resultKey: true,
        message: 'Verification code resent successfully',
        resultCode: 200,
      });
    } catch (error) {
      logger.error(`Error resending verification code: ${error.message}`);
      return res.status(400).json({
        resultKey: false,
        errorMessage: error.message,
        errorCode: 400,
      });
    }
  }

  static async forgotPassword(req, res) {
    const { email } = req.body;

    // Validate that email is provided
    if (!email) {
      return res.status(400).json({ resultKey: false, errorMessage: 'Email is required', errorCode: 400 });
    }

    try {
      // Find the user by email
      const user = await User.findOne({ where: { email } });
      
      if (!user) {
        return res.status(404).json({ resultKey: false, errorMessage: 'No account with that email found', errorCode: 404 });
      }

      // Generate a 6-digit verification code
      const verificationCode = Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit code
      
      // Create a JWT with the verification code and user ID, expires in 15 minutes
      const token = jwt.sign({ id: user.id, code: verificationCode }, process.env.JWT_SECRET_KEY, { expiresIn: '15m' });

      // Send the code via email (you can use nodemailer or any email service)
      await AuthService.sendResetPasswordEmail(user.email, verificationCode);

      return res.status(200).json({ resultKey: true, message: 'Verification code sent to your email', resultCode: 200, token });
    } catch (error) {
      logger.error(`Error during forgotPassword: ${error.message}`);
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 });
    }
  }

  static async verifyPasswordResetCode(req, res) {
    const { token, code } = req.body;

    try {
      // Verify the token and extract the data (user ID and the original code)
      const decoded = jwt.verify(token, process.env.JWT_SECRET_KEY);

      // Check if the provided code matches the one in the token
      if (decoded.code !== code) {
        return res.status(400).json({ resultKey: false, errorMessage: 'Invalid verification code', errorCode: 400 });
      }

      return res.status(200).json({ resultKey: true, message: 'Code verified successfully', resultCode: 200 });
    } catch (error) {
      logger.error(`Error verifying code: ${error.message}`);
      return res.status(400).json({ resultKey: false, errorMessage: 'Invalid or expired token', errorCode: 400 });
    }
  }

  // Function to reset password using the reset token
  static async resetPassword(req, res) {
    const { token, newPassword } = req.body;

    try {
      // Verify the token
      const decoded = jwt.verify(token, process.env.JWT_SECRET_KEY);

      // Find the user by the ID in the token
      const user = await User.findByPk(decoded.id);
      if (!user) {
        return res.status(400).json({ resultKey: false, errorMessage: 'Invalid token', errorCode: 400 });
      }

      // Hash the new password and save it
      const hashedPassword = await bcrypt.hash(newPassword, 10);
      user.password = hashedPassword;
      await user.save();

      return res.status(200).json({ resultKey: true, message: 'Password reset successful', resultCode: 200 });
    } catch (error) {
      logger.error(`Error resetting password: ${error.message}`);
      return res.status(400).json({ resultKey: false, errorMessage: 'Invalid or expired token', errorCode: 400 });
    }
  }

  static async resendPassCode(req, res) {
    const { token } = req.body;
  
    // Validate required fields
    if (!token) {
      return res.status(400).json({
        resultKey: false,
        errorMessage: 'Token is required',
        errorCode: 400,
      });
    }
  
    try {
      // Verify and decode the token
      const decodedToken = jwt.verify(token, process.env.JWT_SECRET_KEY);
      const userId = decodedToken.id;
  
      // Find the user by ID
      const user = await User.findOne({ where: { id: userId } });
      if (!user) {
        return res.status(404).json({
          resultKey: false,
          errorMessage: 'No account with that token found',
          errorCode: 404,
        });
      }
  
      // Generate a new verification code
      const verificationCode = Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit code
  
      // Create a new JWT with the new verification code and user ID, expires in 15 minutes
      const newToken = jwt.sign({ id: user.id, code: verificationCode }, process.env.JWT_SECRET_KEY, { expiresIn: '15m' });
  
      // Send the new code via email
      await AuthService.sendResetPasswordEmail(user.email, verificationCode);
  
      return res.status(200).json({
        resultKey: true,
        message: 'New verification code sent to your email',
        resultCode: 200,
        token: newToken // Return the new token
      });
    } catch (error) {
      logger.error(`Error resending verification code: ${error.message}`);
      return res.status(500).json({
        resultKey: false,
        errorMessage: 'Server error',
        errorCode: 500,
      });
    }
  }
}

module.exports = AuthController;
