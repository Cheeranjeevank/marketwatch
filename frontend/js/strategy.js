document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const cellProduct   = document.getElementById('cell-product');
  const cellMarketing = document.getElementById('cell-marketing');
  const cellSales     = document.getElementById('cell-sales');

  const cellProductTxt   = document.getElementById('cell-product-txt');
  const cellMarketingTxt = document.getElementById('cell-marketing-txt');
  const cellSalesTxt     = document.getElementById('cell-sales-txt');

  const btnResetMatrix       = document.getElementById('btn-reset-matrix');
  const btnSynthesizeStrategy = document.getElementById('btn-synthesize-strategy');

  const terminalScreenText   = document.getElementById('terminal-screen-text');
  const resImmediateAction   = document.getElementById('res-immediate-action');
  const strategyJsonOutput   = document.getElementById('strategy-json-output');
  const recommendationsWall  = document.getElementById('recommendations-wall-container');

  const dotMarketing = document.getElementById('dot-marketing');
  const dotProduct   = document.getElementById('dot-product');
  const dotSales     = document.getElementById('dot-sales');
  const dotStrategy  = document.getElementById('dot-strategy');

  let recommendations = [];
  let isProductActive   = false;
  let isMarketingActive = false;
  let isSalesActive     = false;

  // ── Load static wall recommendations ─────────────────────────────────────
  async function loadRecommendations() {
    try {
      const r    = await fetch('data/sample.json');
      const data = await r.json();
      recommendations = data.strategy.recommendations;
      renderWall();
    } catch {
      recommendations = [];
      renderWall();
    }
  }

  // ── Render static recommendations wall ────────────────────────────────────
  function renderWall() {
    recommendationsWall.innerHTML = '';
    if (!recommendations.length) {
      recommendationsWall.innerHTML = `
        <div style="grid-column:1/-1;text-align:center;padding:3rem;color:var(--text-muted);border:1px dashed var(--card-border);border-radius:12px;">
          No recommendations logged yet. Run a Strategy Synthesis first.
        </div>`;
      return;
    }
    recommendations.forEach((r, i) => {
      const card = document.createElement('div');
      card.className = 'card animate-fade-in';
      card.style.animationDelay = `${i * 80}ms`;
      let badge = 'badge-neutral';
      if (r.impact.toLowerCase() === 'critical') badge = 'badge-negative';
      else if (r.impact.toLowerCase() === 'high')   badge = 'badge-warning';
      card.innerHTML = `
        <div class="card-header">
          <strong style="color:#fff;">${escapeHTML(r.title)}</strong>
          <span class="badge ${badge}">${escapeHTML(r.impact)}</span>
        </div>
        <div class="card-body">
          <p style="font-size:0.85rem;color:var(--text-secondary);line-height:1.5;">${escapeHTML(r.description)}</p>
          <div style="display:flex;justify-content:space-between;margin-top:14px;font-size:0.8rem;color:var(--text-secondary);">
            <span>Confidence: <strong>${r.confidence}%</strong></span>
            <span>Risk: <strong>${escapeHTML(r.risk)}</strong></span>
          </div>
        </div>
        <div class="card-footer">
          <span>Status: ${escapeHTML(r.status)}</span>
          <button class="btn btn-secondary btn-apply" style="padding:4px 8px;font-size:0.75rem;">Apply</button>
        </div>`;
      card.querySelector('.btn-apply').addEventListener('click', e => {
        e.currentTarget.textContent = 'Applied ✓';
        e.currentTarget.style.background = 'var(--accent-secondary-glow)';
        e.currentTarget.disabled = true;
      });
      recommendationsWall.appendChild(card);
    });
  }

  // ── Signal toggles ────────────────────────────────────────────────────────
  cellProduct.addEventListener('click', () => {
    isProductActive = !isProductActive;
    cellProduct.classList.toggle('active', isProductActive);
    cellProductTxt.textContent = isProductActive
      ? '🚨 Listing Hijack / FBA Returns Detected'
      : '✅ Healthy BSR & FBA Ops';
    runSynthesis();
  });

  cellMarketing.addEventListener('click', () => {
    isMarketingActive = !isMarketingActive;
    cellMarketing.classList.toggle('active', isMarketingActive);
    cellMarketingTxt.textContent = isMarketingActive
      ? '🔴 PPC Fatigue — High ACoS Crisis'
      : '✅ Stable Campaign — Profitable ACoS';
    runSynthesis();
  });

  cellSales.addEventListener('click', () => {
    isSalesActive = !isSalesActive;
    cellSales.classList.toggle('active', isSalesActive);
    cellSalesTxt.textContent = isSalesActive
      ? '⚠️ High ACoS / Low CVR — Revenue Risk'
      : '✅ Profitable ACoS & Strong Conversion';
    runSynthesis();
  });

  btnResetMatrix.addEventListener('click', () => {
    isProductActive   = false;
    isMarketingActive = false;
    isSalesActive     = false;
    cellProduct.classList.remove('active');
    cellMarketing.classList.remove('active');
    cellSales.classList.remove('active');
    cellProductTxt.textContent   = '✅ Healthy BSR & FBA Ops';
    cellMarketingTxt.textContent = '✅ Stable Campaign — Profitable ACoS';
    cellSalesTxt.textContent     = '✅ Profitable ACoS & Strong Conversion';
    runSynthesis();
  });

  btnSynthesizeStrategy.addEventListener('click', runSynthesis);

  // ── Main synthesis pipeline ───────────────────────────────────────────────
  function runSynthesis() {
    if (dotStrategy) dotStrategy.className = 'agent-dot thinking';

    // Show thinking state
    terminalScreenText.innerHTML =
      '⏳ Initializing CEO Brain...<br>' +
      '📡 Receiving telemetry from Marketing, Product & Sales agents...<br>' +
      '🧠 Running Weighted Evidence Accumulation (WEA) scoring matrix...<br>' +
      '🎯 Selecting optimal playbook...';

    resImmediateAction.innerHTML = '<em style="color:var(--text-muted)">Generating advice...</em>';

    const mktSignal  = isMarketingActive ? 'PPC Fatigue — High ACoS Crisis' : 'Profitable ACoS';
    const prodSignal = isProductActive   ? 'Listing Hijack/FBA Returns'     : 'Healthy BSR';
    const salesSig   = isSalesActive     ? 'High ACoS/Low CVR'              : 'High Growth Revenue';

    fetch('http://localhost:8080/strategy/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        marketing_summary: mktSignal,
        product_pain_point: prodSignal,
        sales_forecast: salesSig
      })
    })
    .then(r => {
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.json();
    })
    .then(data => {
      const priority  = data.priority    || 'Unknown Priority';
      const steps     = data.immediateAction || [];
      const conf      = data.confidence  || 0;

      // ── Render numbered action cards in resImmediateAction ──────────────
      resImmediateAction.innerHTML = renderActionCards(steps, priority);

      // ── Render terminal summary ──────────────────────────────────────────
      const termText =
        `*** MARKETWATCH CEO INTELLIGENCE REPORT ***\n` +
        `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n` +
        ` PRODUCT  → ${prodSignal.toUpperCase()}\n` +
        ` MARKETING→ ${mktSignal.toUpperCase()}\n` +
        ` SALES    → ${salesSig.toUpperCase()}\n` +
        `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n` +
        ` PRIORITY : ${priority}\n` +
        ` CONFIDENCE: ${conf}%\n` +
        `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n` +
        ` TOTAL STEPS: ${steps.length} actionable decisions generated\n` +
        ` STATUS: CEO playbook armed. Execute in sequence.\n` +
        `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`;

      typewriterTerminal(termText);
      strategyJsonOutput.textContent = JSON.stringify(data, null, 2);
      if (dotStrategy) dotStrategy.className = 'agent-dot active';
    })
    .catch(err => {
      console.error(err);
      resImmediateAction.innerHTML =
        '<div style="color:var(--danger);font-weight:700;">⚠️ Backend Connection Error</div>' +
        '<p style="font-size:0.8rem;color:var(--text-secondary);margin-top:6px;">' +
        'Could not reach Dart Frog at http://localhost:8080/strategy/analyze<br>' +
        'Ensure the backend server is running.</p>';
      typewriterTerminal('CRITICAL ERROR: Failed to reach backend.\nEnsure dart_frog dev is running on port 8080.');
      if (dotStrategy) dotStrategy.className = 'agent-dot error';
    });
  }

  // ── Render advice as beautiful numbered step cards ────────────────────────
  function renderActionCards(steps, priority) {
    if (!steps || !steps.length) return '<em>No advice generated.</em>';

    // Determine colour theme based on priority emoji
    let accent = '#6366f1'; // default indigo
    let bgAccent = 'rgba(99,102,241,0.08)';
    if (priority.includes('🚨')) { accent = '#ef4444'; bgAccent = 'rgba(239,68,68,0.08)'; }
    else if (priority.includes('🔴')) { accent = '#f97316'; bgAccent = 'rgba(249,115,22,0.08)'; }
    else if (priority.includes('⚠️')) { accent = '#f59e0b'; bgAccent = 'rgba(245,158,11,0.08)'; }
    else if (priority.includes('✅')) { accent = '#10b981'; bgAccent = 'rgba(16,185,129,0.08)'; }
    else if (priority.includes('🔵')) { accent = '#38bdf8'; bgAccent = 'rgba(56,189,248,0.08)'; }
    else if (priority.includes('📦')) { accent = '#a78bfa'; bgAccent = 'rgba(167,139,250,0.08)'; }

    let html = `
      <div style="margin-bottom:14px;">
        <div style="display:inline-flex;align-items:center;gap:8px;background:${bgAccent};
             border:1px solid ${accent}33;border-radius:20px;padding:6px 14px;">
          <span style="font-size:0.85rem;font-weight:700;color:${accent};">${escapeHTML(priority)}</span>
        </div>
      </div>`;

    steps.forEach((step, i) => {
      // Skip financial runway and seasonal pulse — display them differently
      const isRunway   = step.startsWith('⏱️') || step.startsWith('💰') || step.startsWith('✅ FINANCIAL') || step.startsWith('📊 FINANCIAL');
      const isSeasonal = step.startsWith('📅');

      if (isRunway) {
        html += `
          <div style="background:rgba(255,255,255,0.03);border-left:3px solid ${accent}55;
               border-radius:0 8px 8px 0;padding:10px 14px;margin-bottom:8px;font-size:0.78rem;
               color:#94a3b8;line-height:1.5;">
            ${escapeHTML(step)}
          </div>`;
        return;
      }
      if (isSeasonal) {
        html += `
          <div style="background:rgba(56,189,248,0.06);border:1px solid rgba(56,189,248,0.2);
               border-radius:8px;padding:10px 14px;margin-top:4px;font-size:0.78rem;
               color:#7dd3fc;line-height:1.5;">
            ${escapeHTML(step)}
          </div>`;
        return;
      }

      html += `
        <div class="animate-fade-in" style="display:flex;gap:12px;align-items:flex-start;
             background:${bgAccent};border:1px solid ${accent}22;border-radius:10px;
             padding:12px 14px;margin-bottom:8px;animation-delay:${i * 80}ms;">
          <div style="min-width:28px;height:28px;border-radius:50%;background:${accent}22;
               border:1px solid ${accent}66;display:flex;align-items:center;justify-content:center;
               font-size:0.75rem;font-weight:800;color:${accent};flex-shrink:0;">
            ${i + 1}
          </div>
          <div style="font-size:0.82rem;color:#e2e8f0;line-height:1.55;">${escapeHTML(step)}</div>
        </div>`;
    });

    return html;
  }

  // ── Typewriter terminal effect ────────────────────────────────────────────
  let twInterval = null;
  function typewriterTerminal(text) {
    if (twInterval) clearInterval(twInterval);
    terminalScreenText.textContent = '';
    let idx = 0;
    twInterval = setInterval(() => {
      if (idx < text.length) {
        const ch = text.charAt(idx);
        terminalScreenText.innerHTML += ch === '\n' ? '<br>' : escapeHTML(ch);
        idx++;
      } else {
        clearInterval(twInterval);
      }
    }, 9);
  }

  // ── Utilities ─────────────────────────────────────────────────────────────
  function escapeHTML(str) {
    if (typeof str !== 'string') return '';
    return str.replace(/[&<>'"]/g, t =>
      ({ '&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;' }[t] || t));
  }

  // ── Init ─────────────────────────────────────────────────────────────────
  loadRecommendations();
  runSynthesis();
});
