/**
 * Shared Type Definitions for SafeRoute Transport Operator Admin Dashboard
 */

export type UserRole = 'operator_admin' | 'dispatcher' | 'supervisor';

export interface OperatorProfile {
  id: string;
  email: string;
  displayName: string;
  companyName: string;
  role: UserRole;
  phone?: string;
  createdAt?: string;
}

export interface Student {
  id: string;
  name: string;
  school: string;
  grade: string;
  parentId: string;
  parentName?: string;
  emergencyContact?: string;
  pickupLocation: string;
  dropOffLocation: string;
  assignedRouteId?: string;
  assignedBusId?: string;
  status: 'on_board' | 'dropped_off' | 'not_boarded' | 'absent';
}

export interface Driver {
  id: string;
  name: string;
  licenseNumber: string;
  phone: string;
  assignedBusId?: string;
  status: 'active' | 'on_duty' | 'off_duty';
}

export interface Bus {
  id: string;
  vehicleNumber: string;
  model: string;
  capacity: number;
  driverId?: string;
  attendantId?: string;
  currentRouteId?: string;
  status: 'in_service' | 'maintenance' | 'idle';
}

export interface Route {
  id: string;
  name: string;
  code: string;
  school: string;
  stopsCount: number;
  startLocation: string;
  endLocation: string;
}

