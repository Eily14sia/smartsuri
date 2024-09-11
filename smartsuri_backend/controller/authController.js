const { sequelize, User, Role, LogMaster } = require('../models/database')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcrypt')
const AuthService = require('../middleware/authToken')
const dotenv = require('dotenv')
const moment = require('moment');

dotenv.config()

const useStoredProcedure = process.env.USE_STORED_PROCEDURE
const getLogger = require('../utils/logger')

const logger = getLogger(__filename)
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
      // Fetch user and related role details
      const user = await User.findOne({
        where: { email },
        include: { model: Role, as: 'role' }, // Include Role model based on role_id
      });

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

  static async verifyCode(req, res) {
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
          role_id: user.role_id,
          isActive: user.isActive,
          issuperadmin: user.issuperadmin,
          iscompany: user.iscompany,
          usertypeid: user.usertypeid,
        },
        role: user.role,
        resultCode: 200,
      });
    } catch (error) {
      logger.error(`Error verifying code: ${error.message}`);
      return res.status(400).json({ resultKey: false, errorMessage: error.message, errorCode: 400 });
    }
  }
}

module.exports = AuthController;
