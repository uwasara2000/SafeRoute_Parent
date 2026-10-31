const express = require('express');
const router = express.Router();
const driverController = require('../controllers/driverController');

// Driver starts trip (activates live tracking stream)
router.post('/trips/:tripId/start', (req, res) => driverController.startTrip(req, res));

// Driver streams GPS updates (pushes to Firebase Realtime Database)
router.post('/trips/:tripId/location', (req, res) => driverController.updateLocation(req, res));

// Driver concludes trip
router.post('/trips/:tripId/end', (req, res) => driverController.endTrip(req, res));

module.exports = router;

