const express = require('express')
const router = express.Router()

const EventController = require('../controller/eventController'); // Controller for User CRUD operations

const multer = require('multer');

// Configure multer for handling form data without files
const upload = multer();

router.post('/createEvent', upload.none(), EventController.createEvent);
router.get('/getEvent', upload.none(), EventController.getEvent)

module.exports = router
