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

### 1. Configure Firebase and run the backend API

The parent and driver APIs require Firebase Admin credentials. Create a service-account JSON file in a secure location outside the repository, then set `GOOGLE_APPLICATION_CREDENTIALS` to its absolute path. Do not commit the service-account file.

Copy `backend/.env.example` to `backend/.env` and set `FIREBASE_DATABASE_URL`, `GOOGLE_APPLICATION_CREDENTIALS`, and (if used) `GOOGLE_MAPS_API_KEY`. The backend uses the Admin SDK for authenticated API requests and Realtime Database reads/writes. Without valid Admin credentials, `/health` remains available but protected API routes return `503`.

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

- Server URL: `http://localhost:5000`
- Health check: `http://localhost:5000/health`

Parent API requests require a Firebase ID token and a child record in `children` whose `parentId` matches the signed-in user's UID. Supported route values currently map route `08`, `14`, and `12` to `route_08`, `route_14`, and `trip_001`.

Driver API requests additionally require Firebase custom claims (`role: "driver"` or `driver: true`, plus `driverId` matching the assigned trip's driver ID). Configure those claims only for authorized driver accounts; a driver cannot update another driver's trips.

### 2. Run the Flutter Frontend App

The app obtains Firebase ID tokens automatically for API calls. For web, the default API URL is `http://localhost:5000`; Android emulators use `http://10.0.2.2:5000`. For a physical device or a different server, provide the backend URL when launching the app:

```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://<backend-host>:5000
```

