'use strict';

const VERDANT_URL_PREFIX = 'https://afflom.github.io/VerdantUI/';
const NATIVE_HOST = 'com.aienos.omega_play';

async function relayToVerdantTabs(telemetry) {
  const tabs = await chrome.tabs.query({ url: `${VERDANT_URL_PREFIX}*` });
  for (const tab of tabs) {
    if (typeof tab.id !== 'number') continue;
    try {
      await chrome.tabs.sendMessage(tab.id, {
        type: 'OMEGA_EXT_TELEMETRY',
        telemetry,
      });
    } catch (_) {
      // VerdantUI tab may still be loading
    }
  }
}

async function attachMonitorToTab(tabId) {
  await chrome.scripting.executeScript({
    target: { tabId },
    files: ['content-game.js'],
  });
  await chrome.storage.local.set({ monitoredTabId: tabId });
  await chrome.action.setBadgeBackgroundColor({ color: '#10b981' });
  await chrome.action.setBadgeText({ text: 'LIVE' });
}

async function silenceBackgroundTabs(activeTabId) {
  const allTabs = await chrome.tabs.query({});
  let discarded = 0;
  for (const tab of allTabs) {
    if (typeof tab.id !== 'number') continue;
    if (tab.id === activeTabId || tab.active || tab.pinned || tab.audible || tab.discarded) continue;
    if (tab.url && tab.url.startsWith(VERDANT_URL_PREFIX)) continue; // never discard VerdantUI Observer!
    try {
      await chrome.tabs.discard(tab.id);
      discarded += 1;
    } catch (_) {
      // Some internal chrome:// tabs cannot be discarded
    }
  }
  await chrome.storage.local.set({ lastSilencedCount: discarded, lastSilencedAt: Date.now() });
  return { discarded };
}

async function probeNativeHost() {
  if (!chrome.runtime.sendNativeMessage) {
    return { ok: false, error: 'nativeMessaging permission not granted' };
  }
  try {
    const resp = await chrome.runtime.sendNativeMessage(NATIVE_HOST, {
      cmd: 'probe',
      mode: 'DRY_RUN_READONLY',
    });
    return { ok: true, response: resp };
  } catch (err) {
    return { ok: false, error: err && err.message ? err.message : String(err) };
  }
}

chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  (async () => {
    try {
      if (!msg || typeof msg !== 'object') {
        sendResponse({ ok: false, error: 'invalid_message' });
        return;
      }

      if (msg.type === 'GAME_TELEMETRY') {
        const telemetry = {
          ...msg.payload,
          tabId: sender.tab ? sender.tab.id : null,
          tabTitle: sender.tab ? sender.tab.title : '',
          tabUrl: sender.tab ? sender.tab.url : '',
          receivedAt: Date.now(),
        };
        await chrome.storage.local.set({ latestTelemetry: telemetry });
        const fpsLabel = telemetry.avgFps ? String(Math.round(telemetry.avgFps)) : 'ON';
        await chrome.action.setBadgeText({ text: fpsLabel });
        await chrome.action.setBadgeBackgroundColor({
          color: telemetry.stuttersGt25ms > 0 ? '#f59e0b' : '#10b981',
        });
        await relayToVerdantTabs(telemetry);
        sendResponse({ ok: true });
        return;
      }

      if (msg.type === 'ATTACH_ACTIVE_TAB') {
        const [active] = await chrome.tabs.query({ active: true, currentWindow: true });
        if (!active || typeof active.id !== 'number') {
          sendResponse({ ok: false, error: 'no_active_tab' });
          return;
        }
        await attachMonitorToTab(active.id);
        sendResponse({ ok: true, tabId: active.id, title: active.title || '' });
        return;
      }

      if (msg.type === 'SILENCE_BG_TABS') {
        const [active] = await chrome.tabs.query({ active: true, currentWindow: true });
        const res = await silenceBackgroundTabs(active ? active.id : -1);
        sendResponse({ ok: true, ...res });
        return;
      }

      if (msg.type === 'OPEN_VERDANT_OBSERVER') {
        const existing = await chrome.tabs.query({ url: `${VERDANT_URL_PREFIX}*` });
        if (existing.length > 0 && typeof existing[0].id === 'number') {
          await chrome.tabs.update(existing[0].id, { active: true });
          sendResponse({ ok: true, reused: true });
        } else {
          await chrome.tabs.create({ url: VERDANT_URL_PREFIX });
          sendResponse({ ok: true, reused: false });
        }
        return;
      }

      if (msg.type === 'PROBE_NATIVE') {
        const res = await probeNativeHost();
        sendResponse(res);
        return;
      }

      if (msg.type === 'GET_STATE') {
        const state = await chrome.storage.local.get([
          'latestTelemetry',
          'monitoredTabId',
          'lastSilencedCount',
          'lastSilencedAt',
        ]);
        sendResponse({ ok: true, state });
        return;
      }

      sendResponse({ ok: false, error: 'unknown_message_type' });
    } catch (err) {
      sendResponse({ ok: false, error: err && err.message ? err.message : String(err) });
    }
  })();
  return true;
});
