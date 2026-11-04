import { auth } from '../firebase/config';
import type { User } from 'firebase/auth';

/**
 * Transport Operator Authentication Service skeleton
 * Ready for implementation once designs and auth rules are finalized.
 */
export const authService = {
  getCurrentUser(): User | null {
    return auth.currentUser;
  },
};

export default authService;

