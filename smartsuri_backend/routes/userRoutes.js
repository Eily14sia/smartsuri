const express = require('express');
const router = express.Router();
const UserController = require('../controller/userController'); // Controller for User CRUD operations

const multer = require('multer');
const AuthService = require('../middleware/authToken'); // Middleware

// Middleware to authenticate token
const authenticateToken = AuthService.authenticateToken;

// Configure multer for handling form data without files
const upload = multer();

// User Create (Signup), Update, and Delete
// Signup endpoint should not require authentication
router.post('/createUser', upload.none(), UserController.createUser);
router.post('/verifyEmail', upload.none(), UserController.verifyEmail)

// Other endpoints that require authentication
router.put('/updateUser/:id', authenticateToken, upload.none(), UserController.updateAndSaveUser);
// router.delete('/deleteUser/:id', authenticateToken, UserController.deleteUser);

module.exports = router;
