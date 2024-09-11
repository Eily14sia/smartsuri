const express = require('express')
const router = express.Router()
const RoleController = require('../controller/roleController') // Controller for Role CRUD operations

const multer = require('multer')
const AuthService = require('../middleware/authToken') // Middleware

// Middleware to authenticate token
const authenticateToken = AuthService.authenticateToken

// Configure multer for handling form data without files
const upload = multer()

//Role Create, Update and Delete
router.post('/createRole', authenticateToken, upload.none(), RoleController.createRole)
router.put('/deleteRole/:id', authenticateToken, RoleController.deleteRole)
router.put('/updateRole/:id', authenticateToken, upload.none(), RoleController.updateAndSaveRole)

module.exports = router
