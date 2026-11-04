import { db } from '../firebase/config';

/**
 * Cloud Firestore Service skeleton for Operators, Parents, Students, Routes, and Buses.
 * Ready for implementation based on your schema.
 */
export const firestoreService = {
  getFirestoreInstance() {
    return db;
  },
};

export default firestoreService;

