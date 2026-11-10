const { db, firebaseRest } = require('../config/firebase');

async function readFirebaseValue(path) {
  if (!db) return firebaseRest.get(path);
  const snapshot = await db.ref(path).once('value');
  return snapshot.val();
}

async function writeFirebaseValue(path, value) {
  if (!db) return firebaseRest.set(path, value);
  await db.ref(path).set(value);
  return value;
}

async function updateFirebaseValue(path, values) {
  if (!db) return firebaseRest.update(path, values);
  await db.ref(path).update(values);
  return values;
}

// Static route catalog; live status, stops, locations, and events are stored in Firebase.
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
    const trip = trips[tripId];
    if (!trip) return null;

    const [activeState, destination, stops] = await Promise.all([
      readFirebaseValue(`liveTrips/${tripId}/active`),
      readFirebaseValue(`liveTrips/${tripId}/destination`),
      readFirebaseValue(`liveTrips/${tripId}/stops`)
    ]);

    return {
      ...trip,
      active: activeState === true,
      destination: destination && typeof destination === 'object'
        ? destination
        : trip.destination,
      stops: Array.isArray(stops) ? stops : trip.stops
    };
  }

  /**
   * Fetch live location from Firebase Realtime Database
   */
  async getLatestLocation(tripId) {
    return readFirebaseValue(`liveTrips/${tripId}/location`);
  }

  /**
   * Update location from Driver App and write directly to Firebase
   */
  async updateLocation(tripId, locationData) {
    if (!trips[tripId]) return null;
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
    await writeFirebaseValue(`liveTrips/${tripId}/location`, payload);
    return payload;
  }

  /**
   * Start a trip (Driver)
   */
  async startTrip(tripId) {
    const trip = trips[tripId];
    if (!trip) return null;

    const startEvent = {
      id: `evt_${Date.now()}`,
      type: 'TRIP_STARTED',
      title: 'Trip Started',
      timestamp: new Date().toISOString(),
      description: 'Trip started by driver.'
    };

    await updateFirebaseValue(`liveTrips/${tripId}`, {
      active: true,
      [`events/${startEvent.id}`]: startEvent
    });
    trip.active = true;
    return { success: true, tripId, active: true };
  }

  /**
   * End a trip (Driver)
   */
  async endTrip(tripId) {
    const trip = trips[tripId];
    if (!trip) return null;

    const endEvent = {
      id: `evt_${Date.now()}`,
      type: 'TRIP_ENDED',
      title: 'Trip Ended',
      timestamp: new Date().toISOString(),
      description: 'Trip concluded at school destination.'
    };

    await updateFirebaseValue(`liveTrips/${tripId}`, {
      active: false,
      [`events/${endEvent.id}`]: endEvent
    });
    trip.active = false;
    return { success: true, tripId, active: false };
  }

  /**
   * Get timeline events for Parent App
   */
  async getEvents(tripId) {
    const trip = trips[tripId];
    if (!trip) return null;

    const storedEvents = await readFirebaseValue(`liveTrips/${tripId}/events`);
    if (Array.isArray(storedEvents)) return storedEvents;
    if (storedEvents && typeof storedEvents === 'object') {
      return Object.values(storedEvents);
    }
    return [];
  }

  /**
   * Update pickup or drop-off location for a trip
   */
  async updateTripStops(tripId, { pickup, destination }) {
    const trip = await this.getTrip(tripId);
    if (!trip) return null;
    const updatedTrip = {
      ...trip,
      destination: { ...trip.destination },
      stops: trip.stops.map((stop) => ({ ...stop }))
    };

    if (destination) {
      updatedTrip.destination = {
        name: destination.name.trim(),
        latitude: Number(destination.latitude),
        longitude: Number(destination.longitude)
      };
      const lastStopIndex = updatedTrip.stops.length - 1;
      if (lastStopIndex >= 0) {
        updatedTrip.stops[lastStopIndex] = {
          id: 'stop_destination',
          name: updatedTrip.destination.name,
          latitude: updatedTrip.destination.latitude,
          longitude: updatedTrip.destination.longitude,
          order: updatedTrip.stops.length
        };
      }
    }

    if (pickup) {
      if (updatedTrip.stops.length > 0) {
        updatedTrip.stops[0] = {
          id: 'stop_pickup',
          name: pickup.name.trim(),
          latitude: Number(pickup.latitude),
          longitude: Number(pickup.longitude),
          order: 1
        };
      }
    }

    await updateFirebaseValue(`liveTrips/${tripId}`, {
      destination: updatedTrip.destination,
      stops: updatedTrip.stops
    });

    trips[tripId] = updatedTrip;
    return updatedTrip;
  }
}

module.exports = new TripService();
