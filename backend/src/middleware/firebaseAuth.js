const { admin, hasAdminAuth } = require('../config/firebase');
const tripService = require('../services/tripService');

function requireFirebaseAuth(req, res, next) {
  if (!hasAdminAuth) {
    return res.status(503).json({ error: 'Authentication service is unavailable' });
  }

  const authorization = req.get('authorization') || '';
  const match = authorization.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  admin.auth().verifyIdToken(match[1])
    .then((decodedToken) => {
      req.user = decodedToken;
      next();
    })
    .catch((error) => {
      console.warn('Firebase token verification failed:', error.code || 'unknown');
      res.status(401).json({ error: 'Invalid or expired session' });
    });
}

function requireDriverRole(req, res, next) {
  if (
    (req.user?.role !== 'driver' && req.user?.driver !== true)
    || typeof req.user?.driverId !== 'string'
    || req.user.driverId.trim().length === 0
  ) {
    return res.status(403).json({ error: 'Authorized driver identity required' });
  }
  next();
}

async function requireDriverTripAccess(req, res, next) {
  try {
    const trip = await tripService.getTrip(req.params.tripId);
    if (!trip) {
      return res.status(404).json({ error: 'Trip not found' });
    }
    if (!trip.driver || trip.driver.driverId !== req.user.driverId) {
      return res.status(403).json({ error: 'You are not assigned to this trip' });
    }
    next();
  } catch (error) {
    console.error('Driver trip access check failed:', error.code || error.message);
    res.status(500).json({ error: 'Unable to verify trip access' });
  }
}

function tripIdsForChild(child) {
  const tripIds = new Set([child.tripId, child.routeId].filter(Boolean));
  const routeNumber = String(child.route || '').match(/\d+/)?.[0];

  if (routeNumber === '08' || routeNumber === '8') tripIds.add('route_08');
  if (routeNumber === '14') tripIds.add('route_14');
  if (routeNumber === '12') tripIds.add('trip_001');

  return tripIds;
}

async function requireParentTripAccess(req, res, next) {
  try {
    const children = await admin.firestore()
      .collection('children')
      .where('parentId', '==', req.user.uid)
      .get();
    const hasAccess = children.docs.some((child) =>
      tripIdsForChild(child.data()).has(req.params.tripId));

    if (!hasAccess) {
      return res.status(403).json({ error: 'You do not have access to this trip' });
    }

    next();
  } catch (error) {
    console.error('Parent trip access check failed:', error.code || error.message);
    res.status(500).json({ error: 'Unable to verify trip access' });
  }
}

module.exports = {
  requireFirebaseAuth,
  requireDriverRole,
  requireDriverTripAccess,
  requireParentTripAccess
};
