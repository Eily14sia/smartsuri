const { sequelize, Event, LogMaster } = require('../models/database');
const { UniqueConstraintError } = require('sequelize');
const dotenv = require('dotenv');
const getLogger = require('../utils/logger');

dotenv.config();
const logger = getLogger(__filename);

class EventController {
  static async createEvent(req, res) {
    const { name, date, location } = req.body;

    if (!name || !date || !location) {
      return res.status(400).json({ message: 'Event name, date, and location are required' });
    }

    try {
      // Create a new event record in the database
      const newEvent = await Event.create({
        name,
        date,
        location,
        isActive: true,
      });

      logger.info(`Event created: ${newEvent.name}`);
      return res.status(200).json({
        resultKey: true,
        message: 'Event created successfully',
        resultCode: 200,
        event: newEvent
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
      // Fetch all events from the database
      const events = await Event.findAll();

      // If no events are found, return a 404 status
      if (!events || events.length === 0) {
        return res.status(404).json({ message: 'No events found' });
      }

      // Log the event retrieval
      logger.info('Events retrieved successfully');
      return res.status(200).json({  resultKey: true,
        message: 'Event fetched successfully',
        resultCode: 200,
        events});
    } catch (error) {
      // Log the error if something goes wrong
      logger.error(`Error fetching events: ${error.message}`);
      return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
  }
}

module.exports = EventController;
