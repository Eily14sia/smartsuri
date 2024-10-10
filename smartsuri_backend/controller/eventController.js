const { sequelize, Event, LogMaster, User } = require('../models/database');
const { UniqueConstraintError } = require('sequelize');
const dotenv = require('dotenv');
const getLogger = require('../utils/logger');
const nodemailer = require('nodemailer');
const moment = require('moment');

dotenv.config();
const logger = getLogger(__filename);

class EventController {
  static async createEvent(req, res) {
    const { name, date, location, details } = req.body;
  
    console.log(req.body);
  
    if (!name || !date || !location || !details) {
      return res.status(400).json({ message: 'Event name, date, location, and description are required' });
    }
  
    try {
      // Convert the date from 'MMMM D, YYYY' to 'YYYY-MM-DD'
      const formattedDate = moment(date, 'MMMM D, YYYY').format('YYYY-MM-DD');
  
      console.log(formattedDate);
  
      // Create a new event record in the database
      const newEvent = await Event.create({
        name,
        date: formattedDate,
        location,
        details,
        isActive: true,
      });
  
      logger.info(`Event created: ${newEvent.name}`);
  
      // Fetch all users from the User model (in a separate query)
      const users = await User.findAll({
        attributes: ['email'], // Retrieve only the email field
      });
  
      if (!users || users.length === 0) {
        return res.status(404).json({ message: 'No users found to send emails' });
      }
  
      // Extract email addresses from users
      const emailAddresses = users.map(user => user.email);
  
      // Immediately respond to the client that the event was created
      res.status(200).json({
        resultKey: true,
        message: 'Event created successfully. Emails will be sent to all users shortly.',
        resultCode: 200,
        event: newEvent,
      });
  
      // Send emails asynchronously without blocking the response
      setImmediate(async () => {
        try {
          // Setup Nodemailer transporter
          const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
              user: process.env.EMAIL_USER, // Your Gmail address
              pass: process.env.EMAIL_PASS, // Your Gmail password or App Password
            },
            tls: {
              rejectUnauthorized: false,
            },
          });
  
          // Email options for bulk email
          const mailOptions = {
            from: process.env.EMAIL_USER,
            to: emailAddresses, // Send emails to all users
            subject: `Event Details: ${newEvent.name}`,
            text: `Event Name: ${newEvent.name}\nDate: ${newEvent.date}\nLocation: ${newEvent.location}\nDescription: ${newEvent.details}`,
          };
  
          // Send bulk email to all users
          await transporter.sendMail(mailOptions);
          logger.info(`Emails sent to ${emailAddresses.join(', ')} regarding event: ${newEvent.name}`);
        } catch (emailError) {
          logger.error(`Error sending emails: ${emailError.message}`);
        }
      });
  
    } catch (error) {
      // Handle Sequelize unique constraint errors
      if (error instanceof UniqueConstraintError) {
        logger.error(`Error creating event: Event name already exists`);
        return res.status(409).json({ message: 'Event with the same name already exists' });
      }
  
      // Log any other errors
      logger.error(`Error creating event: ${error.message}`);
      return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
  }
  
  
  static async getEvent(req, res) {
    try {
      // Fetch all events from the database in descending order by id
      const events = await Event.findAll({
        order: [['id', 'DESC']]
      });
  
      // If no events are found, return a 404 status
      if (!events || events.length === 0) {
        return res.status(404).json({ message: 'No events found' });
      }
  
      // Log the event retrieval
      logger.info('Events retrieved successfully');
      return res.status(200).json({
        resultKey: true,
        message: 'Event fetched successfully',
        resultCode: 200,
        events
      });
    } catch (error) {
      // Log the error if something goes wrong
      logger.error(`Error fetching events: ${error.message}`);
      return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
  }

  static async getEventbyID(req, res) {
    const eventId = req.params.id; // Extract the event ID from the URL parameter

    try {
      // Fetch the event by its primary key (ID)
      const event = await Event.findByPk(eventId);
      
      // Check if the event was found
      if (!event) {
        return res.status(404).json({
          resultKey: false,
          message: 'Event not found',
          resultCode: 404
        });
      }
  
      // Log the successful retrieval of the event
      logger.info(`Event retrieved successfully: ${event.name}`);
  
 
      // Return the event details in the response
      return res.status(200).json({
        resultKey: true,
        message: 'Event fetched ',
        resultCode: 200,
        event // Return the event details
      });
    } catch (error) {
      // Log the error if something goes wrong
      logger.error(`Error getting event by ID: ${error.message}`, {
        stack: error.stack,
      });
      return res.status(500).json({
        resultKey: false,
        message: 'Server error',
        resultCode: 500,
        error: error.message
      });
    }
  }
  

  
}

module.exports = EventController;
