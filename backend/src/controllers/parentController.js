const tripService = require('../services/tripService');
const etaService = require('../services/etaService');

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
      res.json({ tripId, events });
    } catch (error) {
      console.error('getEvents error:', error);
      res.status(500).json({ error: 'Failed to fetch timeline events' });
    }
  }
}

module.exports = new ParentController();

