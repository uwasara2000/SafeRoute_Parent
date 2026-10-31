const tripService = require('../services/tripService');

class DriverController {
  /**
   * POST /api/driver/trips/:tripId/start
   */
  async startTrip(req, res) {
    try {
      const { tripId } = req.params;
      const result = await tripService.startTrip(tripId);
      res.json({ message: 'Trip started successfully', ...result });
    } catch (error) {
      console.error('startTrip error:', error);
      res.status(500).json({ error: 'Failed to start trip' });
    }
  }

  /**
   * POST /api/driver/trips/:tripId/location
   * Accepts GPS updates from Driver phone and writes directly to Firebase Realtime Database
   */
  async updateLocation(req, res) {
    try {
      const { tripId } = req.params;
      const { latitude, longitude, heading, speedMps, accuracyM } = req.body;

      if (latitude === undefined || longitude === undefined) {
        return res.status(400).json({ error: 'latitude and longitude are required' });
      }

      const location = await tripService.updateLocation(tripId, {
        latitude,
        longitude,
        heading,
        speedMps,
        accuracyM
      });

      res.json({
        message: 'Location published to Firebase Realtime Database',
        tripId,
        location
      });
    } catch (error) {
      console.error('updateLocation error:', error);
      res.status(500).json({ error: 'Failed to update location in Firebase' });
    }
  }

  /**
   * POST /api/driver/trips/:tripId/end
   */
  async endTrip(req, res) {
    try {
      const { tripId } = req.params;
      const result = await tripService.endTrip(tripId);
      res.json({ message: 'Trip ended successfully', ...result });
    } catch (error) {
      console.error('endTrip error:', error);
      res.status(500).json({ error: 'Failed to end trip' });
    }
  }
}

module.exports = new DriverController();

