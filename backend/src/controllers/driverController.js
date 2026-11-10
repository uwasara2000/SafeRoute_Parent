const tripService = require('../services/tripService');

class DriverController {
  _isValidCoordinate(latitude, longitude) {
    return typeof latitude === 'number'
      && Number.isFinite(latitude)
      && typeof longitude === 'number'
      && Number.isFinite(longitude)
      && latitude >= -90
      && latitude <= 90
      && longitude >= -180
      && longitude <= 180;
  }

  /**
   * POST /api/driver/trips/:tripId/start
   */
  async startTrip(req, res) {
    try {
      const { tripId } = req.params;
      const result = await tripService.startTrip(tripId);
      if (!result) {
        return res.status(404).json({ error: 'Trip not found' });
      }
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
      if (!req.body || typeof req.body !== 'object' || Array.isArray(req.body)) {
        return res.status(400).json({ error: 'A valid JSON request body is required' });
      }
      const { latitude, longitude, heading, speedMps, accuracyM } = req.body;

      if (!this._isValidCoordinate(latitude, longitude)) {
        return res.status(400).json({ error: 'Valid latitude and longitude are required' });
      }
      if (
        (heading !== undefined
          && (typeof heading !== 'number' || !Number.isFinite(heading) || heading < 0 || heading >= 360))
        || (speedMps !== undefined
          && (typeof speedMps !== 'number' || !Number.isFinite(speedMps) || speedMps < 0))
        || (accuracyM !== undefined
          && (typeof accuracyM !== 'number' || !Number.isFinite(accuracyM) || accuracyM < 0))
      ) {
        return res.status(400).json({ error: 'GPS metadata contains invalid values' });
      }

      const location = await tripService.updateLocation(tripId, {
        latitude,
        longitude,
        heading,
        speedMps,
        accuracyM
      });
      if (!location) {
        return res.status(404).json({ error: 'Trip not found' });
      }

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
      if (!result) {
        return res.status(404).json({ error: 'Trip not found' });
      }
      res.json({ message: 'Trip ended successfully', ...result });
    } catch (error) {
      console.error('endTrip error:', error);
      res.status(500).json({ error: 'Failed to end trip' });
    }
  }
}

module.exports = new DriverController();
