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
  },
  route_08: {
    tripId: 'route_08',
    routeId: 'route_08',
    routeName: 'Route 08 - Nawala to Royal College',
    active: true,
    driver: {
      driverId: 'driver_sunil',
      name: 'Sunil Weerasinghe',
      phone: '+94 71 892 3411',
      licenseNo: 'B829103'
    },
    vehicle: {
      vehicleId: 'bus_NB_4821',
      plateNumber: 'NB-4821',
      model: 'Toyota Coaster 28-Seater',
      capacity: 28
    },
    destination: {
      name: 'Royal College, Colombo 07',
      latitude: 6.9044,
      longitude: 79.8622
    },
    stops: [
      { id: 'stop_1', name: 'Nawala Road stop', latitude: 6.8960, longitude: 79.8870, order: 1 },
      { id: 'stop_2', name: 'Narahenpita Junction', latitude: 6.8990, longitude: 79.8780, order: 2 },
      { id: 'stop_3', name: 'Torrington Square', latitude: 6.9020, longitude: 79.8680, order: 3 },
      { id: 'stop_4', name: 'Royal College main gate', latitude: 6.9044, longitude: 79.8622, order: 4 }
    ],
    events: [
      { id: 'evt_r8_1', type: 'TRIP_STARTED', title: 'Trip Started', timestamp: new Date(Date.now() - 20 * 60000).toISOString(), description: 'Driver Sunil Weerasinghe started morning route 08' },
      { id: 'evt_r8_2', type: 'CHILD_BOARDED', title: 'Child Boarded', timestamp: new Date(Date.now() - 12 * 60000).toISOString(), description: 'Amaya boarded at Nawala Road stop' }
    ]
  },
  route_14: {
    tripId: 'route_14',
    routeId: 'route_14',
    routeName: 'Route 14 - Rajagiriya to Ananda College',
    active: true,
    driver: {
      driverId: 'driver_gamini',
      name: 'Gamini Perera',
      phone: '+94 77 441 9022',
      licenseNo: 'B391048'
    },
    vehicle: {
      vehicleId: 'bus_WP_3156',
      plateNumber: 'WP-3156',
      model: 'Mitsubishi Rosa 30-Seater',
      capacity: 30
    },
    destination: {
      name: 'Ananda College, Colombo 10',
      latitude: 6.9298,
      longitude: 79.8705
    },
    stops: [
      { id: 'stop_1', name: 'Rajagiriya Junction stop', latitude: 6.9110, longitude: 79.8890, order: 1 },
      { id: 'stop_2', name: 'Cotta Road East', latitude: 6.9130, longitude: 79.8800, order: 2 },
      { id: 'stop_3', name: 'Borella Roundabout', latitude: 6.9160, longitude: 79.8750, order: 3 },
      { id: 'stop_4', name: 'Ananda College primary gate', latitude: 6.9298, longitude: 79.8705, order: 4 }
    ],
    events: [
      { id: 'evt_r14_1', type: 'TRIP_STARTED', title: 'Trip Started', timestamp: new Date(Date.now() - 15 * 60000).toISOString(), description: 'Driver Gamini started morning route 14' },
      { id: 'evt_r14_2', type: 'CHILD_BOARDED', title: 'Child Boarded', timestamp: new Date(Date.now() - 8 * 60000).toISOString(), description: 'Dineth boarded at Rajagiriya Junction' }
    ]
  }
};

class TripService {
  /**
   * Fetch trip details
   */
  async getTrip(tripId) {
    let trip = trips[tripId];
    if (!trip) {
      // Dynamic fallback for any child route
      trip = {
        tripId,
        routeId: tripId,
        routeName: `Route - ${tripId}`,
        active: true,
        driver: {
          driverId: 'driver_default',
          name: 'Sunil Weerasinghe',
          phone: '+94 71 892 3411',
          licenseNo: 'B829103'
        },
        vehicle: {
          vehicleId: `bus_${tripId}`,
          plateNumber: 'NB-4821',
          model: 'Toyota Coaster 28-Seater',
          capacity: 28
        },
        destination: {
          name: 'School Destination',
          latitude: 6.9044,
          longitude: 79.8622
        },
        stops: []
      };
    }

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

  /**
   * Update pickup or drop-off location for a trip
   */
  async updateTripStops(tripId, { pickup, destination }) {
    let trip = trips[tripId];
    if (!trip) {
      trip = await this.getTrip(tripId);
      trips[tripId] = trip;
    }

    if (destination) {
      trip.destination = {
        name: destination.name || trip.destination.name,
        latitude: Number(destination.latitude),
        longitude: Number(destination.longitude)
      };
      const lastStopIndex = trip.stops.length - 1;
      if (lastStopIndex >= 0) {
        trip.stops[lastStopIndex] = {
          id: 'stop_destination',
          name: trip.destination.name,
          latitude: trip.destination.latitude,
          longitude: trip.destination.longitude,
          order: trip.stops.length
        };
      }
    }

    if (pickup) {
      if (trip.stops.length > 0) {
        trip.stops[0] = {
          id: 'stop_pickup',
          name: pickup.name || trip.stops[0].name,
          latitude: Number(pickup.latitude),
          longitude: Number(pickup.longitude),
          order: 1
        };
      }
    }

    // Also sync to Firebase Realtime Database
    try {
      await firebaseRest.set(`liveTrips/${tripId}/destination`, trip.destination);
      await firebaseRest.set(`liveTrips/${tripId}/stops`, trip.stops);
    } catch (e) {
      console.warn('Firebase sync warning:', e.message);
    }

    return trip;
  }
}

module.exports = new TripService();
