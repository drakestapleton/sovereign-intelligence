import { NavLink } from "react-router-dom";

const LINKS = [
  { to: "/", label: "Identity", end: true },
  { to: "/path", label: "Career", end: true },
  { to: "/software", label: "Orchestration", end: true },
  { to: "/works", label: "Works", end: false },
  { to: "/evidence", label: "Audit", end: true },
  { to: "/atlas", label: "Atlas", end: true },
  { to: "/aegis", label: "AEGIS", end: true },
  { to: "/aien", label: "AIEN", end: true },
  { to: "/research", label: "Research", end: true },
  { to: "/scholar", label: "Scholar", end: false },
  { to: "/interest", label: "Conversation", end: true },
];

export function SiteNav() {
  return (
    <header className="site-nav">
      <div className="site-nav-inner">
        <NavLink to="/" className="brand" end>
          <span className="brand-name">Drake Stapleton</span>
          <span className="brand-line">Freedom Fighter · AI Architect & Operator · AIENOS.com</span>
        </NavLink>
        <nav className="links" aria-label="Primary">
          {LINKS.map((l) => (
            <NavLink
              key={l.to}
              to={l.to}
              end={l.end}
              className={({ isActive }) => (isActive ? "active" : undefined)}
            >
              {l.label}
            </NavLink>
          ))}
        </nav>
      </div>
    </header>
  );
}
