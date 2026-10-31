const express = require('express');
const router = express.Router();
const parentController = require('../controllers/parentController');

// Trip overview, driver, and vehicle details
router.get('/trips/:tripId', (req, res) => parentController.getTripDetails(req, res));

// Latest location fallback (if polling or non-socket connection)
router.get('/trips/:tripId/location', (req, res) => parentController.getLatestLocation(req, res));

// Live calculated ETA to child's destination/stop
router.get('/trips/:tripId/eta', (req, res) => parentController.getETA(req, res));

// Boarding, drop-off, and stop timeline events
router.get('/trips/:tripId/events', (req, res) => parentController.getEvents(req, res));

module.exports = router;

