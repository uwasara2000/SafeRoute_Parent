import { createBrowserRouter, Navigate } from 'react-router-dom';
import DashboardLayout from '@/components/layout/DashboardLayout';
import DashboardPage from '@/pages/dashboard/DashboardPage';
import ParentsPage from '@/pages/parents/ParentsPage';
import StudentsPage from '@/pages/students/StudentsPage';
import DriversPage from '@/pages/drivers/DriversPage';
import AttendantsPage from '@/pages/attendants/AttendantsPage';
import BusesPage from '@/pages/buses/BusesPage';
import RoutesPage from '@/pages/routes/RoutesPage';
import AssignmentsPage from '@/pages/assignments/AssignmentsPage';
import JourneysPage from '@/pages/journeys/JourneysPage';
import MonitoringPage from '@/pages/monitoring/MonitoringPage';
import NotificationsPage from '@/pages/notifications/NotificationsPage';
import EmergenciesPage from '@/pages/emergencies/EmergenciesPage';
import PaymentsPage from '@/pages/payments/PaymentsPage';
import SupportRequestsPage from '@/pages/support/SupportRequestsPage';
import StaffPermissionsPage from '@/pages/staff/StaffPermissionsPage';
import SettingsPage from '@/pages/settings/SettingsPage';
import AuditLogsPage from '@/pages/audit/AuditLogsPage';
import PlatformBlueprintPage from '@/pages/blueprint/PlatformBlueprintPage';
import LoginPage from '@/pages/auth/LoginPage';

export const router = createBrowserRouter([
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    path: '/',
    element: <DashboardLayout />,
    children: [
      { index: true, element: <DashboardPage /> },
      { path: 'parents', element: <ParentsPage /> },
      { path: 'students', element: <StudentsPage /> },
      { path: 'drivers', element: <DriversPage /> },
      { path: 'attendants', element: <AttendantsPage /> },
      { path: 'buses', element: <BusesPage /> },
      { path: 'routes', element: <RoutesPage /> },
      { path: 'assignments', element: <AssignmentsPage /> },
      { path: 'journeys', element: <JourneysPage /> },
      { path: 'monitoring', element: <MonitoringPage /> },
      { path: 'notifications', element: <NotificationsPage /> },
      { path: 'emergencies', element: <EmergenciesPage /> },
      { path: 'payments', element: <PaymentsPage /> },
      { path: 'support', element: <SupportRequestsPage /> },
      { path: 'staff', element: <StaffPermissionsPage /> },
      { path: 'settings', element: <SettingsPage /> },
      { path: 'audit', element: <AuditLogsPage /> },
      { path: 'blueprint', element: <PlatformBlueprintPage /> },
      { path: '*', element: <Navigate to="/" replace /> },
    ],
  },
]);

export default router;

