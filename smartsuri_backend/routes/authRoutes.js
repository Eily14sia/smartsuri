const express = require('express')
const router = express.Router()
const AuthController = require('../controller/authController')
const multer = require('multer')

// Configure multer for handling form data without files
const upload = multer()

router.post('/login', upload.none(), AuthController.login)
router.post('/verifCode', upload.none(), AuthController.verifyCode)
router.post('/resendCode', AuthController.resendVerificationCode);

module.exports = router
