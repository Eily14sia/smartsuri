const express = require('express')
const router = express.Router()
const SuperAdminController = require('../controller/superAdminController')
const AuthService = require('../middleware/authToken')

// Middleware to authenticate token
const authenticateToken = AuthService.authenticateToken

router.get('/projects', authenticateToken, SuperAdminController.getAllAcc)
router.get('/projectTypes', authenticateToken, SuperAdminController.getAllAccType)
router.get('/sites', authenticateToken, SuperAdminController.getAllSite)

router.get('/projects/:id', authenticateToken, SuperAdminController.getAccByID)
router.get('/projectTypes/:id', authenticateToken, SuperAdminController.getAccTypeByID)
router.get('/sites/:id', authenticateToken, SuperAdminController.getSiteByID)

router.get('/logs', authenticateToken, SuperAdminController.getAllLogs)

router.get('/company', authenticateToken, SuperAdminController.getAllCompany)

router.get('/roles', authenticateToken, SuperAdminController.getAllRole)

router.get('/access', authenticateToken, SuperAdminController.getAllAccess)

module.exports = router
