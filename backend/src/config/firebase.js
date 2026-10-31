const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
const axios = require('axios');
require('dotenv').config();

const databaseURL = process.env.FIREBASE_DATABASE_URL || 'https://track-my-kid-dae5b-default-rtdb.firebaseio.com';
const serviceAccountPath = path.join(__dirname, '../../serviceAccountKey.json');

let hasAdminAuth = false;

if (fs.existsSync(serviceAccountPath)) {
  try {
    const serviceAccount = require(serviceAccountPath);
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: databaseURL
      });
    }
    hasAdminAuth = true;
    console.log('✅ Firebase Admin initialized with serviceAccountKey.json');
  } catch (e) {
    console.warn('⚠️ Could not load serviceAccountKey.json, using REST client fallback.');
  }
}

/**
 * Universal Firebase Realtime Database REST client
 * Works seamlessly without needing gcloud CLI or local OAuth setup
 */
const firebaseRest = {
  async get(endpoint) {
    const cleanEndpoint = endpoint.startsWith('/') ? endpoint.slice(1) : endpoint;
    const url = `${databaseURL}/${cleanEndpoint}.json`;
    const res = await axios.get(url, { timeout: 5000 });
    return res.data;
  },

  async set(endpoint, data) {
    const cleanEndpoint = endpoint.startsWith('/') ? endpoint.slice(1) : endpoint;
    const url = `${databaseURL}/${cleanEndpoint}.json`;
    const res = await axios.put(url, data, { timeout: 5000 });
    return res.data;
  },

  async update(endpoint, data) {
    const cleanEndpoint = endpoint.startsWith('/') ? endpoint.slice(1) : endpoint;
    const url = `${databaseURL}/${cleanEndpoint}.json`;
    const res = await axios.patch(url, data, { timeout: 5000 });
    return res.data;
  }
};

module.exports = {
  admin,
  hasAdminAuth,
  db: hasAdminAuth ? admin.database() : null,
  firebaseRest
};
