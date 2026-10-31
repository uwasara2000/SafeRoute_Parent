const { firebaseRest } = require('../config/firebase');

// In-memory data store for trips & events
const trips = {
  trip_001: {
    tripId: 'trip_001',
    routeId: 'route_colombo_01',
    routeName: 'Route #12 - Colombo North to Gateway College',
    active: true,
    driver: {
      driverId: 'driver_john',
      name: 'John Doe',
      phone: '+94 77 123 4567',
      licenseNo: 'B1234567'
    },
    vehicle: {
      vehicleId: 'bus_NA_1234',
      plateNumber: 'WP NA-1234',
      model: 'Ashok Leyland 32-Seater',
      capacity: 32
    },
    destination: {
      name: 'Gateway College, Rajagiriya',
      latitude: 6.9080,
      longitude: 79.8970
    },
    stops: [
      { id: 'stop_1', name: 'Wattala Junction', latitude: 6.9890, longitude: 79.8910, order: 1 },
      { id: 'stop_2', name: 'Kelaniya Temple Road', latitude: 6.9530, longitude: 79.9160, order: 2 },
      { id: 'stop_3', name: 'Borella Junction', latitude: 6.9140, longitude: 79.8770, order: 3 },
      { id: 'stop_4', name: 'Gateway College', latitude: 6.9080, longitude: 79.8970, order: 4 }
    ],
    events: [
      { id: 'evt_1', type: 'TRIP_STARTED', title: 'Trip Started', timestamp: new Date(Date.now() - 35 * 60000).toISOString(), description: 'Driver John Doe initiated morning trip' },
      { id: 'evt_2', type: 'CHILD_BOARDED', title: 'Child Boarded', timestamp: new Date(Date.now() - 25 * 60000).toISOString(), description: 'Your child boarded at Wattala Junction' },
      { id: 'evt_3', type: 'STOP_PASSED', title: 'Passed Kelaniya', timestamp: new Date(Date.now() - 10 * 60000).toISOString(), description: 'Bus departed stop #2 on schedule' }
    ]
  }
};

class TripService {
  /**
   * Fetch trip details
   */
  async getTrip(tripId) {
    const trip = trips[tripId];
    if (!trip) return null;

    try {
      const activeState = await firebaseRest.get(`liveTrips/${tripId}/active`);
      if (typeof activeState === 'boolean') {
        trip.active = activeState;
      }
    } catch (e) {
      // Use local state if network is momentarily unavailable
    }

    return trip;
  }

  /**
   * Fetch live location from Firebase Realtime Database
   */
  async getLatestLocation(tripId) {
    try {
      return await firebaseRest.get(`liveTrips/${tripId}/location`);
    } catch (error) {
      console.error('Error fetching live location from Firebase:', error.message);
      return null;
    }
  }

  /**
   * Update location from Driver App and write directly to Firebase
   */
  async updateLocation(tripId, locationData) {
    const { latitude, longitude, heading, speedMps, accuracyM } = locationData;

    const payload = {
      latitude: Number(latitude),
      longitude: Number(longitude),
      heading: heading !== undefined ? Number(heading) : 0,
      speedMps: speedMps !== undefined ? Number(speedMps) : 0,
      accuracyM: accuracyM !== undefined ? Number(accuracyM) : 0,
      updatedAt: Date.now()
    };

    // Update Firebase Realtime Database at liveTrips/:tripId/location
    await firebaseRest.set(`liveTrips/${tripId}/location`, payload);
    return payload;
  }

  /**
   * Start a trip (Driver)
   */
  async startTrip(tripId) {
    if (trips[tripId]) {
      trips[tripId].active = true;
    }
    await firebaseRest.set(`liveTrips/${tripId}/active`, true);

    const startEvent = {
      id: `evt_${Date.now()}`,
      type: 'TRIP_STARTED',
      title: 'Trip Started',
      timestamp: new Date().toISOString(),
      description: 'Trip started by driver.'
    };

    if (trips[tripId]) {
      trips[tripId].events.push(startEvent);
    }
    return { success: true, tripId, active: true };
  }

  /**
   * End a trip (Driver)
   */
  async endTrip(tripId) {
    if (trips[tripId]) {
      trips[tripId].active = false;
    }
    await firebaseRest.set(`liveTrips/${tripId}/active`, false);

    const endEvent = {
      id: `evt_${Date.now()}`,
      type: 'TRIP_ENDED',
      title: 'Trip Ended',
      timestamp: new Date().toISOString(),
      description: 'Trip concluded at school destination.'
    };

    if (trips[tripId]) {
      trips[tripId].events.push(endEvent);
    }
    return { success: true, tripId, active: false };
  }

  /**
   * Get timeline events for Parent App
   */
  async getEvents(tripId) {
    const trip = trips[tripId];
    return trip ? trip.events : [];
  }
}

module.exports = new TripService();
