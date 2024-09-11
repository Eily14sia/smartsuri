const { sequelize, Role, LogMaster } = require('../models/database')
const AuthService = require('../middleware/authToken')
const dotenv = require('dotenv')

dotenv.config()

const useStoredProcedure = process.env.USE_STORED_PROCEDURE

const getLogger = require('../utils/logger')

const logger = getLogger(__filename)

class RoleController {
  // Controller function to create a role
  static async createRole(req, res) {
    const { name } = req.body

    // Define required fields for creating a role
    const requiredFields = ['name']

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields)
    if (validationError) {
      return res.status(validationError.errorCode).json(validationError)
    }

    const roleTransaction = await sequelize.transaction()
    debugger;
    try {
      let newRole
      if (useStoredProcedure === 'false') {
        // Check if the role name already exists
        const existingRole = await Role.findOne({ where: { name }, transaction: roleTransaction })
        if (existingRole) {
          await roleTransaction.rollback()
          return res.status(400).json({ resultKey: false, errorMessage: 'Role name already exists', errorCode: 400 })
        }

        // Get the ID of the user who is creating the role
        const createdBy = req.user.id

        // Create the role
        newRole = await Role.create(
          {
            name,
            isActive: true,
            created_by: createdBy,
            updated_by: createdBy,
          },
          { transaction: roleTransaction },
        )
        debugger;
        await roleTransaction.commit()
      } else {
        const params = {
          p_name: name,
          p_isActive: 1,
          p_created_by: req.user.id,
        }
        await AuthService.executeStoredProcedure('CreateRoleProcedure', params, roleTransaction)

        // Fetch the created role
        newRole = await Role.findOne({ where: { name }, transaction: roleTransaction })

        if (!newRole) {
          await roleTransaction.rollback()
          return res.status(400).json({ resultKey: false, errorMessage: 'Role creation failed', errorCode: 400 })
        }
        debugger;
        await roleTransaction.commit()

        // Log the creation in a separate transaction
        const loggingTransaction = await sequelize.transaction()
        try {
          await LogMaster.create(
            {
              tablename: 'role',
              requested_data: JSON.stringify('Create New Role'),
              change_data: JSON.stringify({ id: newRole.id, name, isActive: true }),
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
          logger.error(`Error logging role creation: ${logError.message}`, { stack: logError.stack })
        }
        debugger;
      }

      res.json({ resultKey: true, message: 'Role created successfully', role: newRole, resultCode: 200 })
    } catch (error) {
      if (roleTransaction && !roleTransaction.finished) {
        await roleTransaction.rollback()
      }
      logger.error(`Error creating role: ${error.message}`, { stack: error.stack })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to delete/deactivate a role
  static async deleteRole(req, res) {
    const roleId = req.params.id

    const transaction = await sequelize.transaction()

    const originalData = await Role.findByPk(roleId, { transaction })

    if (!originalData) {
      await transaction.rollback()
      return res.status(404).json({ resultKey: false, errorMessage: 'Role not found', errorCode: 404 })
    }
    debugger;
    try {
      if (useStoredProcedure === 'false') {
        // Use ORM
        // Find the role
        const role = await Role.findByPk(roleId, { transaction })

        if (!role) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Role not found', errorCode: 404 })
        }

        // Deactivate the role
        await role.update(
          {
            isActive: false,
            updated_by: req.user.id,
            deleted_at: new Date(),
          },
          { transaction },
        )
        debugger;
        await transaction.commit()
      } else {
        // Use stored procedure
        const params = {
          p_id: roleId,
          p_updated_by: req.user.id,
        }
        await AuthService.executeStoredProcedure('DeleteRoleProcedure', params, transaction)
        debugger;
        await transaction.commit()

        const updatedData = await Role.findByPk(roleId)
        
        // Log the change
        await AuthService.createLogEntry(originalData.toJSON(), updatedData.toJSON(), 'role', req.user.id, transaction)
      }
      debugger;
      res.json({ resultKey: true, message: 'Role deactivated successfully', resultCode: 200 })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error deactivating role: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to update and save a role
  static async updateAndSaveRole(req, res) {
    const roleId = req.params.id
    const updatedBy = req.user.id
    const { name, isActive } = req.body

    // // Define required fields for updating role info
    // const requiredFields = ['name', 'isActive']

    // // Validate required fields
    // const validationError = AuthService.validateFields(req.body, requiredFields)
    // if (validationError) {
    //   return res.status(validationError.errorCode).json(validationError)
    // }

    // Start a transaction
    const transaction = await sequelize.transaction()
    debugger;
    const originalData = await Role.findByPk(roleId, { transaction })

    if (!originalData) {
      await transaction.rollback()
      return res.status(404).json({ resultKey: false, errorMessage: 'Role not found', errorCode: 404 })
    }

    try {
      if (useStoredProcedure === 'false') {
        // Use ORM
        // Find the role to update
        const role = await Role.findByPk(roleId, { transaction })

        if (!role) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Role not found', errorCode: 404 })
        }

        // Update role fields
        role.name = name
        role.isActive = isActive
        role.updated_by = updatedBy
        role.deleted_at = isActive === false ? new Date() : null

        // Save the updated role
        await role.save({ transaction })
        debugger;
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
          p_id: roleId,
          p_name: name,
          p_isActive: isActiveNumber,
          p_updated_by: updatedBy,
        }
        await AuthService.executeStoredProcedure('UpdateAndSaveRoleProcedure', params, transaction)
        debugger;
        // Commit the transaction
        await transaction.commit()

        const updatedData = await Role.findByPk(roleId)

        // Log the change
        await AuthService.createLogEntry(originalData.toJSON(), updatedData.toJSON(), 'role', req.user.id, transaction)
      }
      debugger;
      res.json({ resultKey: true, message: 'Role updated and saved successfully', resultCode: 200 })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error updating and saving role: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }
}

module.exports = RoleController
