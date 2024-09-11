const { sequelize, Access, LogMaster } = require('../models/database')
const AuthService = require('../middleware/authToken')
const dotenv = require('dotenv')

dotenv.config()

const useStoredProcedure = process.env.USE_STORED_PROCEDURE

const getLogger = require('../utils/logger')

const logger = getLogger(__filename)

class AccessController {
  // Controller function to create access
  static async createAccess(req, res) {
    const { web_access, app_access, role_id } = req.body

    // Define required fields for creating access
    const requiredFields = ['web_access', 'app_access', 'role_id']

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields)
    if (validationError) {
      return res.status(validationError.errorCode).json(validationError)
    }

    // Start a transaction
    const transaction = await sequelize.transaction()
    let newAccess = null 
    debugger;
    try {
      if (useStoredProcedure === 'false') {
        // Use ORM
        const createdBy = req.user.id

        // Create the access
        newAccess = await Access.create(
          {
            web_access,
            app_access,
            isActive: true,
            role_id,
            created_by: createdBy,
            updated_by: createdBy,
          },
          { transaction },
        )
        debugger;
          // Commit the transaction
        await transaction.commit()

      } else {
        // Use stored procedure
        const createdBy = req.user.id
        const params = {
          p_web_access: web_access,
          p_app_access: app_access,
          p_isActive: 1,
          p_role_id: role_id,
          p_created_by: createdBy,
        }
        await AuthService.executeStoredProcedure('CreateAccessProcedure', params, transaction)
        debugger;
        // Log creation
        const loggingTransaction = await sequelize.transaction()
        try {
          await LogMaster.create(
            {
              tablename: 'access',
              requested_data: JSON.stringify('Create New Access'),
              change_data: JSON.stringify({ web_access, app_access, role_id }),
              isActive: true,
              created_by: req.user.id,
              updated_by: req.user.id,
              created_at: new Date(),
            },
            { transaction: loggingTransaction },
          )

          await loggingTransaction.commit()
        } catch (logError) {
          await loggingTransaction.rollback()
          logger.error(`Error logging access creation: ${logError.message}`, { stack: logError.stack })
        }
      }
      debugger;
      // Commit the transaction
      await transaction.commit()

      res.json({ resultKey: true, message: 'Access created successfully', access: newAccess, resultCode: 200 })
    } catch (error) {
      if (transaction.finished !== 'commit') {
        await transaction.rollback()
      }
      logger.error(`Error creating access: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to deactivate access
  static async deleteAccess(req, res) {
    const accessId = req.params.id

    // Start a transaction
    const transaction = await sequelize.transaction()
    try {
      const originalData = await Access.findByPk(accessId, { transaction })

      if (!originalData) {
        await transaction.rollback()
        return res.status(404).json({ resultKey: false, errorMessage: 'Access not found', errorCode: 404 })
      }

      // Find the access
      const access = await Access.findByPk(accessId, { transaction })

      if (!access) {
        await transaction.rollback()
        return res.status(404).json({ resultKey: false, errorMessage: 'Access not found', errorCode: 404 })
      }

      if (useStoredProcedure === 'false') {
        // Use ORM
        // Deactivate the access
        await access.update(
          {
            isActive: false,
            updated_by: req.user.id,
            deleted_at: new Date(),
          },
          { transaction },
        )
        debugger;
        // Commit the transaction
        await transaction.commit()
      } else {
        // Use stored procedure
        const params = {
          p_id: accessId,
          p_updated_by: req.user.id,
        }
        await AuthService.executeStoredProcedure('DeleteAccessProcedure', params, transaction)
        debugger;
        // Commit the transaction
        await transaction.commit()

        const updatedData = await Access.findByPk(accessId)

        // Log the change
        await AuthService.createLogEntry(
          originalData.toJSON(),
          updatedData.toJSON(),
          'access',
          req.user.id,
          transaction,
        )
      }
      debugger;
      res.json({ resultKey: true, message: 'Access deactivated successfully', resultCode: 200 })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error deactivating access: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to update and save access
  static async updateAndSaveAccess(req, res) {
    const accessId = req.params.id
    const updatedBy = req.user.id
    const { web_access, app_access, isActive, role_id } = req.body

    // // Define required fields for updating access
    // const requiredFields = ['web_access', 'app_access', 'isActive', 'role_id']

    // // Validate required fields
    // const validationError = AuthService.validateFields(req.body, requiredFields)
    // if (validationError) {
    //   return res.status(validationError.errorCode).json(validationError)
    // }

    // Start a transaction
    const transaction = await sequelize.transaction()
    try {
      const originalData = await Access.findByPk(accessId, { transaction })

      if (!originalData) {
        await transaction.rollback()
        return res.status(404).json({ resultKey: false, errorMessage: 'Access not found', errorCode: 404 })
      }

      // Find the access to update
      const access = await Access.findByPk(accessId, { transaction })

      if (!access) {
        await transaction.rollback()
        return res.status(404).json({ resultKey: false, errorMessage: 'Access not found', errorCode: 404 })
      }

      if (useStoredProcedure === 'false') {
        // Use ORM
        access.web_access = web_access
        access.app_access = app_access
        access.isActive = isActive
        access.role_id = role_id
        access.updated_by = updatedBy
        access.deleted_at = isActive == 0 ? new Date() : null

        // Save the updated access
        await access.save({ transaction })
        debugger;
        // Commit the transaction
        await transaction.commit()
      } else {
        // Use stored procedure
        let isActiveNumber
        if (isActive === 'true') {
          isActiveNumber = 1
        } else {
          isActiveNumber = 0
        }
        const params = {
          p_id: accessId,
          p_web_access: JSON.stringify(web_access),
          p_app_access: JSON.stringify(app_access),
          p_isActive: isActiveNumber,
          p_role_id: role_id,
          p_updated_by: updatedBy,
        }
        await AuthService.executeStoredProcedure('UpdateAndSaveAccessProcedure', params, transaction)
        debugger;
        await transaction.commit()
        const updatedData = await Access.findByPk(accessId)

        // Log the change
        await AuthService.createLogEntry(
          originalData.toJSON(),
          updatedData.toJSON(),
          'access',
          req.user.id,
          transaction,
        )
      }
      debugger;
      res.json({ resultKey: true, message: 'Access updated and saved successfully', resultCode: 200 })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error updating and saving access: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }
}

module.exports = AccessController
