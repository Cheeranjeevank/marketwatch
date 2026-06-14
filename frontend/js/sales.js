document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const salesPipelineVal = document.getElementById('sales-pipeline-val');
  const salesForecastVal = document.getElementById('sales-forecast-val');
  const salesConversionVal = document.getElementById('sales-conversion-val');

  const leadIngestionForm = document.getElementById('lead-ingestion-form');
  const leadCompany = document.getElementById('lead-company');
  const leadRole = document.getElementById('lead-role');
  const leadValue = document.getElementById('lead-value');
  const leadSignal = document.getElementById('lead-signal');

  const salesRecAction = document.getElementById('sales-rec-action');
  const salesJsonOutput = document.getElementById('sales-json-output');
  const leadsTableBody = document.getElementById('leads-table-body');

  // Sidebar dot states
  const dotMarketing = document.getElementById('dot-marketing');
  const dotProduct = document.getElementById('dot-product');
  const dotSales = document.getElementById('dot-sales');
  const dotStrategy = document.getElementById('dot-strategy');

  // State
  let leads = [];

  // Fetch initial leads
  async function loadLeads() {
    try {
      const response = await fetch('data/sample.json');
      const data = await response.json();
      leads = data.sales.leads;
      updatePipelineStats();
      renderLeadsTable();
    } catch (e) {
      console.error('Error fetching leads:', e);
      leads = [];
      updatePipelineStats();
      renderLeadsTable();
    }
  }

  // Update high-level indicators
  function updatePipelineStats() {
    if (leads.length === 0) {
      salesPipelineVal.textContent = '₹0';
      salesForecastVal.textContent = 'Stable Growth';
      salesConversionVal.textContent = '0%';
      return;
    }

    const totalValue = leads.reduce((acc, l) => acc + l.value, 0);
    const avgConfidence = leads.reduce((acc, l) => acc + l.confidence, 0) / leads.length;

    // Calculate forecast outlook category
    const hotCount = leads.filter(l => l.status === 'Hot').length;
    const coolCount = leads.filter(l => l.status === 'Cool').length;
    
    let forecast = 'Stable Growth';
    if (hotCount > coolCount) {
      forecast = 'High Growth';
    } else if (coolCount > hotCount) {
      forecast = 'Downside Risk';
    }

    salesPipelineVal.textContent = `$${totalValue.toLocaleString()}`;
    salesForecastVal.innerHTML = `<span style="font-weight: 700; color: ${forecast === 'High Growth' ? 'var(--success)' : (forecast === 'Downside Risk' ? 'var(--danger)' : '#fff')}">${forecast}</span>`;
    salesConversionVal.textContent = `${Math.round(avgConfidence)}%`;
  }

  // Render Qualified Leads datatable
  function renderLeadsTable() {
    leadsTableBody.innerHTML = '';

    if (leads.length === 0) {
      leadsTableBody.innerHTML = `
        <tr>
          <td colspan="6" style="text-align: center; color: var(--text-muted);">No pipeline opportunities logged.</td>
        </tr>
      `;
      return;
    }

    leads.forEach((l, idx) => {
      const tr = document.createElement('tr');
      tr.className = 'animate-fade-in';
      tr.style.animationDelay = `${idx * 80}ms`;

      tr.innerHTML = `
        <td><strong style="color:#fff;">${escapeHTML(l.company)}</strong></td>
        <td>${escapeHTML(l.role)}</td>
        <td><strong>₹${l.value.toLocaleString()}</strong></td>
        <td style="max-width: 320px; font-size: 0.8rem; color: var(--text-secondary);">${escapeHTML(l.signal)}</td>
        <td>
          <span style="font-weight: 700; color: ${l.confidence > 80 ? 'var(--success)' : (l.confidence < 65 ? 'var(--warning)' : '#fff')}">${l.confidence}%</span>
        </td>
        <td>
          <div style="display:flex; gap: 8px;">
            <button class="btn btn-secondary btn-qualify" style="padding: 4px 8px; font-size:0.75rem; border-color:var(--success); color:var(--success)">Adjust Bid</button>
            <button class="btn btn-secondary btn-archive" style="padding: 4px 8px; font-size:0.75rem; border-color:var(--danger); color:var(--danger)">Pause</button>
          </div>
        </td>
      `;

      // Qualify Click Handler
      tr.querySelector('.btn-qualify').addEventListener('click', () => {
        tr.style.background = 'var(--success-glow)';
        tr.style.transition = 'all 0.5s ease';
        
        if (dotSales) dotSales.className = 'agent-dot thinking';

        setTimeout(() => {
          // Remove from local list and update
          leads = leads.filter(item => item.id !== l.id);
          updatePipelineStats();
          renderLeadsTable();
          if (dotSales) dotSales.className = 'agent-dot active';
        }, 1000);
      });

      // Archive Click Handler
      tr.querySelector('.btn-archive').addEventListener('click', () => {
        tr.style.background = 'var(--danger-glow)';
        tr.style.opacity = '0.3';
        tr.style.transform = 'translateX(50px)';
        tr.style.transition = 'all 0.5s ease';

        setTimeout(() => {
          leads = leads.filter(item => item.id !== l.id);
          updatePipelineStats();
          renderLeadsTable();
        }, 5000); // 500ms transition delay match
      });

      leadsTableBody.appendChild(tr);
    });
  }

  // Handle Signal scoring form submit
  leadIngestionForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const company = leadCompany.value.trim();
    const role = leadRole.value.trim();
    const value = parseInt(leadValue.value) || 0;
    const signalText = leadSignal.value.trim();

    if (dotSales) dotSales.className = 'agent-dot thinking';

    fetch('http://localhost:8080/sales/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        marketing_sentiment: 80,
        product_impact_score: 50,
        historical_sales: value
      })
    })
    .then(res => {
      if (!res.ok) throw new Error("HTTP " + res.status);
      return res.json();
    })
    .then(data => {
      const forecastText = data.forecast || "Stable";
      const recommendation = data.suggestion || "No recommendation provided.";
      let conversionRate = data.conversionRate || 0.5;
      
      const confidenceScore = Math.min(100, Math.max(0, conversionRate * 100));

      salesRecAction.textContent = recommendation;
      salesJsonOutput.textContent = JSON.stringify(data, null, 2);

      // Add new lead object to array
      const leadStatus = confidenceScore > 70 ? 'Hot' : (confidenceScore < 40 ? 'Cool' : 'Warm');
      const newLead = {
        id: 'l' + (leads.length + 1),
        company: company,
        signal: signalText,
        role: role,
        value: value,
        confidence: Math.round(confidenceScore),
        status: leadStatus,
        date: new Date().toISOString().split('T')[0]
      };

      leads.unshift(newLead);
      updatePipelineStats();
      renderLeadsTable();

      leadIngestionForm.reset();
      if (dotSales) dotSales.className = 'agent-dot active';
    })
    .catch(err => {
      console.error(err);
      salesRecAction.innerHTML = '<span style="color:var(--danger)">Backend Connection Error</span>';
      if (dotSales) dotSales.className = 'agent-dot error';
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
  loadLeads();
});
