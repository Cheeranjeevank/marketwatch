document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const campaignsCountEl = document.getElementById('stat-campaigns');
  const reviewsCountEl = document.getElementById('stat-reviews');
  const leadsCountEl = document.getElementById('stat-leads');
  const strategiesCountEl = document.getElementById('stat-strategies');
  
  const campaignsTableBody = document.getElementById('campaigns-preview-body');
  const alertsFeedContainer = document.getElementById('alerts-feed-container');
  const alertsCountBadge = document.getElementById('alerts-count');
  const btnRefresh = document.getElementById('btn-refresh');

  // New Upload and Processing elements
  const fileUploadInput = document.getElementById('file-upload-input');
  const btnUpload = document.getElementById('btn-upload');
  const uploadBtnText = document.getElementById('upload-btn-text');
  const btnProcess = document.getElementById('btn-process');
  const modelCard = document.getElementById('card-tflite-info');

  // State
  let campaigns = [];
  let reviews = [];
  let leads = [];
  let recommendations = [];

  // Fetch intelligence data
  async function loadData() {
    try {
      const response = await fetch('data/sample.json');
      if (!response.ok) throw new Error('Network response was not ok');
      const data = await response.json();
      
      campaigns = data.marketing.campaigns;
      reviews = data.product.reviews;
      leads = data.sales.leads;
      recommendations = data.strategy.recommendations;

      renderDashboard();
    } catch (error) {
      console.error('Error fetching sample data:', error);
      // Fallback
      campaigns = [];
      reviews = [];
      leads = [];
      recommendations = [];
      renderDashboard();
    }
  }

  function renderDashboard() {
    // 1. Animate metric values
    animateValue(campaignsCountEl, 0, campaigns.length, 1000);
    animateValue(reviewsCountEl, 0, reviews.length, 1000);
    animateValue(leadsCountEl, 0, leads.length, 1000);
    animateValue(strategiesCountEl, 0, recommendations.length, 1000);

    // 2. Campaigns Preview Table
    campaignsTableBody.innerHTML = '';
    const campaignsToShow = campaigns.slice(0, 3);
    
    if (campaignsToShow.length === 0) {
      campaignsTableBody.innerHTML = `
        <tr>
          <td colspan="5" style="text-align: center; color: var(--text-muted);">No campaigns loaded.</td>
        </tr>
      `;
    } else {
      campaignsToShow.forEach(c => {
        const tr = document.createElement('tr');
        
        let badgeClass = 'badge-neutral';
        if (c.impact.toLowerCase() === 'critical') badgeClass = 'badge-negative';
        else if (c.impact.toLowerCase() === 'high') badgeClass = 'badge-warning';

        tr.innerHTML = `
          <td><strong style="color:#fff;">${escapeHTML(c.competitor)}</strong></td>
          <td>${escapeHTML(c.title)}</td>
          <td>${escapeHTML(c.channel)}</td>
          <td>$${c.spent.toLocaleString()}</td>
          <td><span class="badge ${badgeClass}">${escapeHTML(c.impact)}</span></td>
        `;
        campaignsTableBody.appendChild(tr);
      });
    }

    // 3. Alerts Feed rendering
    alertsFeedContainer.innerHTML = '';
    const alerts = generateAlerts();
    alertsCountBadge.textContent = `${alerts.length} New`;
    
    alerts.forEach((alert, index) => {
      const item = document.createElement('div');
      item.className = 'activity-item';
      item.style.animationDelay = `${index * 150}ms`;
      item.classList.add('animate-fade-in');
      
      item.innerHTML = `
        <span class="activity-badge ${alert.agent}"></span>
        <div class="activity-content">
          <p class="activity-text">
            <strong style="color: #fff;">[${alert.agentName}]</strong> ${escapeHTML(alert.text)}
          </p>
          <div class="activity-meta">
            <span>${escapeHTML(alert.subtext)}</span>
            <span>${alert.time}</span>
          </div>
        </div>
      `;
      alertsFeedContainer.appendChild(item);
    });
  }

  // Generate alerts log based on data
  function generateAlerts() {
    const list = [];
    
    // Add marketing alerts
    if (campaigns.length > 0) {
      const topCampaign = campaigns[campaigns.length - 1];
      list.push({
        agent: 'marketing',
        agentName: 'Marketing AI',
        text: `Detected campaign launch: "${topCampaign.title}" by ${topCampaign.competitor} on ${topCampaign.channel}.`,
        subtext: `Target: Competitive Advantage | Spent: $${topCampaign.spent.toLocaleString()}`,
        time: '2m ago'
      });
    }

    // Add sales alerts
    if (leads.length > 0) {
      const topLead = leads[0];
      list.push({
        agent: 'sales',
        agentName: 'Sales AI',
        text: `Qualified HOT lead: ${topLead.company} (${topLead.role}) interested in migration.`,
        subtext: `Est. Annual Value: $${topLead.value.toLocaleString()} | Confidence: ${topLead.confidence}%`,
        time: '12m ago'
      });
    }

    // Add product alerts
    if (reviews.length > 0) {
      const topReview = reviews.find(r => r.sentiment === 'Negative') || reviews[0];
      list.push({
        agent: 'product',
        agentName: 'Product AI',
        text: `Negative sentiment flagged on ${topReview.platform}: "${topReview.content.substring(0, 50)}..."`,
        subtext: `Identified Gap: ${topReview.gap}`,
        time: '45m ago'
      });
    }

    // Add strategy alerts
    if (recommendations.length > 0) {
      const topRec = recommendations.find(r => r.impact === 'Critical') || recommendations[0];
      list.push({
        agent: 'strategy',
        agentName: 'Strategy AI',
        text: `New recommendation formulated: "${topRec.title}" based on current feedback loops.`,
        subtext: `Confidence: ${topRec.confidence}% | Priority: ${topRec.impact}`,
        time: '1h ago'
      });
    }

    return list;
  }

  // Animation values helper
  function animateValue(obj, start, end, duration) {
    let startTimestamp = null;
    const step = (timestamp) => {
      if (!startTimestamp) startTimestamp = timestamp;
      const progress = Math.min((timestamp - startTimestamp) / duration, 1);
      obj.innerHTML = Math.floor(progress * (end - start) + start).toLocaleString();
      if (progress < 1) {
        window.requestAnimationFrame(step);
      }
    };
    window.requestAnimationFrame(step);
  }

  // Refresh Sync Simulator
  btnRefresh.addEventListener('click', () => {
    alertsFeedContainer.innerHTML = '<div style="text-align: center; padding: 2rem; color: var(--text-muted);">Syncing with agent swarm...</div>';
    
    setTimeout(() => {
      loadData();
    }, 1200);
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

  // File Upload listener
  btnUpload.addEventListener('click', () => {
    fileUploadInput.click();
  });

  fileUploadInput.addEventListener('change', (e) => {
    if (e.target.files.length > 0) {
      const file = e.target.files[0];
      uploadBtnText.textContent = file.name;
      btnProcess.disabled = false;
      btnProcess.style.opacity = '1';
      btnProcess.style.cursor = 'pointer';
    }
  });

  // Process Dataset simulation listener
  btnProcess.addEventListener('click', () => {
    if (!fileUploadInput.files.length) return;
    
    btnProcess.disabled = true;
    btnProcess.style.opacity = '0.6';
    btnProcess.style.cursor = 'not-allowed';
    btnProcess.querySelector('span').textContent = 'Processing...';

    // Simulate progress delay
    setTimeout(() => {
      btnProcess.querySelector('span').textContent = 'Processed ✓';
      btnProcess.style.background = 'var(--success)';
      btnProcess.style.borderColor = 'var(--success)';
      
      // Update statistics to simulate new file details
      animateValue(campaignsCountEl, campaigns.length, campaigns.length + 8, 1000);
      animateValue(reviewsCountEl, reviews.length, reviews.length + 2166, 1000);
      animateValue(leadsCountEl, leads.length, leads.length + 14, 1000);
      animateValue(strategiesCountEl, recommendations.length, recommendations.length + 5, 1000);

      // Add intelligence alert in the feed
      const newAlert = document.createElement('div');
      newAlert.className = 'activity-item animate-fade-in';
      newAlert.style.borderLeft = '3px solid var(--accent-secondary)';
      newAlert.style.paddingLeft = '8px';
      newAlert.innerHTML = `
        <span class="activity-badge strategy"></span>
        <div class="activity-content">
          <p class="activity-text">
            <strong style="color: #fff;">[System Swarm]</strong> Successfully parsed dataset "${escapeHTML(fileUploadInput.files[0].name)}". Ingested 2,166 new customer reviews.
          </p>
          <div class="activity-meta">
            <span>Data Ingestion Engine</span>
            <span>Just now</span>
          </div>
        </div>
      `;
      alertsFeedContainer.prepend(newAlert);
      
      // Update alerts count badge
      const count = parseInt(alertsCountBadge.textContent) || 0;
      alertsCountBadge.textContent = `${count + 1} New`;
    }, 1500);
  });

  // Model Card Zoom listener
  if (modelCard) {
    modelCard.addEventListener('click', () => {
      modelCard.classList.toggle('zoomed');
    });
  }

  // Run initial load
  loadData();
});
