const tripService = require('../services/tripService');
const etaService = require('../services/etaService');

function isValidStop(stop) {
  if (!stop || typeof stop !== 'object' || Array.isArray(stop)) return false;
  const { name, latitude, longitude } = stop;
  return typeof name === 'string'
    && name.trim().length > 0
    && typeof latitude === 'number'
    && Number.isFinite(latitude)
    && latitude >= -90
    && latitude <= 90
    && typeof longitude === 'number'
    && Number.isFinite(longitude)
    && longitude >= -180
    && longitude <= 180;
}

function hasValidCoordinates(location) {
  if (!location || typeof location !== 'object' || Array.isArray(location)) {
    return false;
  }
  const { latitude, longitude } = location;
  return typeof latitude === 'number'
    && Number.isFinite(latitude)
    && latitude >= -90
    && latitude <= 90
    && typeof longitude === 'number'
    && Number.isFinite(longitude)
    && longitude >= -180
    && longitude <= 180;
}

class ParentController {
  /**
   * GET /api/parent/trips/:tripId
   */
  async getTripDetails(req, res) {
    try {
      const { tripId } = req.params;
      const trip = await tripService.getTrip(tripId);

      if (!trip) {
        return res.status(404).json({ error: 'Trip not found' });
      }

      res.json({
        tripId: trip.tripId,
        routeId: trip.routeId,
        routeName: trip.routeName,
        active: trip.active,
        driver: trip.driver,
        vehicle: trip.vehicle,
        destination: trip.destination,
        stops: trip.stops
      });
    } catch (error) {
      console.error('getTripDetails error:', error);
      res.status(500).json({ error: 'Failed to retrieve trip details' });
    }
  }

  /**
   * GET /api/parent/trips/:tripId/location
   */
  async getLatestLocation(req, res) {
    try {
      const { tripId } = req.params;
      const location = await tripService.getLatestLocation(tripId);

      if (!location) {
        return res.status(404).json({ error: 'No live location available for this trip' });
      }
      if (!hasValidCoordinates(location)) {
        return res.status(502).json({ error: 'The live location contains invalid coordinates' });
      }

      res.json({
        tripId,
        location
      });
    } catch (error) {
      console.error('getLatestLocation error:', error);
      res.status(500).json({ error: 'Failed to retrieve location' });
    }
  }

  /**
   * GET /api/parent/trips/:tripId/eta
   */
  async getETA(req, res) {
    try {
      const { tripId } = req.params;
      const trip = await tripService.getTrip(tripId);

      if (!trip) {
        return res.status(404).json({ error: 'Trip not found' });
      }

      const currentLocation = await tripService.getLatestLocation(tripId);

      if (!currentLocation) {
        return res.status(400).json({ error: 'Bus location not available to calculate ETA' });
      }
      if (!hasValidCoordinates(currentLocation)) {
        return res.status(502).json({ error: 'The live location contains invalid coordinates' });
      }

      const etaData = await etaService.calculateETA(
        { latitude: currentLocation.latitude, longitude: currentLocation.longitude },
        trip.destination
      );

      res.json({
        tripId,
        destination: trip.destination.name,
        ...etaData
      });
    } catch (error) {
      console.error('getETA error:', error);
      res.status(500).json({ error: 'Failed to compute ETA' });
    }
  }

  /**
   * GET /api/parent/trips/:tripId/events
   */
  async getEvents(req, res) {
    try {
      const { tripId } = req.params;
      const events = await tripService.getEvents(tripId);
      if (!events) {
        return res.status(404).json({ error: 'Trip not found' });
      }
      res.json({ tripId, events });
    } catch (error) {
      console.error('getEvents error:', error);
      res.status(500).json({ error: 'Failed to fetch timeline events' });
    }
  }

  /**
   * PUT /api/parent/trips/:tripId/stops
   */
  async updateStops(req, res) {
    try {
      const { tripId } = req.params;
      if (!req.body || typeof req.body !== 'object' || Array.isArray(req.body)) {
        return res.status(400).json({ error: 'A valid JSON request body is required' });
      }
      const { pickup, destination } = req.body;

      if ((!pickup && !destination)
        || (pickup !== undefined && !isValidStop(pickup))
        || (destination !== undefined && !isValidStop(destination))) {
        return res.status(400).json({
          error: 'Provide a pickup or destination with a name and valid coordinates'
        });
      }

      const updatedTrip = await tripService.updateTripStops(tripId, { pickup, destination });
      if (!updatedTrip) {
        return res.status(404).json({ error: 'Trip not found' });
      }

      res.json({
        message: 'Pickup and drop-off updated successfully',
        trip: updatedTrip
      });
    } catch (error) {
      console.error('updateStops error:', error);
      res.status(500).json({ error: 'Failed to update stops' });
    }
  }
}

module.exports = new ParentController();
