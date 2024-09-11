const express = require('express')
const router = express.Router()
const AuthController = require('../controller/authController')
const multer = require('multer')

// Configure multer for handling form data without files
const upload = multer()

router.post('/login', upload.none(), AuthController.login)
router.post('/verifcode', upload.none(), AuthController.verifyCode)

module.exports = router
