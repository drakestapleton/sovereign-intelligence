# Omega Play — Manifest V3 Extension & VerdantUI Observer Bridge

Zero-cheat, zero-telemetry Chrome/Brave/Edge Manifest V3 extension that:
1. Measures live `requestAnimationFrame` `p50`, `p95`, `p99`, `1% low`, `0.1% low`, and `>25 ms` stutters on any browser game tab (strictly read-only; never hooks game logic or anti-cheat).
2. Silences idle background tabs (`chrome.tabs.discard`) to eliminate V8 GC & Chrome renderer contention while keeping pinned, audible, and `VerdantUI` tabs alive.
3. Relays live game-tab telemetry straight into **`https://afflom.github.io/VerdantUI/`** and feeds our imported **`omega-play-observer.holo`** Prism (`ObserverStreamBus` `omega.external_game` OTel events).
4. Optionally pairs over Chrome Native Messaging (`com.aienos.omega_play`) with local AienOS `omega-play` (`DRY_RUN_READONLY` default).

## Load in 10 seconds (Chrome / Brave / Edge)
1. Open `chrome://extensions` and enable **Developer mode**.
2. Click **Load unpacked** and select this `omega-play-extension/` directory.
3. Open `https://afflom.github.io/VerdantUI/` → **Studio** → **Import `.holo`** → select `../omega-play-observer.holo` → **Publish**.
4. Open any browser game tab (or `https://www.aienos.com/v1/#si-play`), click the **Omega Play** toolbar icon, and click **1. Monitor Active Game Tab** + **2. Silence Background Tabs**.
