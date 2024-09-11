const { sequelize, User, LogMaster } = require('../models/database');
const { UniqueConstraintError, Op } = require('sequelize');
const bcrypt = require('bcrypt');
const dotenv = require('dotenv');
const AuthService = require('../middleware/authToken');
const getLogger = require('../utils/logger');

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
  
  // static async deleteUser(req, res) {
  //   const userId = req.params.id;
  //   const updatedBy = req.user.id;
  //   const deletedAt = new Date();

  //   let transaction;
  //   try {
  //     // Start transaction
  //     transaction = await sequelize.transaction();

  //     const user = await User.findByPk(userId, { transaction });

  //     if (!user) {
  //       await transaction.rollback();
  //       return res.status(404).json({ resultKey: false, errorMessage: 'User not found', errorCode: 404 });
  //     }

  //     // Update the user isActive field
  //     await user.update(
  //       {
  //         isActive: false,
  //         updated_by: updatedBy,
  //         deleted_at: deletedAt,
  //       },
  //       { transaction }
  //     );

  //     // Commit transaction
  //     await transaction.commit();

  //     // Return success response
  //     return res.json({ resultKey: true, resultValue: 'User deactivated successfully', resultCode: 200 });
  //   } catch (error) {
  //     // Rollback transaction if not committed
  //     if (transaction && transaction.finished !== 'commit') {
  //       await transaction.rollback();
  //     }

  //     logger.error(`Error deleting user: ${error.message}`, { stack: error.stack })
  //     return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 });
  //   }
  // }

  static async updateAndSaveUser(req, res) {
    const userId = req.params.id;
    const { username, password, role_id, email, isActive, company_id } = req.body;

    let transaction;
    try {
      // Start transaction
      transaction = await sequelize.transaction();

      const existingUser = await User.findOne({ where: { username, company_id } });

      if (existingUser && existingUser.id !== userId) {
        return res.status(400).json({
          resultKey: false,
          errorMessage: 'Username already exists in the same company',
          errorCode: 400,
        });
      }

      const user = await User.findByPk(userId, { transaction });
      if (!user) {
        await transaction.rollback();
        return res.status(404).json({ resultKey: false, errorMessage: 'User not found', errorCode: 404 });
      }

      let hashedPassword = password;
      if (password) {
        hashedPassword = await bcrypt.hash(password, saltRounds);
      }

      // Update the user using model update method
      await user.update(
        {
          username,
          password: hashedPassword,
          role_id,
          email,
          isActive,
          updated_by: req.user.id,
          company_id,
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
