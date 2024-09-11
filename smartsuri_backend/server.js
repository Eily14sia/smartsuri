const { Sequelize } = require('sequelize')
const dotenv = require('dotenv').config()
const getLogger = require('../smartsuri_backend/utils/logger')

const logger = getLogger(__filename)

// Create a new Sequelize instance
const sequelize = new Sequelize({
  database: process.env.DB_DATABASE,
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  dialect: process.env.DB_DIALECT,
})

// Test the connection
async function testConnection() {
  try {
    await sequelize.authenticate()
    logger.info('Connection has been established successfully.')
  } catch (error) {
    logger.error('Unable to connect to the database:', error)
  }
}

module.exports = { sequelize, testConnection }
