const express = require('express')
const router = express.Router()
const CompanyController = require('../controller/companyController') // Controller for Company CRUD operations

const multer = require('multer')
const AuthService = require('../middleware/authToken') // Middleware

// Middleware to authenticate token
const authenticateToken = AuthService.authenticateToken

// Configure multer for handling form data without files
const upload = multer()

//Company Create, Update and Delete
router.post('/createCompany', authenticateToken, upload.none(), CompanyController.createCompany)
router.put('/deleteCompany/:id', authenticateToken, CompanyController.deleteCompany)
router.put('/updateCompany/:id', authenticateToken, upload.none(), CompanyController.updateAndSaveCompany)

module.exports = router
