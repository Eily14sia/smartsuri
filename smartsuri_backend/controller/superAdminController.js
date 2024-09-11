const { ProjectInfo, ProjectType, Site, LogMaster, Company, Role, Access } = require('../models/database')
const getLogger = require('../utils/logger')

const logger = getLogger(__filename)

class SuperAdminController {
  // Controller function to get all accounts
  static async getAllAcc(req, res) {
    debugger;
    try {
      const allAccounts = await ProjectInfo.findAll()
      res.json({ resultKey: true, resultMessage: allAccounts, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting all accounts: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to get all account types
  static async getAllAccType(req, res) {
    debugger;
    try {
      const allAccountTypes = await ProjectType.findAll()
      res.json({ resultKey: true, resultMessage: allAccountTypes, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting all account types: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to get all sites
  static async getAllSite(req, res) {
    debugger;
    try {
      const allSites = await Site.findAll()
      res.json({ resultKey: true, resultMessage: allSites, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting all sites: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to get account by ID
  static async getAccByID(req, res) {
    const accountId = req.params.id
    debugger;
    try {
      const account = await ProjectInfo.findByPk(accountId)
      if (!account) {
        return res.status(404).json({ resultKey: false, errorMessage: 'Account not found' })
      }
      res.json({ resultKey: true, resultMessage: account, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting account by ID: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to get account type by ID
  static async getAccTypeByID(req, res) {
    const accTypeId = req.params.id
    debugger;
    try {
      const accType = await ProjectType.findByPk(accTypeId)
      if (!accType) {
        return res.status(404).json({ resultKey: false, errorMessage: 'Account type not found', errorCode: 404 })
      }
      res.json({ resultKey: true, resultMessage: accType, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting account type by ID: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to get site by ID
  static async getSiteByID(req, res) {
    const siteId = req.params.id
    debugger;
    try {
      const site = await Site.findByPk(siteId)
      if (!site) {
        return res.status(404).json({ resultKey: false, errorMessage: 'Site not found', errorCode: 404 })
      }
      res.json({ resultKey: true, resultMessage: site, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting site by ID: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to get all logs
  static async getAllLogs(req, res) {
    debugger;
    try {
      const allLogs = await LogMaster.findAll()
      res.json({ resultKey: true, resultMessage: allLogs, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting all logs: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to get all companies
  static async getAllCompany(req, res) {
    debugger;
    try {
      const allCompanies = await Company.findAll()
      res.json({ resultKey: true, resultMessage: allCompanies, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting all companies: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to get all role
  static async getAllRole(req, res) {
    debugger;
    try {
      const allRole = await Role.findAll()
      res.json({ resultKey: true, resultMessage: allRole, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting all roles: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  // Controller function to get all accedss
  static async getAllAccess(req, res) {
    debugger;
    try {
      const allAccess = await Access.findAll()
      res.json({ resultKey: true, resultMessage: allAccess, resultCode: 200 })
    } catch (error) {
      logger.error(`Error getting all access: ${error.message}`, {
        stack: error.stack,
      })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }
}

module.exports = SuperAdminController
