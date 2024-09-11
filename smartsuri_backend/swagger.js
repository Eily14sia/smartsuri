const swaggerJsdoc = require('swagger-jsdoc')
const swaggerUi = require('swagger-ui-express')
const dotenv = require('dotenv').config()

const PORT = process.env.PORT 
const url = process.env.url

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Smartsuri API',
      version: '1.0.0',
      description: 'API Documentation for Smartsuri API',
    },
    servers: [
      {
        url:`${url}:${PORT}`, // Replace with your server URL
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ['./routes/*.js'], // Path to the API docs
}

const specs = swaggerJsdoc(options)

module.exports = { swaggerUi, specs }
