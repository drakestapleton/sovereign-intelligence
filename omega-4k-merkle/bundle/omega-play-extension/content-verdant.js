(() => {
  'use strict';
  let pill = null;

  function ensurePill() {
    if (pill && document.contains(pill)) return pill;
    pill = document.createElement('div');
    pill.id = 'omega-verdant-bridge-pill';
    Object.assign(pill.style, {
      position: 'fixed',
      bottom: '14px',
      right: '14px',
      zIndex: '2147483646',
      padding: '8px 12px',
      borderRadius: '10px',
      border: '1px solid rgba(16, 185, 129, 0.6)',
      background: 'rgba(7, 16, 31, 0.92)',
      color: '#e2e8f0',
      fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
      fontSize: '11px',
      lineHeight: '1.4',
      boxShadow: '0 8px 28px rgba(0, 0, 0, 0.45)',
      maxWidth: '340px',
      whiteSpace: 'pre-wrap',
    });
    document.body.appendChild(pill);
    return pill;
  }

  function forwardToPrisms(telemetry) {
    const frames = document.querySelectorAll('iframe');
    let delivered = 0;
    for (const f of frames) {
      try {
        if (f.contentWindow) {
          f.contentWindow.postMessage({
            __omegaExt: true,
            type: 'omega-ext-telemetry',
            payload: telemetry,
          }, '*');
          delivered += 1;
        }
      } catch (_) {
        // Ignore inaccessible frames
      }
    }
    return delivered;
  }

  chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
    if (msg && msg.type === 'OMEGA_EXT_TELEMETRY' && msg.telemetry) {
      const t = msg.telemetry;
      const delivered = forwardToPrisms(t);
      const el = ensurePill();
      const title = (t.tabTitle || t.tabUrl || 'External Game Tab').slice(0, 38);
      el.textContent =
        'OMEGA PLAY -> VERDANT OBSERVER BRIDGE\n' +
        'Tab: ' + title + '\n' +
        'AVG ' + t.avgFps + ' FPS | 1% LOW ' + t.low1Fps + ' FPS | p99 ' + t.p99Ms + 'ms\n' +
        'Stutters(>25ms): ' + t.stuttersGt25ms + ' | Prism frames fed: ' + delivered;
      sendResponse({ ok: true, delivered });
    }
    return false;
  });
})();
