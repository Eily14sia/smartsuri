const { sequelize, ProjectType, LogMaster } = require('../models/database')
const AuthService = require('../middleware/authToken')
const dotenv = require('dotenv')

dotenv.config()

const useStoredProcedure = process.env.USE_STORED_PROCEDURE

const getLogger = require('../utils/logger')

const logger = getLogger(__filename)

class ProjectTypeController {
  static async createProjType(req, res) {
    const { type_name, description } = req.body

    // Define required fields for creating account type
    const requiredFields = ['type_name', 'description']

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields)
    if (validationError) {
      return res.status(validationError.errorCode).json(validationError)
    }

    const transaction = await sequelize.transaction()
    debugger;
    try {
      // Check if the account type name already exists
      const existingAccType = await ProjectType.findOne({ where: { type_name }, transaction })
      if (existingAccType) {
        await transaction.rollback()
        return res
          .status(400)
          .json({ resultKey: false, errorMessage: 'Project type name already exists', errorCode: 400 })
      }

      // Get the ID of the user who is creating the account type
      const createdBy = req.user.id

      let newProjType
      if (useStoredProcedure === 'false') {
        // Use ORM
        newProjType = await ProjectType.create(
          {
            type_name,
            description,
            isActive: true,
            created_by: createdBy,
            updated_by: createdBy,
          },
          { transaction },
        )
        debugger;
        await transaction.commit()
      } else {
        // Use the stored procedure
        const params = {
          p_type_name: type_name,
          p_description: description,
          p_isActive: 1,
          p_created_by: createdBy,
        }
        const result = await AuthService.executeStoredProcedure('CreateProjTypeProcedure', params, transaction)

        if (!result.success) {
          await transaction.rollback()
          return res
            .status(500)
            .json({ resultKey: false, errorMessage: 'Failed to create Project Type', errorCode: 500 })
        }

        // Fetch the newly created ProjType
        newProjType = await ProjectType.findOne({ where: { type_name }, transaction })
        debugger;
        await transaction.commit()

        // Log the creation in a separate transaction
        const loggingTransaction = await sequelize.transaction()
        try {
          await LogMaster.create(
            {
              tablename: 'project_type',
              requested_data: JSON.stringify('Create New Project Type'),
              change_data: JSON.stringify({ id: newProjType.id_type, type_name, description, isActive: true }),
              isActive: true,
              created_by: req.user.id,
              updated_by: req.user.id,
              created_at: new Date(),
            },
            { transaction: loggingTransaction },
          )
          await loggingTransaction.commit()
        } catch (logError) {
          // Rollback the logging transaction in case of error
          await loggingTransaction.rollback()
          logger.error(`Error logging Proj Type creation: ${logError.message}`, { stack: logError.stack })
        }
      }
      debugger;
      res.json({
        resultKey: true,
        resultMessage: 'Project type created successfully',
        accountType: newProjType,
        resultCode: 200,
      })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error creating account type: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  static async deleteProjType(req, res) {
    const typeId = req.params.id

    const transaction = await sequelize.transaction()

    const originalData = await ProjectType.findByPk(typeId, { transaction })

    if (!originalData) {
      await transaction.rollback()
      return res.status(404).json({ resultKey: false, errorMessage: 'Site not found', errorCode: 404 })
    }
    debugger;
    try {
      if (useStoredProcedure === 'false') {
        // Find the account type
        const accType = await ProjectType.findByPk(typeId, { transaction })

        if (!accType) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Project type not found', errorCode: 404 })
        }

        // Deactivate the account type using ORM
        await accType.update(
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
        // Use the stored procedure
        const params = {
          p_id: typeId,
          p_updated_by: req.user.id,
        }
        await AuthService.executeStoredProcedure('DeleteProjTypeProcedure', params, transaction)
        debugger;
        await transaction.commit()
        const updatedData = await ProjectType.findByPk(typeId)

        // Log the change
        await AuthService.createLogEntry(
          originalData.toJSON(),
          updatedData.toJSON(),
          'project_type',
          req.user.id,
          transaction,
        )
      }
      debugger;
      res.json({ resultKey: true, message: 'Project type deactivated successfully', resultCode: 200 })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error deactivating Project type: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  static async updateAndSaveProjType(req, res) {
    const type_id = req.params.id
    const updated_by = req.user.id
    const { type_name, description, isActive } = req.body

    // // Define required fields for updating user info
    // const requiredFields = ['type_name', 'description', 'isActive']

    // // Validate required fields
    // const validationError = AuthService.validateFields(req.body, requiredFields)
    // if (validationError) {
    //   return res.status(validationError.errorCode).json(validationError)
    // }

    // Start a transaction
    const transaction = await sequelize.transaction()

    const originalData = await ProjectType.findByPk(type_id, { transaction })

    if (!originalData) {
      await transaction.rollback()
      return res.status(404).json({ resultKey: false, errorMessage: 'Proj Type not found', errorCode: 404 })
    }
    debugger;
    try {
      if (useStoredProcedure === 'false') {
        // Find the account type to update
        const accountType = await ProjectType.findByPk(type_id, { transaction: transaction })

        if (!accountType) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Project Type not found', errorCode: 404 })
        }

        // Check if the type_name is already in use
        const existingType = await ProjectType.findOne({
          where: { type_name },
          transaction: transaction,
        })

        if (existingType && existingType.id !== type_id) {
          await transaction.rollback()
          return res.status(400).json({ resultKey: false, errorMessage: 'Type name already exists', errorCode: 400 })
        }

        accountType.type_name = type_name
        accountType.description = description
        accountType.isActive = isActive
        accountType.updated_by = updated_by
        accountType.deleted_at = isActive == 0 ? new Date() : null
        // Save the updated account type
        await accountType.save({ transaction: transaction })
        debugger;
        // Commit the transaction
        await transaction.commit()
      } else {
        // Check if the type_name is already in use
        const existingType = await ProjectType.findOne({
          where: { type_name },
          transaction: transaction,
        })

        if (existingType && existingType.id !== type_id) {
          await transaction.rollback()
          return res.status(400).json({ resultKey: false, errorMessage: 'Type name already exists', errorCode: 400 })
        }

        let isActiveNumber
        if (isActive === 'true') {
          isActiveNumber = 1
        } else {
          isActiveNumber = 0
        }

        // Use the stored procedure
        const params = {
          p_id: type_id,
          p_type_name: type_name,
          p_description: description,
          p_isActive: isActiveNumber,
          p_updated_by: updated_by,
        }
        await AuthService.executeStoredProcedure('UpdateAndSaveProjTypeProcedure', params, transaction)
        debugger;
        // Commit the transaction
        await transaction.commit()

        const updatedData = await ProjectType.findByPk(type_id)

        // Log the change
        await AuthService.createLogEntry(
          originalData.toJSON(),
          updatedData.toJSON(),
          'project_type',
          req.user.id,
          transaction,
        )
      }
      debugger;
      res.json({ resultKey: true, resultMessage: 'Project type updated and saved successfully', resultCode: 200 })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error updating and saving Project type: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }
}

module.exports = ProjectTypeController
