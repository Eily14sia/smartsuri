const { sequelize, Site, LogMaster } = require('../models/database')
const AuthService = require('../middleware/authToken')
const dotenv = require('dotenv')
const moment = require('moment')

dotenv.config()

const useStoredProcedure = process.env.USE_STORED_PROCEDURE

const getLogger = require('../utils/logger')

const logger = getLogger(__filename)

class SiteController {
  static async createSite(req, res) {
    const { name, url, domain, ip } = req.body

    // Define required fields for creating a site
    const requiredFields = ['name', 'url', 'domain', 'ip']

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields)
    if (validationError) {
      return res.status(validationError.errorCode).json(validationError)
    }
    // Start a transaction
    const transaction = await sequelize.transaction()
    debugger;
    try {
      // Check if the site name already exists
      const existingSite = await Site.findOne({ where: { name } }, { transaction })
      if (existingSite) {
        await transaction.rollback()
        return res.status(400).json({ resultKey: false, errorMessage: 'Site name already exists', errorCode: 400 })
      }

      const createdBy = req.user.id
      
      let newSite

      if (useStoredProcedure === 'false') {
        // Use ORM to create site
        newSite = await Site.create(
          {
            name,
            url,
            domain,
            ip,
            isActive: true,
            created_by: createdBy,
            updated_by: createdBy,
          },
          { transaction },
        )

        debugger;
        await transaction.commit()

        return res.json({
          resultKey: true,
          message: 'Site created successfully',
          projectInfo: newSite,
          resultCode: 200,
        })
      } else {
        // Using stored procedure
        const params = {
          p_name: name,
          p_url: url,
          p_domain: domain,
          p_ip: ip,
          p_isActive: 1,
          p_created_by: createdBy,
        }

        const result = await AuthService.executeStoredProcedure('CreateSiteProcedure', params, transaction)

        if (!result.success) {
          await transaction.rollback()
          return res.status(500).json({ resultKey: false, errorMessage: 'Failed to create site', errorCode: 500 })
        }

        // Fetch the newly created site
        newSite = await Site.findOne({ where: { name }, transaction })

        // Log the creation
        const loggingTransaction = await sequelize.transaction()
        try {
          await LogMaster.create(
            {
              tablename: 'site',
              requested_data: JSON.stringify('Create New site'),
              change_data: JSON.stringify({
                id: newSite.id,
                name,
                url,
                domain,
                ip,
                isActive: true,
              }),
              isActive: true,
              created_by: createdBy,
              updated_by: createdBy,
              created_at: new Date(),
            },
            { transaction: loggingTransaction },
          )
          // Commit the logging transaction
          await loggingTransaction.commit()
        } catch (logError) {
          // Rollback the logging transaction in case of error
          await loggingTransaction.rollback()
          logger.error(`Error logging site creation: ${logError.message}`, { stack: logError.stack })
        }

        debugger;
        // Commit the transaction
        await transaction.commit()
      }

      res.json({ resultKey: true, resultMessage: 'Site created successfully', site: newSite, resultCode: 200 })
    } catch (error) {
      if (transaction && !transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error creating site: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: `Server error: ${error.message}`, errorCode: 500 })
    }
  }

  // Controller function to deactivate a site
  static async deleteSite(req, res) {
    const siteId = req.params.id

    const transaction = await sequelize.transaction()
    const originalData = await Site.findByPk(siteId, { transaction })

    if (!originalData) {
      await transaction.rollback()
      return res.status(404).json({ resultKey: false, errorMessage: 'Site not found', errorCode: 404 })
    }

    debugger;
    try {
      if (useStoredProcedure === 'false') {
        // Find the site using ORM
        const site = await Site.findByPk(siteId, { transaction })

        if (!site) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Site not found', errorCode: 404 })
        }

        // Deactivate the site using ORM
        await site.update(
          {
            isActive: false,
            updated_by: req.user.id,
            deleted_at: moment().format('YYYY-MM-DD HH:mm:ss'), // Format datetime
          },
          { transaction },
        )

        debugger;
        await transaction.commit()

        return res.json({
          resultKey: true,
          message: 'Site deactivated successfully',
          resultCode: 200,
        })
      } else {
        // Check if the site exists before deactivating
        const existingSite = await Site.findByPk(siteId, { transaction })

        if (!existingSite) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Site not found', errorCode: 404 })
        }

        // Deactivate the site using stored procedure
        const params = {
          p_site_id: siteId,
          p_updated_by: req.user.id,
          p_deleted_at: moment().format('YYYY-MM-DD HH:mm:ss'), // Format datetime
        }

        const result = await AuthService.executeStoredProcedure('DeactivateSiteProcedure', params, transaction)

        if (!result.success) {
          await transaction.rollback()
          return res.status(500).json({ resultKey: false, errorMessage: 'Failed to deactivate site', errorCode: 500 })
        }

        debugger;
        await transaction.commit()

        // Fetch updated data
        const updatedData = await Site.findByPk(siteId)

        // Log the change
        await AuthService.createLogEntry(originalData.toJSON(), updatedData.toJSON(), 'site', req.user.id, transaction)

        debugger;
        res.json({ resultKey: true, message: 'Site deactivated successfully', resultCode: 200 })
      }
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error deactivating site: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: `Server error: ${error.message}`, errorCode: 500 })
    }
  }

  // Controller function to update and save a site
  static async updateAndSaveSite(req, res) {
    const siteId = req.params.id
    const updated_by = req.user.id
    const { name, url, domain, ip, isActive } = req.body

    // Define required fields for updating user info
    const requiredFields = ['name', 'url', 'domain', 'ip', 'isActive']

    // Validate required fields
    const validationError = AuthService.validateFields(req.body, requiredFields)
    if (validationError) {
      return res.status(validationError.errorCode).json(validationError)
    }

    const transaction = await sequelize.transaction()

    const originalData = await Site.findByPk(siteId, { transaction })

    if (!originalData) {
      await transaction.rollback()
      return res.status(404).json({ resultKey: false, errorMessage: 'Site not found', errorCode: 404 })
    }
    debugger;
    try {
      if (useStoredProcedure === 'false') {
        // Update the site using ORM
        const site = await Site.findByPk(siteId, { transaction })

        if (!site) {
          await transaction.rollback()
          return res.status(404).json({ resultKey: false, errorMessage: 'Site not found', errorCode: 404 })
        }

        // Update the site fields
        site.name = name
        site.url = url
        site.domain = domain
        site.ip = ip
        site.isActive = isActive
        site.updated_by = updated_by 
        site.deleted_at = isActive == 0 ? new Date() : null

        // Save the updated site
        await site.save({ transaction: transaction })
        debugger;
        await transaction.commit()

        return res.json({
          resultKey: true,
          message: 'Site updated successfully',
          resultCode: 200,
        })
      } else {
        // Update the site using stored procedure
        let isActiveNumber
        if (isActive === 'true') {
          isActiveNumber = 1
        } else {
          isActiveNumber = 0
        }
        const params = {
          p_id: siteId,
          p_name: name,
          p_url: url,
          p_domain: domain,
          p_ip: ip,
          p_isActive: isActiveNumber,
          p_updated_by: updated_by,
        }

        const result = await AuthService.executeStoredProcedure('UpdateAndSaveSiteProcedure', params, transaction)

        if (!result.success) {
          await transaction.rollback()
          return res
            .status(500)
            .json({ resultKey: false, errorMessage: 'Failed to update and save site', errorCode: 500 })
        }

        debugger;
        // Commit the transaction
        await transaction.commit()

        const updatedData = await Site.findByPk(siteId)

        // Log the change
        await AuthService.createLogEntry(originalData.toJSON(), updatedData.toJSON(), 'site', req.user.id, transaction)
      }
      debugger;
      res.json({ resultKey: true, message: 'Site updated and saved successfully', resultCode: 200 })
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error updating and saving site: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: `Server error: ${error.message}`, errorCode: 500 })
    }
  }
}
module.exports = SiteController
