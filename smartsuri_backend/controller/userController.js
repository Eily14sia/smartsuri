const { sequelize, User, LogMaster } = require('../models/database')
const { UniqueConstraintError } = require('sequelize')
const bcrypt = require('bcrypt')

const saltRounds = 10 //adjust the salt rounds for hashing
const AuthService = require('../middleware/authToken')
const dotenv = require('dotenv')

dotenv.config()

const getLogger = require('../utils/logger')

const logger = getLogger(__filename)

const useStoredProcedure = process.env.USE_STORED_PROCEDURE

class UserController {
  static async createUser(req, res) {
    const { username, password, role_id, email, company_id, birthday, city, prof_img, name } = req.body;
    const requiredFields = ['username', 'password', 'role_id', 'email', 'birthday', 'city', 'prof_img', 'name'];
  
    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields);
    if (validationError) {
      return res.status(400).json(validationError);
    }
  
    let transaction;
    try {
      // Check if the username already exists within the company
      const existingUser = await User.findOne({ where: { username, company_id } });
      if (existingUser) {
        return res.status(400).json({
          resultKey: false,
          errorMessage: 'Username already exists in this company',
          errorCode: 400,
        });
      }
  
      // Start transaction
      transaction = await sequelize.transaction();
  
      let newUser;
      const hashedPassword = await bcrypt.hash(password, 10);
  
      // Assuming `useStoredProcedure` is defined somewhere, either as a config or environment variable
      if (useStoredProcedure === 'false') {
        // Using ORM for user creation
        try {
          newUser = await User.create(
            {
              username,
              password: hashedPassword,
              role_id,
              isActive: true,
              email,
              birthday,
              city,
              prof_img,
              name,
              created_by: null, // Signup has no creator (adjust if needed)
              updated_by: null, // Adjust if there is a process that updates the user on creation
              company_id,
            },
            { transaction }
          );
  
          await transaction.commit();
  
          // Return success response
          return res.json({ resultKey: true, user: newUser, resultCode: 200 });
  
        } catch (error) {
          await transaction.rollback();
  
          // Handle Unique Constraint error or others
          if (error instanceof UniqueConstraintError && error.errors.length > 0) {
            const errorMessage = error.errors[0].message;
            return res.status(400).json({
              resultKey: false,
              errorMessage,
              errorCode: 400,
            });
          }
  
          // Log and return generic server error
          logger.error(`Error creating new user in ORM: ${error.message}`, { stack: error.stack });
          return res.status(500).json({
            resultKey: false,
            errorMessage: 'Server error',
            errorCode: 500,
          });
        }
      }
    } catch (error) {
      // Handle any transaction errors
      if (transaction) await transaction.rollback();
  
      logger.error(`Error creating new user: ${error.message}`, { stack: error.stack });
      return res.status(500).json({
        resultKey: false,
        errorMessage: 'Server error',
        errorCode: 500,
      });
    }
  }  

  static async deleteUser(req, res) {
    const userId = req.params.id
    const updatedBy = req.user.id 
    const deletedAt = new Date()

    // Initialize transaction
    const transaction = await sequelize.transaction()

    debugger;
    try {
      const originalData = await User.findByPk(userId, { transaction })
      debugger;

      if (!originalData) {
        await transaction.rollback()
        return res.status(404).json({ resultKey: false, errorMessage: 'User not found', errorCode: 404 })
      }

      if (useStoredProcedure === 'false') {
        // Using ORM
        const user = await User.findByPk(userId, { transaction })

        if (!user) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'User not found', errorCode: 404 })
        }

        // Update the user isActive field
        await user.update(
          {
            isActive: false,
            updated_by: updatedBy,
            deleted_at: deletedAt,
          },
          { transaction },
        )

        debugger;
        // Commit transaction
        await transaction.commit()
      } else {
        // Using stored procedure
        const params = {
          p_user_id: userId,
          p_updated_by: updatedBy,
        }

        const result = await AuthService.executeStoredProcedure('DeleteUserProcedure', params, transaction)
        // Fetch the updated user data

        debugger;
        // Commit transaction
        await transaction.commit()

        const updatedData = await User.findByPk(userId)

        // Log the change
        await AuthService.createLogEntry(originalData.toJSON(), updatedData.toJSON(), 'users', req.user.id, transaction)
      }

      return res.json({ resultKey: true, resultValue: 'User deactivated successfully', resultCode: 200 })
    } catch (error) {
      // Rollback transaction if not committed
      if (transaction.finished !== 'commit') {
        await transaction.rollback()
      }
      logger.error(`Error deleting user: ${error.message}`, { stack: error.stack })
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  static async updateAndSaveUser(req, res) {
    const userId = req.params.id
    const { username, password, role_id, email, isActive, company_id } = req.body
    // const requiredFields = ['username', 'role_id', 'email', 'isActive', 'company_id']

    const originalData = await User.findByPk(userId)
    if (!originalData) {
      await transaction.rollback()
      return res.status(404).json({ resultKey: false, errorMessage: 'User not found', errorCode: 404 })
    }

    let transaction
    try {
      const existingUser = await User.findOne({ where: { username, company_id } })
      if (existingUser && existingUser.id !== userId) {
        // logger.info('Username already exists in the same company')
        return res
          .status(400)
          .json({ resultKey: false, errorMessage: 'Username already exists in the same company', errorCode: 400 })
      }

      debugger;

      if (useStoredProcedure === 'false') {
        // Using ORM
        let hashedPassword = password
        if (password) {
          hashedPassword = await bcrypt.hash(password, 10) 
        }

        transaction = await sequelize.transaction()
        try {
          const user = await User.findByPk(userId, { transaction })
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
            {
              where: { id: userId },
              transaction,
            },
          )

          debugger;

          await transaction.commit()

          // Fetch the updated user
          const updatedData = await User.findByPk(userId)

          return res.json({ resultKey: true, user: updatedData, resultCode: 200 })
        } catch (error) {
          await transaction.rollback()
          logger.error(`Error updating user in ORM: ${error.message}`, { stack: error.stack })

          return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
        }
      } else {
        let isActiveNumber
        if (isActive === 'true') {
          isActiveNumber = 1
        } else {
          isActiveNumber = 0
        }
        // Using stored procedure
        transaction = await sequelize.transaction()
        const params = {
          p_user_id: userId,
          p_username: username,
          p_password: password,
          p_role_id: role_id,
          p_email: email,
          p_is_active: isActiveNumber,
          p_updated_by: req.user.id,
          p_company_id: company_id,
        }

        try {
          let hashedPassword = password
          if (password) {
            hashedPassword = await bcrypt.hash(password, 10) 
          }

          const result = await AuthService.executeStoredProcedure(
            'UpdateUserProcedure',
            { ...params, p_password: hashedPassword },
            transaction,
          )
          // Check if isActive is 1 and update deleted_at to null
          if (isActiveNumber === 1) {
            await User.update({ deleted_at: null }, { where: { id: userId }, transaction })
          } else {
            await User.update({ deleted_at: new Date() }, { where: { id: userId }, transaction })
          }

          debugger;

          await transaction.commit()

          if (!result.success) {
            return res.status(500).json({ resultKey: false, errorMessage: 'Failed to update user', errorCode: 500 })
          }
          // Fetch the updated user
          const updatedData = await User.findByPk(userId)

          // Log the change
          await AuthService.createLogEntry(
            originalData.toJSON(),
            updatedData.toJSON(),
            'users',
            req.user.id,
            transaction,
          )
          
          debugger;

          return res.json({ resultKey: true, user: updatedData, resultCode: 200 })
        } catch (error) {
          await transaction.rollback()

          logger.error(`Error updating user in stored procedure: ${error.message}`, { stack: error.stack })
          return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
        }
      }
    } catch (error) {
      logger.error(`Error updating user: ${error.message}`, { stack: error.stack })
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }
}

module.exports = UserController
