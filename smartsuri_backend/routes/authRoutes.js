const express = require('express')
const router = express.Router()
const AuthController = require('../controller/authController')
const multer = require('multer')

// Configure multer for handling form data without files
const upload = multer()

router.post('/login', upload.none(), AuthController.login)
router.post('/verifCode', upload.none(), AuthController.verifyLoginCode)
router.post('/resendCode', upload.none(), AuthController.resendVerificationCode);
router.post('/forgetPass', upload.none(), AuthController.forgotPassword);
router.post('/resetPass', upload.none(), AuthController.resetPassword);
router.post('/verifyPass', upload.none(), AuthController.verifyPasswordResetCode);
router.post('/resendPassCode', upload.none(), AuthController.resendPassCode);


module.exports = router
