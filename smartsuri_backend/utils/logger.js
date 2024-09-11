const fs = require('fs')
const path = require('path')
const winston = require('winston')

function getLogger(filePath) {
  // Get current date in YYYY-MM-DD format
  const currentDate = new Date().toISOString().slice(0, 10)

  // Get the base directory for logs
  const logBaseDir = path.join(__dirname, '../public/logs')

  // Define the date directory
  const dateDir = path.join(logBaseDir, currentDate)

  // Extract the folder name from the file path
  const folderName = path.basename(path.dirname(filePath))

  // Define the log directory within the date directory
  const logDir = path.join(dateDir, folderName)

  // Create the date directory if it doesn't exist
  try {
    if (!fs.existsSync(dateDir)) {
      fs.mkdirSync(dateDir, { recursive: true })
    } else {
    }

    // Create the log directory within the date directory if it doesn't exist
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true })
    } else {
    }
  } catch (err) {
    // console.error('Error creating log directory:', err);
  }

  const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
      winston.format.timestamp(),
      winston.format.printf(({ timestamp, level, message, ...meta }) => {
        return `${timestamp} [${level}] ${message} ${Object.keys(meta).length ? JSON.stringify(meta, null, 2) : ''}`
      }),
    ),
    transports: [
      new winston.transports.File({
        filename: path.join(logDir, `${path.basename(filePath)}.txt`),
        level: 'info',
      }),
      new winston.transports.Console({
        format: winston.format.simple(),
        level: 'debug',
      }),
    ],
  })

  return logger
}

module.exports = getLogger
