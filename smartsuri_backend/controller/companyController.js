const { sequelize, Company, LogMaster } = require('../models/database')
const AuthService = require('../middleware/authToken')
const dotenv = require('dotenv')

dotenv.config()

const useStoredProcedure = process.env.USE_STORED_PROCEDURE

const getLogger = require('../utils/logger')

const logger = getLogger(__filename)

class CompanyController {
  static async createCompany(req, res) {
    const { name } = req.body

    // Define required fields for creating company
    const requiredFields = ['name']

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields)
    if (validationError) {
      return res.status(validationError.errorCode).json(validationError)
    }

    // Start a transaction
    const transaction = await sequelize.transaction()
    debugger;
    try {
      // Check if the company name already exists
      const existingCompany = await Company.findOne({ where: { name }, transaction: transaction })
      if (existingCompany) {
        await transaction.rollback()
        return res.status(400).json({ resultKey: false, errorMessage: 'Company name already exists', errorCode: 400 })
      }

      let newCompany

      if (useStoredProcedure === 'false') {

        const createdBy = req.user.id

        // Create the company
        newCompany = await Company.create(
          {
            name,
            isActive: true,
            created_by: createdBy,
            updated_by: createdBy,
          },
          { transaction: transaction },
        )
        // Commit the transaction
        debugger;
        await transaction.commit()
      } else {
        // Use the stored procedure
        const createdBy = req.user.id
        const params = {
          p_name: name,
          p_isActive: 1,
          p_created_by: createdBy,
        }
        await AuthService.executeStoredProcedure('CreateCompanyProcedure', params, transaction)

        // Fetch the newly created company
        newCompany = await Company.findOne({ where: { name }, transaction: transaction })

        // Commit the transaction
        debugger;
        await transaction.commit()

        // Log creation
        const loggingTransaction = await sequelize.transaction()
        try {
          await LogMaster.create(
            {
              tablename: 'company',
              requested_data: JSON.stringify('Create New Company'),
              change_data: JSON.stringify(newCompany),
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
          logger.error(`Error logging company creation: ${logError.message}`, { stack: logError.stack })
        }
      }
      debugger;
      res.json({ resultKey: true, resultMessage: 'Company created successfully', company: newCompany, resultCode: 200 })
    } catch (error) {
      if (transaction.finished !== 'commit') {
        await transaction.rollback()
      }
      logger.error(`Error creating company: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to deactivate a company
  static async deleteCompany(req, res) {
    const companyId = req.params.id
    const updatedBy = req.user.id

    const transaction = await sequelize.transaction()

    const originalData = await Company.findByPk(companyId, { transaction })

    if (!originalData) {
      await transaction.rollback()
      return res.status(404).json({ resultKey: false, errorMessage: 'Company not found', errorCode: 404 })
    }
    debugger;
    try {
      if (useStoredProcedure === 'false') {
        // Find the company
        const company = await Company.findByPk(companyId, { transaction: transaction })

        if (!company) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Company not found', errorCode: 404 })
        }

        // Deactivate the company
        await company.update(
          {
            isActive: false,
            updated_by: updatedBy,
            deleted_at: new Date(),
          },
          { transaction: transaction },
        )
        debugger;
        await transaction.commit()
      } else {
        // Use the stored procedure
        const params = {
          p_id: companyId,
          p_updated_by: updatedBy,
        }
        await AuthService.executeStoredProcedure('DeleteCompanyProcedure', params, transaction)

        // Fetch the deactivated company
        const company = await Company.findByPk(companyId, { transaction: transaction })

        if (!company) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Company not found', errorCode: 404 })
        }
        debugger;
        await transaction.commit()

        const updatedData = await Company.findByPk(companyId)

        // Log the change
        await AuthService.createLogEntry(
          originalData.toJSON(),
          updatedData.toJSON(),
          'company',
          req.user.id,
          transaction,
        )
      }
      debugger;
      res.json({ resultKey: true, message: 'Company deactivated successfully', resultCode: 200 })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error deactivating company: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to update and save a company
  static async updateAndSaveCompany(req, res) {
    const companyId = req.params.id
    const updatedBy = req.user.id
    const { name, isActive } = req.body

    // // Define required fields for updating company info
    // const requiredFields = ['name', 'isActive']

    // // Validate required fields
    // const validationError = AuthService.validateFields(req.body, requiredFields)
    // if (validationError) {
    //   return res.status(validationError.errorCode).json(validationError)
    // }

    // Start a transaction
    const transaction = await sequelize.transaction()

    const originalData = await Company.findByPk(companyId, { transaction })

    if (!originalData) {
      await transaction.rollback()
      return res.status(404).json({ resultKey: false, errorMessage: 'Company not found', errorCode: 404 })
    }
    debugger;
    try {
      if (useStoredProcedure === 'false') {
        // Find the company to update
        const company = await Company.findByPk(companyId, { transaction: transaction })

        if (!company) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Company not found', errorCode: 404 })
        }

        // Update company fields
        company.name = name
        company.isActive = isActive
        company.updated_by = updatedBy
        company.deleted_at = isActive == 0 ? new Date() : null

        // Save the updated company
        await company.save({ transaction: transaction })
        debugger;
        // Commit the transaction
        await transaction.commit()
      } else {
        // Use the stored procedure
        let isActiveNumber
        if (isActive === 'true') {
          isActiveNumber = 1
        } else {
          isActiveNumber = 0
        }
        const params = {
          p_id: companyId,
          p_name: name,
          p_isActive: isActiveNumber,
          p_updated_by: updatedBy,
        }
        await AuthService.executeStoredProcedure('UpdateAndSaveCompanyProcedure', params, transaction)

        // Fetch the updated company
        const company = await Company.findByPk(companyId, { transaction: transaction })

        if (!company) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Company not found', errorCode: 404 })
        }
        debugger;
        await transaction.commit()

        const updatedData = await Company.findByPk(companyId)

        // Log the change
        await AuthService.createLogEntry(
          originalData.toJSON(),
          updatedData.toJSON(),
          'company',
          req.user.id,
          transaction,
        )
      }
      debugger;
      res.json({
        resultKey: true,
        message: 'Company updated and saved successfully',
        resultCode: 200,
      })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error updating and saving company: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }
}

module.exports = CompanyController
