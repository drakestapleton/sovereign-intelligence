import { Link } from "react-router-dom";
import { usePageMeta } from "../lib/usePageMeta";

export function NotFoundPage() {
  usePageMeta("/404", "noindex, follow");
  return (
    <main className="wrap">
      <p className="kicker">404</p>
      <h1>Choose where to go next</h1>
      <p className="lede">
        Return to the <Link to="/">human story</Link>, explore <Link to="/software">software and AI</Link>,
        open the <Link to="/aegis">AEGIS defense record</Link>, or review the <Link to="/symphony">Symphony process</Link>.
      </p>
    </main>
  );
}
