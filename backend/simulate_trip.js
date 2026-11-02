const axios = require('axios');
require('dotenv').config();

const DATABASE_URL = process.env.FIREBASE_DATABASE_URL || 'https://track-my-kid-dae5b-default-rtdb.firebaseio.com';

// 1. Route 08: Nawala -> Narahenpita -> Torrington -> Royal College, Colombo 07 (Amaya Silva)
const route08Waypoints = [
  { lat: 6.8960, lng: 79.8870, name: 'Nawala Road stop (Pickup)' },
  { lat: 6.8975, lng: 79.8825, name: 'Nawala Bridge' },
  { lat: 6.8990, lng: 79.8780, name: 'Narahenpita Junction' },
  { lat: 6.9005, lng: 79.8730, name: 'Independence Avenue' },
  { lat: 6.9020, lng: 79.8680, name: 'Torrington Square' },
  { lat: 6.9035, lng: 79.8650, name: 'Reid Avenue' },
  { lat: 6.9044, lng: 79.8622, name: 'Royal College, Colombo 07 (Destination)' }
];

// 2. Route 14: Rajagiriya -> Cotta Road -> Borella -> Maradana -> Ananda College (Dineth Silva)
const route14Waypoints = [
  { lat: 6.9110, lng: 79.8890, name: 'Rajagiriya Junction stop (Pickup)' },
  { lat: 6.9125, lng: 79.8845, name: 'Cotta Road East' },
  { lat: 6.9140, lng: 79.8800, name: 'Cotta Road Mid' },
  { lat: 6.9160, lng: 79.8750, name: 'Borella Roundabout' },
  { lat: 6.9230, lng: 79.8730, name: 'Dean\'s Road' },
  { lat: 6.9270, lng: 79.8715, name: 'Maradana Road' },
  { lat: 6.9298, lng: 79.8705, name: 'Ananda College, Colombo 10 (Destination)' }
];

// 3. Route #12 / trip_001: Wattala -> Kelaniya -> Borella -> Gateway College
const trip001Waypoints = [
  { lat: 6.9890, lng: 79.8910, name: 'Wattala Junction (Pickup)' },
  { lat: 6.9810, lng: 79.8930, name: 'Negombo Road South' },
  { lat: 6.9730, lng: 79.8970, name: 'Approaching Peliyagoda' },
  { lat: 6.9650, lng: 79.9050, name: 'Peliyagoda Interchange' },
  { lat: 6.9580, lng: 79.9110, name: 'Kandy Road' },
  { lat: 6.9530, lng: 79.9160, name: 'Kelaniya Temple Road (Stop #2)' },
  { lat: 6.9450, lng: 79.9100, name: 'Passing Kelani Bridge' },
  { lat: 6.9370, lng: 79.9000, name: 'Baseline Road North' },
  { lat: 6.9290, lng: 79.8900, name: 'Dematagoda Overpass' },
  { lat: 6.9210, lng: 79.8820, name: 'Baseline Road Mid' },
  { lat: 6.9140, lng: 79.8770, name: 'Borella Junction (Stop #3)' },
  { lat: 6.9125, lng: 79.8830, name: 'Cotta Road East' },
  { lat: 6.9110, lng: 79.8890, name: 'Rajagiriya Flyover' },
  { lat: 6.9095, lng: 79.8940, name: 'Parliament Road Approach' },
  { lat: 6.9080, lng: 79.8970, name: 'Gateway College, Rajagiriya (Destination)' }
];

// Calculate compass bearing
function calculateBearing(startLat, startLng, destLat, destLng) {
  const startLatRad = (startLat * Math.PI) / 180;
  const startLngRad = (startLng * Math.PI) / 180;
  const destLatRad = (destLat * Math.PI) / 180;
  const destLngRad = (destLng * Math.PI) / 180;

  const y = Math.sin(destLngRad - startLngRad) * Math.cos(destLatRad);
  const x =
    Math.cos(startLatRad) * Math.sin(destLatRad) -
    Math.sin(startLatRad) * Math.cos(destLatRad) * Math.cos(destLngRad - startLngRad);

  let brng = (Math.atan2(y, x) * 180) / Math.PI;
  return (brng + 360) % 360;
}

const simulators = [
  { id: 'route_08', name: 'Route 08 (Amaya - Royal College)', waypoints: route08Waypoints, index: 0 },
  { id: 'route_14', name: 'Route 14 (Dineth - Ananda College)', waypoints: route14Waypoints, index: 0 },
  { id: 'trip_001', name: 'Route #12 (Wattala - Gateway)', waypoints: trip001Waypoints, index: 0 }
];

async function updateRouteGps(sim) {
  const current = sim.waypoints[sim.index];
  const next = sim.waypoints[(sim.index + 1) % sim.waypoints.length];
  const heading = Math.round(calculateBearing(current.lat, current.lng, next.lat, next.lng));
  const speedMps = (7.0 + Math.random() * 4.0).toFixed(1);

  const payload = {
    latitude: current.lat,
    longitude: current.lng,
    heading: heading,
    speedMps: parseFloat(speedMps),
    accuracyM: 5.0,
    updatedAt: Date.now()
  };

  try {
    const url = `${DATABASE_URL}/liveTrips/${sim.id}/location.json`;
    await axios.put(url, payload, { timeout: 4000 });
    const timeStr = new Date().toLocaleTimeString();
    console.log(`[${timeStr}] 🚌 ${sim.id} -> ${current.name} | Lat: ${current.lat}, Lng: ${current.lng} | ${(speedMps * 3.6).toFixed(0)} km/h`);
  } catch (error) {
    console.error(`❌ ${sim.id} update failed:`, error.message);
  }

  sim.index = (sim.index + 1) % sim.waypoints.length;
}

async function runSimulations() {
  for (const sim of simulators) {
    await updateRouteGps(sim);
  }
}

console.log('====================================================');
console.log('🚀 Multi-Route School Bus GPS Simulator Started');
console.log('📡 Streaming routes: route_08, route_14, trip_001');
console.log('====================================================');

runSimulations();
setInterval(runSimulations, 3500);
