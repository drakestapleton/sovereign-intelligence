import { useEffect, useRef } from "react";
import { Outlet, useLocation } from "react-router-dom";
import { SiteNav } from "./SiteNav";
import { SiteFooter } from "./SiteFooter";

function RouteFocus() {
  const location = useLocation();
  const firstRender = useRef(true);

  useEffect(() => {
    if (firstRender.current) {
      firstRender.current = false;
      return;
    }
    window.scrollTo({ top: 0, left: 0, behavior: "auto" });
    document.querySelector<HTMLElement>("#main-content")?.focus();
  }, [location.pathname]);

  return null;
}

export function Layout() {
  return (
    <div className="site-shell">
      <RouteFocus />
      <a className="skip-link" href="#main-content">
        Skip to main content
      </a>
      <SiteNav />
      <div id="main-content" tabIndex={-1}>
        <Outlet />
      </div>
      <SiteFooter />
    </div>
  );
}
