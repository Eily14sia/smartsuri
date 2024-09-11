const express = require('express')
const cors = require('cors')
const bodyParser = require('body-parser')
const dotenv = require('dotenv').config()
const getLogger = require('../smartsuri_backend/utils/logger')

const logger = getLogger(__filename)

const app = express()

// Connect to the database
const { testConnection } = require('./server')

// Swagger setup
const { swaggerUi, specs } = require('./swagger')

// Routes
const authRoutes = require('./routes/authRoutes')
const crudRoutes = require('./routes/crudRoutes')
// const superAdminRoutes = require('./routes/superAdminRoutes')

testConnection()
  .then(() => {
    logger.info('Database connection tested successfully.')
  })
  .catch((error) => {
    logger.error('Error testing database connection:', error)
  })

// Middleware
app.use(express.json({ limit: '50mb' })) 
app.use(cors()) 
app.use(bodyParser.json({ limit: '10mb' })); 
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));

// Swagger UI route
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs))

// API routes
app.use('/api/auth', authRoutes)
app.use('/api/crud', crudRoutes)
// app.use('/api/superAdmin', superAdminRoutes)

// Start the server
const PORT = process.env.PORT 
const url = process.env.url 

app.listen(PORT, () => {
  logger.info(`App is running on port ${PORT}`)
  logger.info(`Swagger API docs are available at ${url}:${PORT}/api-docs`)
})
