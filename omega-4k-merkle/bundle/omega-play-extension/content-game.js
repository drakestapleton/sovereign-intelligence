(() => {
  'use strict';
  if (window.__omegaPlayMonitorActive) {
    if (window.__omegaPlayHudEl) {
      window.__omegaPlayHudEl.style.display =
        window.__omegaPlayHudEl.style.display === 'none' ? 'block' : 'none';
    }
    return;
  }
  window.__omegaPlayMonitorActive = true;

  const ring = new Float32Array(240);
  const sorted = new Float32Array(240);
  let ringIdx = 0;
  let ringFill = 0;
  let totalFrames = 0;
  let stutters = 0;
  let lastTs = 0;
  let lastSendMs = 0;

  const hud = document.createElement('div');
  hud.id = 'omega-play-hud';
  hud.setAttribute('role', 'status');
  Object.assign(hud.style, {
    position: 'fixed',
    top: '12px',
    right: '12px',
    zIndex: '2147483647',
    pointerEvents: 'none',
    padding: '8px 11px',
    borderRadius: '8px',
    border: '1px solid rgba(16, 185, 129, 0.55)',
    background: 'rgba(5, 10, 20, 0.88)',
    color: '#f1f5f9',
    fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
    fontSize: '11px',
    lineHeight: '1.4',
    boxShadow: '0 6px 24px rgba(0, 0, 0, 0.45)',
    whiteSpace: 'pre',
  });
  hud.textContent = 'OMEGA PLAY LIVE\nSampling frames...';
  (document.body || document.documentElement).appendChild(hud);
  window.__omegaPlayHudEl = hud;

  function computeMetrics() {
    const n = ringFill;
    if (n === 0) return null;
    let sum = 0;
    for (let i = 0; i < n; i++) {
      const v = ring[i];
      sorted[i] = v;
      sum += v;
    }
    for (let i = 1; i < n; i++) {
      const key = sorted[i];
      let j = i - 1;
      while (j >= 0 && sorted[j] > key) {
        sorted[j + 1] = sorted[j];
        j--;
      }
      sorted[j + 1] = key;
    }
    const p50 = sorted[(n * 0.5) | 0];
    const p95 = sorted[Math.min(n - 1, (n * 0.95) | 0)];
    const p99 = sorted[Math.min(n - 1, (n * 0.99) | 0)];
    const maxMs = sorted[n - 1];
    const avgMs = sum / n;
    const canvases = document.querySelectorAll('canvas');
    let largestCanvas = null;
    for (const c of canvases) {
      const area = (c.width || 0) * (c.height || 0);
      if (!largestCanvas || area > largestCanvas.area) {
        largestCanvas = { width: c.width || 0, height: c.height || 0, area };
      }
    }
    return {
      source: 'omega-play-mv3',
      samples: n,
      totalFrames,
      p50Ms: +p50.toFixed(2),
      p95Ms: +p95.toFixed(2),
      p99Ms: +p99.toFixed(2),
      maxMs: +maxMs.toFixed(2),
      avgFps: +(avgMs > 0 ? 1000 / avgMs : 0).toFixed(1),
      low1Fps: +(p99 > 0 ? 1000 / p99 : 0).toFixed(1),
      low01Fps: +(maxMs > 0 ? 1000 / maxMs : 0).toFixed(1),
      stuttersGt25ms: stutters,
      canvas: largestCanvas ? { width: largestCanvas.width, height: largestCanvas.height } : null,
    };
  }

  function tick(ts) {
    if (lastTs > 0) {
      const dt = ts - lastTs;
      ring[ringIdx] = dt;
      ringIdx = (ringIdx + 1) % 240;
      if (ringFill < 240) ringFill++;
      if (dt > 25) stutters++;
      totalFrames++;
    }
    lastTs = ts;

    if (ts - lastSendMs >= 1200 && ringFill >= 15) {
      lastSendMs = ts;
      const m = computeMetrics();
      if (m) {
        hud.textContent =
          'OMEGA PLAY -> VERDANT OBSERVER\n' +
          'AVG ' + m.avgFps + ' FPS | 1% LOW ' + m.low1Fps + ' FPS\n' +
          'p99 ' + m.p99Ms + 'ms | stutters(>25ms): ' + m.stuttersGt25ms;
        try {
          chrome.runtime.sendMessage({ type: 'GAME_TELEMETRY', payload: m });
        } catch (_) {
          // Extension reloaded
        }
      }
    }
    requestAnimationFrame(tick);
  }

  requestAnimationFrame(tick);
})();
