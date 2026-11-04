import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Navbar from './Navbar';

export default function DashboardLayout() {
  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F4F6FB] antialiased select-none">
      {/* Fixed Left Sidebar */}
      <Sidebar />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 h-screen overflow-hidden">
        {/* Fixed Top Navbar */}
        <Navbar />

        {/* Scrollable Viewport (Vertical only, no horizontal shifting) */}
        <main className="flex-1 overflow-y-auto overflow-x-hidden bg-[#F4F6FB]">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
