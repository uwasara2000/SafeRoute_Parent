/**
 * Firebase Cloud Messaging (FCM) Service skeleton
 * Handles operator push notifications and emergency broadcast alerts.
 */
export const fcmService = {
  isSupported(): boolean {
    return typeof window !== 'undefined' && 'Notification' in window;
  },
};

export default fcmService;

