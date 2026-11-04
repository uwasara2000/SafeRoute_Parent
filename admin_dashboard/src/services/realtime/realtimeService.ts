import { realtimeDb } from '../firebase/config';

/**
 * Firebase Realtime Database Service skeleton
 * Handles live GPS telemetry for buses and trips.
 */
export const realtimeService = {
  getDatabaseInstance() {
    return realtimeDb;
  },
};

export default realtimeService;

