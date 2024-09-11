const express = require('express')
const router = express.Router()
const ProjTypeController = require('../controller/projTypeController') // Controller for ProjType CRUD operations

const multer = require('multer')
const AuthService = require('../middleware/authToken') // Middleware

// Middleware to authenticate token
const authenticateToken = AuthService.authenticateToken

// Configure multer for handling form data without files
const upload = multer()

//ProjType Create, Update and Delete
router.post('/createProjType', authenticateToken, upload.none(), ProjTypeController.createProjType)
router.put('/deleteProjType/:id', authenticateToken, ProjTypeController.deleteProjType)
router.put('/updateProjType/:id', authenticateToken, upload.none(), ProjTypeController.updateAndSaveProjType)

module.exports = router
