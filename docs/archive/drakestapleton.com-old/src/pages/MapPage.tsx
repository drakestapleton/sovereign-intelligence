import { Birdseye } from "../diagrams/Birdseye";
import { usePageMeta } from "../lib/usePageMeta";

export function MapPage() {
  usePageMeta("/symphony/map");

  return (
    <main className="wrap wide map-page">
      <p className="kicker">Diagram · 18 Jun - 13 Aug 2026</p>
      <h1>Bird’s-eye</h1>
      <p className="lede">
        This timeline covers six concurrent Atlas workstreams from June through August 2026. The first-run
        page documents the process&apos;s starting point.
      </p>
      <div className="card table-scroll">
        <Birdseye />
      </div>
    </main>
  );
}
