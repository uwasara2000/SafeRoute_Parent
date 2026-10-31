const axios = require('axios');
require('dotenv').config();

class ETAService {
  /**
   * Calculate ETA using Google Maps Routes API (or haversine fallback)
   */
  async calculateETA(origin, destination) {
    const apiKey = process.env.GOOGLE_MAPS_API_KEY;

    if (apiKey && apiKey !== 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
      try {
        const response = await axios.post(
          'https://routes.googleapis.com/directions/v2:computeRoutes',
          {
            origin: {
              location: {
                latLng: {
                  latitude: origin.latitude,
                  longitude: origin.longitude
                }
              }
            },
            destination: {
              location: {
                latLng: {
                  latitude: destination.latitude,
                  longitude: destination.longitude
                }
              }
            },
            travelMode: 'DRIVE',
            routingPreference: 'TRAFFIC_AWARE'
          },
          {
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': apiKey,
              'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
            },
            timeout: 5000
          }
        );

        const route = response.data.routes?.[0];
        if (route) {
          // duration is formatted as a string like "840s"
          const durationStr = route.duration || '0s';
          const etaSeconds = parseInt(durationStr.replace('s', ''), 10) || 0;
          const distanceMeters = route.distanceMeters || 0;

          return {
            etaSeconds,
            etaMinutes: Math.ceil(etaSeconds / 60),
            distanceMeters,
            distanceKm: (distanceMeters / 1000).toFixed(1),
            polyline: route.polyline?.encodedPolyline || null,
            calculatedAt: new Date().toISOString()
          };
        }
      } catch (err) {
        console.warn('Google Routes API request failed, falling back to approximation:', err.message);
      }
    }

    // Mathematical Haversine fallback if API is unreachable or not configured
    return this.fallbackEstimate(origin, destination);
  }

  /**
   * Great-circle distance & speed estimation fallback
   */
  fallbackEstimate(origin, destination) {
    const R = 6371; // Earth radius in km
    const dLat = this.deg2rad(destination.latitude - origin.latitude);
    const dLon = this.deg2rad(destination.longitude - origin.longitude);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.deg2rad(origin.latitude)) *
        Math.cos(this.deg2rad(destination.latitude)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distanceKm = R * c;

    // Assume average city bus speed: ~25 km/h with stops
    const avgSpeedKmh = 25;
    const hours = distanceKm / avgSpeedKmh;
    const etaSeconds = Math.round(hours * 3600);

    return {
      etaSeconds,
      etaMinutes: Math.max(1, Math.ceil(etaSeconds / 60)),
      distanceMeters: Math.round(distanceKm * 1000),
      distanceKm: distanceKm.toFixed(1),
      polyline: null,
      calculatedAt: new Date().toISOString(),
      isEstimate: true
    };
  }

  deg2rad(deg) {
    return deg * (Math.PI / 180);
  }
}

module.exports = new ETAService();

