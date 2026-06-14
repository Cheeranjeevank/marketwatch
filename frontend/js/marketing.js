document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const trendingPlatformSelect = document.getElementById('trending-platform-select');
  const btnCameraSim = document.getElementById('btn-camera-sim');
  const btnScrapeSim = document.getElementById('btn-scrape-sim');
  const scrapeUrlField = document.getElementById('scrape-url-field');
  const textInputField = document.getElementById('text-input-field');
  const btnRunClassifier = document.getElementById('btn-run-classifier');
  const cameraPlaceholder = document.getElementById('camera-placeholder');
  const layer1Log = document.getElementById('layer1-log');

  const tfliteIndicator = document.getElementById('tflite-indicator');
  const tfliteText = document.getElementById('tflite-text');
  const sentimentResultVal = document.getElementById('sentiment-result-val');
  const urgencyResultVal = document.getElementById('urgency-result-val');
  const layer2Val = document.getElementById('layer2-val');
  const layer3Val = document.getElementById('layer3-val');
  const jsonOutput = document.getElementById('marketing-json-output');

  const mktTotalSpend = document.getElementById('mkt-total-spend');
  const mktTotalClicks = document.getElementById('mkt-total-clicks');
  const mktMainChannel = document.getElementById('mkt-main-channel');

  const competitorFilters = document.getElementById('competitor-filters');
  const channelFilters = document.getElementById('channel-filters');
  const campaignsGridContainer = document.getElementById('campaigns-grid-container');

  const simulationDialog = document.getElementById('simulation-dialog');
  const btnOpenModal = document.getElementById('btn-open-modal');
  const btnCloseModal = document.getElementById('btn-close-modal');
  const campaignForm = document.getElementById('campaign-form');

  // Sidebar dot states
  const dotMarketing = document.getElementById('dot-marketing');
  const dotProduct = document.getElementById('dot-product');
  const dotSales = document.getElementById('dot-sales');
  const dotStrategy = document.getElementById('dot-strategy');

  // State
  let campaigns = [];
  let currentCompetitorFilter = 'all';
  let currentChannelFilter = 'all';

  // Load baseline campaigns and metrics
  async function loadCampaigns() {
    try {
      const response = await fetch('data/sample.json');
      const data = await response.json();
      campaigns = data.marketing.campaigns;
      
      updateCompetitorFilterUI(data.marketing.competitors);
      updateMetrics();
      renderCampaignsGrid();
    } catch (e) {
      console.error('Error loading campaigns:', e);
      campaigns = [];
      updateMetrics();
      renderCampaignsGrid();
    }
  }

  // Calculate high-level marketing metrics
  function updateMetrics() {
    if (campaigns.length === 0) {
      mktTotalSpend.textContent = '$0';
      mktTotalClicks.textContent = '0';
      mktMainChannel.textContent = 'N/A';
      return;
    }

    const totalSpend = campaigns.reduce((acc, c) => acc + c.spent, 0);
    const totalClicks = campaigns.reduce((acc, c) => acc + c.clicks, 0);

    // Find main channel
    const channels = {};
    campaigns.forEach(c => {
      channels[c.channel] = (channels[c.channel] || 0) + 1;
    });
    let mainChannel = 'N/A';
    let maxCount = -1;
    for (const [ch, count] of Object.entries(channels)) {
      if (count > maxCount) {
        maxCount = count;
        mainChannel = ch;
      }
    }

    mktTotalSpend.textContent = `$${totalSpend.toLocaleString()}`;
    mktTotalClicks.textContent = totalClicks.toLocaleString();
    mktMainChannel.innerHTML = `<span style="font-size: 1.15rem; font-weight: 700; color: var(--accent-primary);">${escapeHTML(mainChannel)}</span>`;
  }

  // Dynamically populate competitor filter buttons
  function updateCompetitorFilterUI(competitors) {
    competitorFilters.innerHTML = '<button class="filter-btn active" data-competitor="all">All Competitors</button>';
    competitors.forEach(comp => {
      const btn = document.createElement('button');
      btn.className = 'filter-btn';
      btn.setAttribute('data-competitor', comp);
      btn.textContent = comp;
      competitorFilters.appendChild(btn);
    });

    // Wire up filter click listeners
    document.querySelectorAll('#competitor-filters .filter-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        document.querySelectorAll('#competitor-filters .filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentCompetitorFilter = btn.getAttribute('data-competitor');
        renderCampaignsGrid();
      });
    });
  }

  // Render cards grid
  function renderCampaignsGrid() {
    campaignsGridContainer.innerHTML = '';
    
    const filtered = campaigns.filter(c => {
      const matchComp = currentCompetitorFilter === 'all' || c.competitor === currentCompetitorFilter;
      const matchChan = currentChannelFilter === 'all' || c.channel === currentChannelFilter;
      return matchComp && matchChan;
    });

    if (filtered.length === 0) {
      campaignsGridContainer.innerHTML = `
        <div style="grid-column: 1/-1; text-align: center; padding: 3rem; color: var(--text-muted); border: 1px dashed var(--card-border); border-radius: 12px;">
          No matching ad campaigns detected.
        </div>
      `;
      return;
    }

    filtered.forEach((c, idx) => {
      const card = document.createElement('div');
      card.className = 'card animate-fade-in';
      card.style.animationDelay = `${idx * 100}ms`;

      let badgeClass = 'badge-neutral';
      if (c.impact.toLowerCase() === 'critical') badgeClass = 'badge-negative';
      else if (c.impact.toLowerCase() === 'high') badgeClass = 'badge-warning';

      card.innerHTML = `
        <div class="card-header">
          <strong style="color:#fff;">${escapeHTML(c.competitor)}</strong>
          <span class="badge ${badgeClass}">${escapeHTML(c.impact)}</span>
        </div>
        <div class="card-body">
          <div class="card-title">${escapeHTML(c.title)}</div>
          <div style="display:flex; justify-content:space-between; margin-top:14px; font-size:0.8rem; color:var(--text-secondary);">
            <span>Est. Spend: <strong>$${c.spent.toLocaleString()}</strong></span>
            <span>Clicks: <strong>${c.clicks.toLocaleString()}</strong></span>
          </div>
        </div>
        <div class="card-footer">
          <span>Channel: ${escapeHTML(c.channel)}</span>
          <span>${c.date || 'Active'}</span>
        </div>
      `;
      campaignsGridContainer.appendChild(card);
    });
  }

  // Setup channel filters
  document.querySelectorAll('#channel-filters .filter-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('#channel-filters .filter-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      currentChannelFilter = btn.getAttribute('data-channel');
      renderCampaignsGrid();
    });
  });

  // Modal open/close actions
  if (btnOpenModal) {
    btnOpenModal.addEventListener('click', () => {
      simulationDialog.showModal();
    });
  }
  if (btnCloseModal) {
    btnCloseModal.addEventListener('click', () => {
      simulationDialog.close();
    });
  }

  // Form submit handler to simulate ad creation
  campaignForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const newCampaign = {
      id: 'c' + (campaigns.length + 1),
      competitor: document.getElementById('comp-name').value,
      title: document.getElementById('camp-title').value,
      channel: document.getElementById('camp-channel').value,
      spent: parseInt(document.getElementById('camp-spent').value) || 0,
      clicks: parseInt(document.getElementById('camp-clicks').value) || 0,
      status: 'Active',
      date: new Date().toISOString().split('T')[0]
    };

    // Calculate Impact and Sentiment automatically using weights
    const cpc = newCampaign.clicks > 0 ? (newCampaign.spent / newCampaign.clicks) : newCampaign.spent;
    
    if (cpc > 15 || newCampaign.spent > 20000) {
      newCampaign.impact = 'Critical';
      newCampaign.sentiment = 'Negative';
    } else if (cpc < 5 && newCampaign.clicks > 100) {
      newCampaign.impact = 'Good';
      newCampaign.sentiment = 'Positive';
    } else {
      newCampaign.impact = 'Normal';
      newCampaign.sentiment = 'Mixed';
    }

    campaigns.push(newCampaign);
    updateMetrics();
    renderCampaignsGrid();
    simulationDialog.close();
    campaignForm.reset();

    // Trigger local dot thinking micro-animation
    if (dotMarketing) {
      dotMarketing.className = 'agent-dot thinking';
      setTimeout(() => {
        dotMarketing.className = 'agent-dot active';
      }, 1500);
    }
  });

  // Camera Ingestion simulation
  btnCameraSim.addEventListener('click', () => {
    cameraPlaceholder.style.display = 'block';
    layer1Log.innerHTML = 'Initializing physical camera pipeline...<br>Scanning viewport for text...';
    
    setTimeout(() => {
      textInputField.value = 'Initech launches new local AI engine, offering 3x faster queries but suffers from severe UI lags and negative feedback';
      layer1Log.innerHTML = 'Camera scan success!<br>Extracted: "Initech launches new local AI engine..."';
      cameraPlaceholder.style.display = 'none';
    }, 1500);
  });

  // Scrape Ingestion simulation
  btnScrapeSim.addEventListener('click', () => {
    const url = scrapeUrlField.value || 'https://twitter.com/marketwatch/trends';
    layer1Log.innerHTML = `Connecting to ${url}...<br>Bypassing paywalls and dynamic content...`;
    
    setTimeout(() => {
      textInputField.value = 'Acme Corp ad campaign matches amazing customer satisfaction ratings. Great features and perfect stability!';
      layer1Log.innerHTML = `Successfully scraped ${url}<br>Extracted: "Acme Corp ad campaign matches amazing..."`;
    }, 1200);
  });

  // Run TFLite Classifier simulation
  btnRunClassifier.addEventListener('click', () => {
    const text = textInputField.value.trim();
    if (!text) {
      layer1Log.innerHTML = '<span style="color:var(--danger)">Error: No text input provided for classification</span>';
      return;
    }

    // Enter thinking state
    if (dotMarketing) dotMarketing.className = 'agent-dot thinking';
    tfliteIndicator.className = 'tflite-status neutral';
    tfliteText.textContent = 'Thinking...';
    layer1Log.innerHTML += `<br>Tokenizing scraped buffer...<br>Running multi-tensor inference...`;

    fetch('http://localhost:8080/marketing/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        product: "Competitor Analysis",
        extracted_text: text,
        trending_platform: trendingPlatformSelect.value
      })
    })
    .then(res => {
      if (!res.ok) throw new Error("HTTP " + res.status);
      return res.json();
    })
    .then(data => {
      const sentiment = data.Sentiment || 50;
      const impactScore = data.TrendScore || 0.5;
      const layer3 = data.Layer3_Context_Aware_Summarization || {};
      const recommendation = layer3.summary || "No recommendation provided by backend.";
      const platform = trendingPlatformSelect.value;
      
      let status = "Neutral";
      let trendClass = "neutral";
      if (sentiment > 70) {
        status = "Green";
        trendClass = "green";
      } else if (sentiment < 40) {
        status = "Red";
        trendClass = "red";
      }

      const urgency = status === "Red" ? 85 : 45;

      const summaryText = status === "Green"
          ? `Highly favorable customer response trending on ${platform}.`
          : `Critical warning: Negative sentiment detected on ${platform}.`;

      // Update UI
      tfliteIndicator.className = `tflite-status ${trendClass}`;
      tfliteText.textContent = `Backend Live (Connected)`;
      sentimentResultVal.textContent = `${sentiment}%`;
      urgencyResultVal.textContent = `${urgency}%`;
      layer2Val.innerHTML = `<span style="font-weight:700; color:#fff;">${impactScore}</span> (Trend Score from Backend)`;
      
      layer3Val.innerHTML = `<strong>Summary:</strong> ${summaryText}<br><strong style="color:var(--accent-secondary)">Recommendation:</strong> ${recommendation}`;
      
      if (dotMarketing) dotMarketing.className = 'agent-dot active';

      jsonOutput.textContent = JSON.stringify(data, null, 2);
      layer1Log.innerHTML += `<br><span style="color:var(--success)">HTTP 200 OK. Backend Inference completed. Data parsed.</span>`;
    })
    .catch(err => {
      console.error(err);
      layer1Log.innerHTML += `<br><span style="color:var(--danger)">HTTP Error: Failed to reach backend at http://localhost:8080/marketing/analyze.<br>${err.message}</span>`;
      if (dotMarketing) dotMarketing.className = 'agent-dot error';
    });
  });

  // Helpers
  function escapeHTML(str) {
    return str.replace(/[&<>'"]/g, 
      tag => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        "'": '&#39;',
        '"': '&quot;'
      }[tag] || tag)
    );
  }

  // Initialize
  loadCampaigns();
});
