const axios = require('axios');
require('dotenv').config();

const DATABASE_URL = process.env.FIREBASE_DATABASE_URL || 'https://track-my-kid-dae5b-default-rtdb.firebaseio.com';
const TRIP_ID = 'trip_001';

// High-resolution GPS waypoints from Wattala -> Kelaniya -> Borella -> Gateway College, Rajagiriya
const waypoints = [
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

// Helper: Calculate compass bearing between two coordinates
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

let currentIndex = 0;

async function sendGpsUpdate() {
  const current = waypoints[currentIndex];
  const next = waypoints[(currentIndex + 1) % waypoints.length];
  const heading = Math.round(calculateBearing(current.lat, current.lng, next.lat, next.lng));
  const speedMps = (7.5 + Math.random() * 3.5).toFixed(1); // ~27 - 40 km/h

  const payload = {
    latitude: current.lat,
    longitude: current.lng,
    heading: heading,
    speedMps: parseFloat(speedMps),
    accuracyM: 5.0,
    updatedAt: Date.now()
  };

  try {
    const url = `${DATABASE_URL}/liveTrips/${TRIP_ID}/location.json`;
    await axios.put(url, payload, { timeout: 4000 });

    const timeStr = new Date().toLocaleTimeString();
    console.log(
      `[${timeStr}] 🚌 Step ${currentIndex + 1}/${waypoints.length} -> ${current.name} | Lat: ${current.lat}, Lng: ${current.lng} | Heading: ${heading}° | Speed: ${(speedMps * 3.6).toFixed(0)} km/h`
    );
  } catch (error) {
    console.error('❌ GPS Update failed:', error.message);
  }

  currentIndex = (currentIndex + 1) % waypoints.length;
}

console.log('====================================================');
console.log('🚀 School Bus GPS Stream Simulator Started');
console.log(`📡 Trip ID: ${TRIP_ID}`);
console.log(`🌐 Target:  ${DATABASE_URL}`);
console.log('📍 Route:    Wattala -> Kelaniya -> Borella -> Gateway College');
console.log('⏱️ Interval: Every 3.5 seconds');
console.log('====================================================\n');

// Set trip active
axios.put(`${DATABASE_URL}/liveTrips/${TRIP_ID}/active.json`, true).catch(() => {});

// Push initial coordinate immediately
sendGpsUpdate();

// Stream continuous updates every 3.5 seconds
setInterval(sendGpsUpdate, 3500);

