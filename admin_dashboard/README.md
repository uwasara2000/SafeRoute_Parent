# SafeRoute – Transport Operator Admin Dashboard

The web management portal for SafeRoute School Bus Child Tracking System, designed for transport operators to manage fleets, routes, drivers, attendants, students, and live tracking.

## Technology Stack
- **Framework:** React 18 + Vite + TypeScript
- **Styling:** Tailwind CSS + shadcn/ui design tokens
- **Icons:** Lucide React
- **Routing:** React Router DOM v6
- **Forms & Validation:** React Hook Form + Zod
- **Data & Charts:** Recharts
- **Mapping:** Google Maps JavaScript API
- **Backend & Realtime:** Firebase JavaScript SDK v10 (Authentication, Cloud Firestore, Realtime Database, Cloud Messaging)

## Getting Started

### 1. Installation
Install the dependencies inside the `admin_dashboard` folder:
```bash
npm install
```

### 2. Environment Variables
Copy `.env.example` to `.env` and verify your Firebase project credentials:
```bash
cp .env.example .env
```

### 3. Run Development Server
```bash
npm run dev
```
The dashboard will run at `http://localhost:3000`.

### 4. Build for Production
```bash
npm run build
```

## Folder Structure
```text
admin_dashboard/
  public/            # Public static assets
  src/
    assets/          # Project images & assets
    components/
      common/        # Shared components
      layout/        # Navbar, Sidebar, DashboardLayout
      ui/            # shadcn/ui atomic components
    pages/           # Route views (dashboard, monitoring, buses, routes, etc.)
    hooks/           # Custom React hooks
    services/        # Firebase, Auth, Firestore, Realtime DB, Notifications
    types/           # TypeScript interfaces & types
    schemas/         # Zod schemas for forms
    utils/           # Helper functions & cn()
    routes/          # React Router configuration
    contexts/        # React contexts
    App.tsx          # App entry component
    main.tsx         # DOM mount point
```

