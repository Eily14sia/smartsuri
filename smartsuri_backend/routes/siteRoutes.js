const express = require('express')
const router = express.Router()
const SiteController = require('../controller/siteController') // Controller for Site CRUD operations

const multer = require('multer')
const AuthService = require('../middleware/authToken') // Middleware

// Middleware to authenticate token
const authenticateToken = AuthService.authenticateToken

// Configure multer for handling form data without files
const upload = multer()

//Site Create, Update and Delete
router.post('/createSite', authenticateToken, upload.none(), SiteController.createSite)
router.put('/deleteSite/:id', authenticateToken, SiteController.deleteSite)
router.put('/updateSite/:id', authenticateToken, upload.none(), SiteController.updateAndSaveSite)

module.exports = router
