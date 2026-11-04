import { initializeApp, getApps, getApp, type FirebaseApp } from 'firebase/app';
import { getAuth, type Auth } from 'firebase/auth';
import { getFirestore, type Firestore } from 'firebase/firestore';
import { getDatabase, type Database } from 'firebase/database';

export interface FirebaseConfig {
  apiKey: string;
  authDomain: string;
  projectId: string;
  storageBucket: string;
  messagingSenderId: string;
  appId: string;
  databaseURL?: string;
  measurementId?: string;
}

export const firebaseConfig: FirebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || '',
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || '',
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || 'track-my-kid-dae5b',
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || '',
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || '',
  appId: import.meta.env.VITE_FIREBASE_APP_ID || '',
  databaseURL: import.meta.env.VITE_FIREBASE_DATABASE_URL || 'https://track-my-kid-dae5b-default-rtdb.firebaseio.com',
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID || undefined,
};

// Initialize Firebase singleton
export const app: FirebaseApp = !getApps().length
  ? initializeApp(firebaseConfig)
  : getApp();

// Firebase Services instances
export const auth: Auth = getAuth(app);
export const db: Firestore = getFirestore(app);
export const realtimeDb: Database = getDatabase(app);

export default app;

