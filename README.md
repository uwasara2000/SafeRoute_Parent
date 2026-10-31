# School Bus Child Tracking System

Full-stack application for live school bus tracking with parent real-time map, ETA calculation, and driver GPS streaming.

## Project Structure

```text
parent_app/
├── frontend/             # Flutter Mobile App (Parent App)
│   ├── lib/
│   │   ├── features/tracking/  # Live Map, GPS models, Firebase listeners
│   │   ├── firebase_options.dart
│   │   └── main.dart
│   ├── android/          # Native Android configuration & Google Maps key
│   └── pubspec.yaml      # Flutter dependencies
│
└── backend/              # Node.js + Express API Server
    ├── src/
    │   ├── config/       # Firebase Realtime Database connection
    │   ├── controllers/  # Parent & Driver API controllers
    │   ├── routes/       # Express route handlers
    │   └── services/     # ETA calculation & Trip management
    ├── .env              # Environment configuration
    ├── package.json
    └── server.js         # Backend entrypoint (Port 5000)
```

## Quick Start

### 1. Run the Backend API
```bash
cd backend
npm run dev
```
- Server URL: `http://localhost:5000`
- Health check: `http://localhost:5000/health`
- Parent trip details: `http://localhost:5000/api/parent/trips/trip_001`
- Live ETA: `http://localhost:5000/api/parent/trips/trip_001/eta`

### 2. Run the Flutter Frontend App
In a second terminal:
```bash
cd frontend
flutter run
```
