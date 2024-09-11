const express = require('express')
const router = express.Router()

const AccessController = require('../controller/accessController') // Controller for Access CRUD operations

const multer = require('multer')
const AuthService = require('../middleware/authToken') // Middleware

// Middleware to authenticate token
const authenticateToken = AuthService.authenticateToken

// Configure multer for handling form data without files
const upload = multer()

//Access Create, Update and Delete
router.post('/createAccess', authenticateToken, upload.none(), AccessController.createAccess)
router.put('/deleteAccess/:id', authenticateToken, AccessController.deleteAccess)
router.put('/updateAccess/:id', authenticateToken, upload.none(), AccessController.updateAndSaveAccess)

module.exports = router
