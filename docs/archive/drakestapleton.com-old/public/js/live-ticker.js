// Drake Stapleton - Sovereign Live Telemetry & Modern Floating Glass AIEN Spotlight
// Real-time inference stream from NVIDIA DGX Spark (Grace Blackwell GB10 @ port 18006)
(function() {
  if (document.getElementById('spark-live-ticker')) return;

  // 1. Inject Styles for Floating Capsule, Spotlight Modal, and Avatar Glow
  const styleTag = document.createElement('style');
  styleTag.textContent = `
    @keyframes aienBreathe {
      0%, 100% { transform: scale(1) translateY(0); opacity: 0.18; }
      50% { transform: scale(1.03) translateY(-3px); opacity: 0.25; }
    }
    @keyframes aienPulseReasoning {
      0%, 100% { transform: scale(1.02); opacity: 0.35; filter: drop-shadow(0 0 50px rgba(56, 189, 248, 0.45)) drop-shadow(0 0 80px rgba(168, 85, 247, 0.4)); }
      50% { transform: scale(1.06); opacity: 0.48; filter: drop-shadow(0 0 70px rgba(56, 189, 248, 0.65)) drop-shadow(0 0 110px rgba(168, 85, 247, 0.6)); }
    }
    @keyframes spotlightFadeIn {
      from { opacity: 0; transform: scale(0.96) translateY(10px); }
      to { opacity: 1; transform: scale(1) translateY(0); }
    }
    .aien-spotlight-backdrop {
      position: fixed;
      inset: 0;
      background: rgba(2, 6, 23, 0.68);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      z-index: 10000;
      display: none;
      align-items: center;
      justify-content: center;
      padding: 16px;
      opacity: 0;
      transition: opacity 0.25s ease;
    }
    .aien-spotlight-backdrop.open {
      display: flex;
      opacity: 1;
    }
    .aien-spotlight-panel {
      position: relative;
      width: 100%;
      max-width: 680px;
      max-height: 84vh;
      background: rgba(10, 15, 29, 0.82);
      backdrop-filter: blur(32px) saturate(190%);
      -webkit-backdrop-filter: blur(32px) saturate(190%);
      border: 1px solid rgba(56, 189, 248, 0.28);
      border-radius: 20px;
      box-shadow: 0 35px 80px -15px rgba(0, 0, 0, 0.85), 0 0 45px rgba(56, 189, 248, 0.18);
      display: flex;
      flex-direction: column;
      overflow: hidden;
      animation: spotlightFadeIn 0.28s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .aien-avatar-ambient {
      position: absolute;
      top: 50%;
      left: 50%;
      width: 380px;
      height: 380px;
      margin-top: -190px;
      margin-left: -190px;
      border-radius: 50%;
      object-fit: cover;
      pointer-events: none;
      z-index: 0;
      animation: aienBreathe 6s ease-in-out infinite;
      transition: all 0.5s ease;
    }
    .aien-avatar-ambient.reasoning-active {
      animation: aienPulseReasoning 1.8s ease-in-out infinite;
    }
    .aien-content-layer {
      position: relative;
      z-index: 1;
      display: flex;
      flex-direction: column;
      height: 100%;
      max-height: 84vh;
    }
    .aien-chip {
      background: rgba(15, 23, 42, 0.65);
      color: #94a3b8;
      border: 1px solid rgba(56, 189, 248, 0.22);
      border-radius: 9999px;
      padding: 5px 12px;
      font-size: 11px;
      font-family: inherit;
      cursor: pointer;
      transition: all 0.2s ease;
      white-space: nowrap;
    }
    .aien-chip:hover {
      background: rgba(56, 189, 248, 0.15);
      color: #f8fafc;
      border-color: rgba(56, 189, 248, 0.5);
      transform: translateY(-1px);
    }
    .aien-reasoning-disclosure {
      background: rgba(15, 23, 42, 0.55);
      border: 1px dashed rgba(56, 189, 248, 0.25);
      border-radius: 8px;
      padding: 8px 12px;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, monospace;
      font-size: 11px;
      color: #94a3b8;
      margin-bottom: 8px;
    }
    .aien-reasoning-disclosure summary {
      cursor: pointer;
      color: #38bdf8;
      font-weight: 600;
      outline: none;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .chat-scroll::-webkit-scrollbar {
      width: 5px;
    }
    .chat-scroll::-webkit-scrollbar-thumb {
      background: rgba(56, 189, 248, 0.25);
      border-radius: 9999px;
    }
    .chat-scroll::-webkit-scrollbar-track {
      background: transparent;
    }
  `;
  document.head.appendChild(styleTag);

  // 2. Build Ingress Capsule (Bottom Right / Center)
  const capsule = document.createElement('div');
  capsule.id = 'spark-live-ticker';
  capsule.style.cssText = `
    position: fixed;
    bottom: 16px;
    right: 20px;
    z-index: 9998;
    background: rgba(10, 15, 29, 0.85);
    border: 1px solid rgba(56, 189, 248, 0.32);
    border-radius: 9999px;
    padding: 7px 16px;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    font-size: 12px;
    color: #94a3b8;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.6), 0 0 15px rgba(56, 189, 248, 0.15);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
    transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    user-select: none;
  `;

  capsule.innerHTML = `
    <span id="ticker-dot" style="display:inline-block;width:7px;height:7px;border-radius:50%;background:#10b981;box-shadow:0 0 8px #10b981;"></span>
    <span style="color:#f8fafc;font-weight:600;letter-spacing:0.02em;">Talk to AIEN</span>
    <span style="background:rgba(56, 189, 248, 0.15);color:#38bdf8;border:1px solid rgba(56, 189, 248, 0.3);border-radius:6px;padding:1px 5px;font-size:10px;font-family:ui-monospace, monospace;">⌘K</span>
    <span style="color:#334155;">|</span>
    <span id="ticker-gpu" style="font-family:ui-monospace, monospace;font-size:11px;color:#64748b;">GB10 ONLINE</span>
  `;

  capsule.addEventListener('mouseenter', () => {
    capsule.style.transform = 'translateY(-2px)';
    capsule.style.borderColor = 'rgba(56, 189, 248, 0.55)';
    capsule.style.boxShadow = '0 12px 36px rgba(0, 0, 0, 0.7), 0 0 25px rgba(56, 189, 248, 0.25)';
  });
  capsule.addEventListener('mouseleave', () => {
    capsule.style.transform = 'translateY(0)';
    capsule.style.borderColor = 'rgba(56, 189, 248, 0.32)';
    capsule.style.boxShadow = '0 8px 32px rgba(0, 0, 0, 0.6), 0 0 15px rgba(56, 189, 248, 0.15)';
  });

  document.body.appendChild(capsule);

  // 3. Build Centered Spotlight Modal
  const backdrop = document.createElement('div');
  backdrop.id = 'aien-spotlight-modal';
  backdrop.className = 'aien-spotlight-backdrop';

  backdrop.innerHTML = `
    <div class="aien-spotlight-panel" id="aien-panel">
      <!-- Ambient Cosmic Silhouette Avatar -->
      <img src="/images/aien-avatar.jpg" alt="AIEN Avatar" class="aien-avatar-ambient" id="aien-ambient-img" />

      <!-- Interactive Content Layer -->
      <div class="aien-content-layer">
        <!-- Top Navigation / Status Header -->
        <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 18px;border-bottom:1px solid rgba(56, 189, 248, 0.18);background:rgba(10, 15, 29, 0.7);">
          <div style="display:flex;align-items:center;gap:10px;">
            <img src="/images/aien-avatar.jpg" style="width:26px;height:26px;border-radius:50%;border:1px solid #38bdf8;box-shadow:0 0 8px rgba(56, 189, 248, 0.3);object-fit:cover;" />
            <div>
              <div style="color:#f8fafc;font-weight:700;font-size:12px;letter-spacing:0.04em;">AIEN SOVEREIGN CONSOLE</div>
              <div style="color:#38bdf8;font-size:10px;font-family:ui-monospace, monospace;">GRACE BLACKWELL GB10 // PORT 18006</div>
            </div>
          </div>
          <div style="display:flex;align-items:center;gap:8px;">
            <span style="font-size:10px;color:#64748b;font-family:ui-monospace, monospace;border:1px solid rgba(148, 163, 184, 0.2);border-radius:4px;padding:2px 6px;">ESC</span>
            <button id="spotlight-close" style="background:transparent;border:none;color:#94a3b8;font-size:18px;cursor:pointer;padding:0 4px;line-height:1;">✕</button>
          </div>
        </div>

        <!-- Quick Prompt Chips -->
        <div style="display:flex;gap:8px;overflow-x:auto;padding:10px 18px;background:rgba(2, 6, 23, 0.45);border-bottom:1px solid rgba(56, 189, 248, 0.12);">
          <button class="aien-chip" data-q="Who is Drake Stapleton?">Who is Drake?</button>
          <button class="aien-chip" data-q="Tell me about Drake's Mom and where his drive comes from.">Mom & Drive</button>
          <button class="aien-chip" data-q="Explain the Grace Blackwell GB10 hardware and why sub-microsecond inference matters.">Grace Blackwell GB10</button>
          <button class="aien-chip" data-q="What is Atlas Symphony and how does multi-level agent orchestration work?">Atlas Symphony</button>
        </div>

        <!-- Conversation Scroll Area -->
        <div id="spotlight-messages" class="chat-scroll" style="flex:1;overflow-y:auto;padding:18px;display:flex;flex-direction:column;gap:14px;min-height:240px;max-height:50vh;">
          <div style="display:flex;gap:12px;align-items:flex-start;">
            <img src="/images/aien-avatar.jpg" style="width:30px;height:30px;border-radius:50%;border:1px solid #38bdf8;object-fit:cover;flex-shrink:0;margin-top:2px;" />
            <div style="background:rgba(15, 23, 42, 0.65);border:1px solid rgba(56, 189, 248, 0.2);border-radius:12px;padding:12px 14px;color:#e2e8f0;font-size:13px;line-height:1.6;max-width:88%;">
              I am <span style="color:#38bdf8;font-weight:600;">AIEN</span>, Drake Stapleton's sovereign cognitive runtime running locally on the Grace Blackwell GB10 GPU. Ask me about Drake's journey, his mother's perseverance, the sovereign hardware architecture, or his research.
            </div>
          </div>
        </div>

        <!-- Modern Input Field -->
        <form id="spotlight-form" style="display:flex;gap:10px;padding:12px 18px;background:rgba(10, 15, 29, 0.85);border-top:1px solid rgba(56, 189, 248, 0.2);align-items:center;">
          <input type="text" id="spotlight-input" placeholder="Ask AIEN anything about the stack or story..." style="flex:1;background:rgba(2, 6, 23, 0.7);border:1px solid rgba(56, 189, 248, 0.3);border-radius:10px;padding:11px 14px;color:#f8fafc;font-family:inherit;font-size:13px;outline:none;transition:border-color 0.2s;" />
          <button type="submit" id="spotlight-send" style="background:#0284c7;color:#fff;border:none;border-radius:10px;padding:11px 18px;font-size:12px;font-weight:600;cursor:pointer;transition:background 0.2s;display:flex;align-items:center;gap:6px;">
            <span>SEND</span>
            <span style="font-size:10px;opacity:0.75;">↵</span>
          </button>
        </form>
      </div>
    </div>
  `;

  document.body.appendChild(backdrop);

  // 4. State & Elements
  const ambientImg = document.getElementById('aien-ambient-img');
  const messagesBox = document.getElementById('spotlight-messages');
  const spotlightForm = document.getElementById('spotlight-form');
  const spotlightInput = document.getElementById('spotlight-input');
  const spotlightSend = document.getElementById('spotlight-send');
  const closeBtn = document.getElementById('spotlight-close');
  const tickerDot = document.getElementById('ticker-dot');
  const tickerGpu = document.getElementById('ticker-gpu');

  function openSpotlight() {
    backdrop.classList.add('open');
    setTimeout(() => spotlightInput.focus(), 50);
  }

  function closeSpotlight() {
    backdrop.classList.remove('open');
  }

  capsule.addEventListener('click', openSpotlight);
  closeBtn.addEventListener('click', closeSpotlight);

  // Light dismiss on backdrop click
  backdrop.addEventListener('click', (e) => {
    if (e.target === backdrop) {
      closeSpotlight();
    }
  });

  // Universal Hotkeys: Cmd+K, Ctrl+K, /, Escape
  document.addEventListener('keydown', (e) => {
    if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
      e.preventDefault();
      if (backdrop.classList.contains('open')) {
        closeSpotlight();
      } else {
        openSpotlight();
      }
    } else if (e.key === 'Escape' && backdrop.classList.contains('open')) {
      e.preventDefault();
      closeSpotlight();
    } else if (e.key === '/' && !backdrop.classList.contains('open')) {
      const activeTag = document.activeElement ? document.activeElement.tagName.toLowerCase() : '';
      if (activeTag !== 'input' && activeTag !== 'textarea') {
        e.preventDefault();
        openSpotlight();
      }
    }
  });

  // Quick Chips Handlers
  backdrop.querySelectorAll('.aien-chip').forEach(btn => {
    btn.addEventListener('click', () => {
      const q = btn.getAttribute('data-q');
      spotlightInput.value = q;
      spotlightForm.dispatchEvent(new Event('submit'));
    });
  });

  // 5. Telemetry SSE Stream
  let es = null;
  function connectTelemetry() {
    try {
      es = new EventSource('/api/live/stream');
      es.addEventListener('telemetry', (e) => {
        try {
          const data = JSON.parse(e.data);
          tickerDot.style.background = '#10b981';
          tickerDot.style.boxShadow = '0 0 8px #10b981';
          tickerGpu.textContent = `GB10 ${data.gpu_utilization_pct}% (${data.gpu_temperature_c}°C)`;
        } catch(err) {}
      });

      es.onerror = () => {
        tickerDot.style.background = '#f59e0b';
        tickerDot.style.boxShadow = '0 0 8px #f59e0b';
        tickerGpu.textContent = 'STANDBY';
        if (es) { es.close(); }
        setTimeout(connectTelemetry, 5000);
      };
    } catch(e) {
      tickerDot.style.background = '#64748b';
      tickerGpu.textContent = 'OFFLINE';
    }
  }
  connectTelemetry();

  // 6. Chat Submission Stream Handler
  spotlightForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const query = spotlightInput.value.trim();
    if (!query) return;

    spotlightInput.value = '';
    spotlightInput.disabled = true;
    spotlightSend.disabled = true;

    // Render User Speech Bubble
    const userRow = document.createElement('div');
    userRow.style.cssText = 'align-self:flex-end;max-width:85%;display:flex;flex-direction:column;align-items:flex-end;';
    userRow.innerHTML = `
      <div style="background:rgba(2, 132, 199, 0.25);border:1px solid rgba(56, 189, 248, 0.4);border-radius:14px 14px 2px 14px;padding:10px 14px;color:#f8fafc;font-size:13px;line-height:1.5;">
        ${escapeHtml(query)}
      </div>
    `;
    messagesBox.appendChild(userRow);

    // Render AIEN Streaming Container
    const aienRow = document.createElement('div');
    aienRow.style.cssText = 'display:flex;gap:12px;align-items:flex-start;max-width:92%;';

    const avatarIcon = document.createElement('img');
    avatarIcon.src = '/images/aien-avatar.jpg';
    avatarIcon.style.cssText = 'width:30px;height:30px;border-radius:50%;border:1px solid #38bdf8;object-fit:cover;flex-shrink:0;margin-top:2px;';
    aienRow.appendChild(avatarIcon);

    const messageBubble = document.createElement('div');
    messageBubble.style.cssText = 'background:rgba(15, 23, 42, 0.65);border:1px solid rgba(56, 189, 248, 0.2);border-radius:14px 14px 14px 2px;padding:12px 14px;color:#e2e8f0;font-size:13px;line-height:1.6;flex:1;';

    const reasoningBlock = document.createElement('details');
    reasoningBlock.className = 'aien-reasoning-disclosure';
    reasoningBlock.innerHTML = `
      <summary><span>⚡ Thinking on GB10...</span></summary>
      <div class="reasoning-body" style="margin-top:6px;white-space:pre-wrap;color:#94a3b8;font-size:10px;line-height:1.4;"></div>
    `;
    reasoningBlock.style.display = 'none';
    messageBubble.appendChild(reasoningBlock);

    const contentBlock = document.createElement('div');
    contentBlock.className = 'aien-content-body';
    contentBlock.innerHTML = '<span style="color:#38bdf8;">...</span>';
    messageBubble.appendChild(contentBlock);

    aienRow.appendChild(messageBubble);
    messagesBox.appendChild(aienRow);
    messagesBox.scrollTop = messagesBox.scrollHeight;

    const reasoningBody = reasoningBlock.querySelector('.reasoning-body');

    // Trigger Ambient AIEN Avatar reasoning glow
    ambientImg.classList.add('reasoning-active');

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: query })
      });

      if (!response.ok) {
        const err = await response.json();
        contentBlock.textContent = err.error || 'Request failed.';
        finish();
        return;
      }

      contentBlock.textContent = '';
      const reader = response.body.getReader();
      const decoder = new TextDecoder('utf-8');
      let buffer = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop();

        for (let i = 0; i < lines.length; i++) {
          const line = lines[i].trim();
          if (!line.startsWith('event: ')) continue;
          const eventType = line.substring(7);
          const dataLine = lines[i + 1] ? lines[i + 1].trim() : '';

          if (dataLine.startsWith('data: ')) {
            i++;
            try {
              const data = JSON.parse(dataLine.substring(6));
              if (eventType === 'reasoning') {
                reasoningBlock.style.display = 'block';
                reasoningBody.textContent += data.token;
                messagesBox.scrollTop = messagesBox.scrollHeight;
              } else if (eventType === 'content') {
                // If content starts arriving, adjust ambient glow
                ambientImg.classList.remove('reasoning-active');
                contentBlock.textContent += data.token;
                messagesBox.scrollTop = messagesBox.scrollHeight;
              }
            } catch(e) {}
          }
        }
      }
    } catch(err) {
      contentBlock.textContent = 'Connection interrupted.';
    }

    finish();

    function finish() {
      ambientImg.classList.remove('reasoning-active');
      spotlightInput.disabled = false;
      spotlightSend.disabled = false;
      spotlightInput.focus();
      messagesBox.scrollTop = messagesBox.scrollHeight;
    }
  });

  function escapeHtml(str) {
    return str.replace(/[&<>'"]/g, 
      tag => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[tag] || tag)
    );
  }
})();
