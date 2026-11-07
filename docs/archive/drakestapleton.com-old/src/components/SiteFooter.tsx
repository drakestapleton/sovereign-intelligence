import { Link } from "react-router-dom";
import { HisWords } from "./VoiceMark";

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="site-footer-inner">
        <div className="site-footer-identity">
          <p className="site-footer-name">Drake Stapleton</p>
          <p className="site-footer-line">Freedom Fighter. AI Architect. Operator.</p>
          <p className="site-footer-line">Springfield, Missouri.</p>
          <p className="site-footer-line">
            <HisWords>His own words, spoken aloud.</HisWords> Everything else was
            drafted with AI and kept only with his approval.
          </p>
        </div>
        <nav className="site-footer-links" aria-label="Explore the site">
          <Link to="/">Life</Link>
          <Link to="/atlas">Atlas</Link>
          <Link to="/aegis">AEGIS</Link>
          <Link to="/interest">Conversation</Link>
        </nav>
      </div>
    </footer>
  );
}
