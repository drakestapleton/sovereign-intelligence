(() => {
  'use strict';
  const statusEl = document.getElementById('status');

  function show(text) {
    statusEl.textContent = text;
  }

  async function refreshState() {
    const res = await chrome.runtime.sendMessage({ type: 'GET_STATE' });
    if (res && res.ok && res.state && res.state.latestTelemetry) {
      const t = res.state.latestTelemetry;
      show(
        'LIVE GAME TELEMETRY -> VERDANT OBSERVER\n' +
        'Tab: ' + (t.tabTitle || t.tabUrl || 'Active tab') + '\n' +
        'AVG ' + t.avgFps + ' FPS | 1% LOW ' + t.low1Fps + ' FPS | 0.1% LOW ' + t.low01Fps + ' FPS\n' +
        'p50=' + t.p50Ms + 'ms  p95=' + t.p95Ms + 'ms  p99=' + t.p99Ms + 'ms  stutters=' + t.stuttersGt25ms
      );
    }
  }

  document.getElementById('btn-attach').addEventListener('click', async () => {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    if (tab && tab.url && /^https?:/.test(tab.url)) {
      const origin = new URL(tab.url).origin + '/*';
      const granted = await chrome.permissions.request({ origins: [origin] });
      if (!granted) {
        show('Host permission declined for ' + origin + '.');
        return;
      }
    }
    const res = await chrome.runtime.sendMessage({ type: 'ATTACH_ACTIVE_TAB' });
    if (res && res.ok) {
      show('Monitoring attached to "' + res.title + '".\nStreaming read-only rAF telemetry to VerdantUI Observer!');
    } else {
      show('Attach failed: ' + (res && res.error ? res.error : 'unknown error'));
    }
  });

  document.getElementById('btn-silence').addEventListener('click', async () => {
    const res = await chrome.runtime.sendMessage({ type: 'SILENCE_BG_TABS' });
    if (res && res.ok) {
      show('Silenced ' + res.discarded + ' idle background tab(s) (VerdantUI Observer & audible/pinned tabs preserved).');
    } else {
      show('Silence failed: ' + (res && res.error ? res.error : 'unknown error'));
    }
  });

  document.getElementById('btn-verdant').addEventListener('click', async () => {
    await chrome.runtime.sendMessage({ type: 'OPEN_VERDANT_OBSERVER' });
    show('Opened VerdantUI Observer (https://afflom.github.io/VerdantUI/). Import omega-play-observer.holo in Studio to ingest live OTel streams.');
  });

  document.getElementById('btn-native').addEventListener('click', async () => {
    const granted = await chrome.permissions.request({ permissions: ['nativeMessaging'] });
    if (!granted) {
      show('nativeMessaging permission not granted.');
      return;
    }
    const res = await chrome.runtime.sendMessage({ type: 'PROBE_NATIVE' });
    if (res && res.ok) {
      show('LOCAL AIENOS OMEGA-PLAY HOST (DRY_RUN_READONLY):\n' + JSON.stringify(res.response, null, 2));
    } else {
      show('Local omega-play native host not registered yet.\nRegister native-host/com.aienos.omega_play.json after installing sovereign-intelligence.\nDetail: ' + (res && res.error ? res.error : 'not found'));
    }
  });

  refreshState();
})();
