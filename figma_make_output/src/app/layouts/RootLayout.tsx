import { Outlet } from "react-router";
import { Navigation } from "../components/Navigation";
import { Sidebar } from "../components/Sidebar";
import { Footer } from "../components/Footer";

export default function RootLayout() {
  return (
    <div className="min-h-screen flex flex-col">
      <Navigation />
      <div className="flex flex-1">
        <Sidebar />
        <main className="flex-1 p-6 overflow-y-auto">
          <div className="max-w-[1600px] mx-auto">
            <Outlet />
          </div>
        </main>
      </div>
      <Footer />
    </div>
  );
}
