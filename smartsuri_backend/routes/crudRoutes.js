const express = require('express')
const router = express.Router()
// const logger = require('../utils/logger'); // Adjust the path to your logger

const userRoutes = require('./userRoutes')
const accessRoutes = require('./accessRoutes')
const companyRoutes = require('./companyRoutes')
const profInfoRoutes = require('./projInfoRoutes')
const projTypeRoutes = require('./projTypeRoutes')
const roleRoutes = require('./roleRoutes')
const siteRoutes = require('./siteRoutes')

router.use('/user', userRoutes)
router.use('/access', accessRoutes)
router.use('/company', companyRoutes)
router.use('/projInfo', profInfoRoutes)
router.use('/projType', projTypeRoutes)
router.use('/role', roleRoutes)
router.use('/site', siteRoutes)

// // Error handling middleware
// router.use((err, req, res, next) => {
//     logger.error(`Error occurred in ${req.method} ${req.originalUrl}: ${err.message}`, { stack: err.stack });
//     res.status(500).json({ message: 'Internal Server Error' });
//   });

module.exports = router
