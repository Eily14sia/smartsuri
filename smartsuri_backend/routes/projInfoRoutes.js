const express = require('express')
const router = express.Router()
const ProjInfoController = require('../controller/projInfoController') // Controller for Project CRUD operations

const multer = require('multer')
const AuthService = require('../middleware/authToken') // Middleware

// Middleware to authenticate token
const authenticateToken = AuthService.authenticateToken

const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 } // 10 MB limit
});

//ProjectInfo Create, Update and Delete
router.post('/createProjInfo', authenticateToken, upload.single('logo'), ProjInfoController.createProjInfo)
router.put('/deleteProjInfo/:id', authenticateToken, ProjInfoController.deleteProjInfo)
router.post('/updateProjInfo/:id', authenticateToken, upload.single('logo'), ProjInfoController.updateAndSaveProjInfo)

module.exports = router
