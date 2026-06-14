document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const micTriggerBtn = document.getElementById('mic-trigger-btn');
  const micStatusText = document.getElementById('mic-status-text');
  const micSvg = document.getElementById('mic-svg');
  const acousticWaveform = document.getElementById('acoustic-waveform');
  const reviewTextField = document.getElementById('review-text-field');
  const btnProcessFeedback = document.getElementById('btn-process-feedback');

  const nodeListener = document.getElementById('node-listener');
  const nodeProcessor = document.getElementById('node-processor');
  const nodeController = document.getElementById('node-controller');

  const resPainpoint = document.getElementById('res-painpoint');
  const resCategory = document.getElementById('res-category');
  const resImpact = document.getElementById('res-impact');
  const productJsonOutput = document.getElementById('product-json-output');

  const prodGapCount = document.getElementById('prod-gap-count');
  const prodCsatVal = document.getElementById('prod-csat-val');
  const prodRoadmapVal = document.getElementById('prod-roadmap-val');

  const backlogTableBody = document.getElementById('backlog-table-body');
  const btnSimulateVoice = document.getElementById('btn-simulate-voice');

  // Sidebar indicators
  const dotMarketing = document.getElementById('dot-marketing');
  const dotProduct = document.getElementById('dot-product');
  const dotSales = document.getElementById('dot-sales');
  const dotStrategy = document.getElementById('dot-strategy');

  // State
  let reviews = [];
  let isRecording = false;

  // Load reviews and backlog
  async function loadReviews() {
    try {
      const response = await fetch('data/sample.json');
      const data = await response.json();
      reviews = data.product.reviews;
      updateStats();
      renderBacklogTable();
    } catch (e) {
      console.error('Error loading reviews:', e);
      reviews = [];
      updateStats();
      renderBacklogTable();
    }
  }

  // Update statistics values
  function updateStats() {
    if (reviews.length === 0) {
      prodGapCount.textContent = '0';
      prodCsatVal.textContent = 'N/A';
      prodRoadmapVal.textContent = '0';
      return;
    }

    const negativeCount = reviews.filter(r => r.sentiment === 'Negative').length;
    const ratingSum = reviews.reduce((acc, r) => acc + r.rating, 0);
    const avgRating = ratingSum / reviews.length;
    const csatPercent = Math.round((avgRating / 5) * 100);

    prodGapCount.textContent = negativeCount.toString();
    prodCsatVal.textContent = `${csatPercent}%`;
    prodRoadmapVal.textContent = reviews.filter(r => r.sentiment === 'Positive').length.toString();
  }

  // Render backlog list matching the reviews array
  function renderBacklogTable() {
    backlogTableBody.innerHTML = '';

    if (reviews.length === 0) {
      backlogTableBody.innerHTML = `
        <tr>
          <td colspan="5" style="text-align: center; color: var(--text-muted);">No feedback items logged.</td>
        </tr>
      `;
      return;
    }

    reviews.forEach((r, idx) => {
      const tr = document.createElement('tr');
      tr.className = 'animate-fade-in';
      tr.style.animationDelay = `${idx * 80}ms`;

      let badgeClass = 'badge-neutral';
      if (r.sentiment === 'Negative') badgeClass = 'badge-negative';
      else if (r.sentiment === 'Positive') badgeClass = 'badge-positive';

      tr.innerHTML = `
        <td>
          <div style="font-weight: 600; color: #fff;">${escapeHTML(r.user)}</div>
          <div style="font-size: 0.8rem; color: var(--text-secondary); margin-top: 4px;">"${escapeHTML(r.content)}"</div>
        </td>
        <td><span style="font-size:0.8rem; color: var(--accent-primary); font-weight: 600;">${escapeHTML(r.gap)}</span></td>
        <td><span class="badge ${badgeClass}">${escapeHTML(r.sentiment)}</span></td>
        <td><strong>${r.rating} / 5</strong></td>
        <td>
          <button class="btn btn-secondary btn-upvote" style="padding: 4px 8px; font-size: 0.75rem;">
            ▲ Upvote
          </button>
        </td>
      `;

      // Upvote action listener
      tr.querySelector('.btn-upvote').addEventListener('click', (e) => {
        const btn = e.currentTarget;
        btn.textContent = '▲ Upvoted';
        btn.style.background = 'var(--accent-secondary-glow)';
        btn.style.borderColor = 'var(--accent-secondary)';
        btn.style.color = '#fff';
        btn.disabled = true;
      });

      backlogTableBody.appendChild(tr);
    });
  }

  // Simulate microphone speech transcript inputs
  const simulatedTranscripts = [
    "The camera is completely broken. In low light, there is so much camera grain, it makes photos look completely terrible.",
    "I really love the new UI interface and dashboard design, it feels super modern and beautiful!",
    "It needs direct integrations with Salesforce because pushing leads manually takes too much time.",
    "App crashes immediately when exporting large datasets on my iqoo phone 15"
  ];
  let transcriptIdx = 0;

  btnSimulateVoice.addEventListener('click', () => {
    // Start microphone recording simulation
    if (isRecording) return;
    
    isRecording = true;
    micTriggerBtn.style.background = 'rgba(239, 68, 68, 0.15)';
    micTriggerBtn.style.borderColor = 'var(--danger)';
    micSvg.style.fill = 'var(--danger)';
    micStatusText.textContent = 'Listening to voice review...';
    acousticWaveform.classList.add('active');

    // Simulate speech transcription delay
    setTimeout(() => {
      reviewTextField.value = simulatedTranscripts[transcriptIdx];
      transcriptIdx = (transcriptIdx + 1) % simulatedTranscripts.length;
      
      stopRecording();
      // Auto run feedback pipeline
      processFeedbackPipeline();
    }, 2500);
  });

  // Toggle record manually
  micTriggerBtn.addEventListener('click', () => {
    if (isRecording) {
      stopRecording();
    } else {
      isRecording = true;
      micTriggerBtn.style.background = 'rgba(239, 68, 68, 0.15)';
      micTriggerBtn.style.borderColor = 'var(--danger)';
      micSvg.style.fill = 'var(--danger)';
      micStatusText.textContent = 'Listening to voice review...';
      acousticWaveform.classList.add('active');
    }
  });

  function stopRecording() {
    isRecording = false;
    micTriggerBtn.style.background = 'rgba(255, 255, 255, 0.03)';
    micTriggerBtn.style.borderColor = 'var(--card-border)';
    micSvg.style.fill = 'var(--text-secondary)';
    micStatusText.textContent = 'Click to record voice review';
    acousticWaveform.classList.remove('active');
  }

  // Manual trigger
  btnProcessFeedback.addEventListener('click', () => {
    processFeedbackPipeline();
  });

  // Core dual-layer processor workflow simulation
  function processFeedbackPipeline() {
    const text = reviewTextField.value.trim();
    if (!text) {
      micStatusText.innerHTML = '<span style="color:var(--danger)">Error: Input text is empty.</span>';
      return;
    }

    // Node 1: Listener activation
    nodeListener.classList.add('active');
    nodeProcessor.classList.remove('active');
    nodeController.classList.remove('active');

    if (dotProduct) dotProduct.className = 'agent-dot thinking';

    setTimeout(() => {
      // Node 2: Analyzer/Processor activation
      nodeListener.classList.remove('active');
      nodeProcessor.classList.add('active');

      setTimeout(() => {
        // Node 3: Controller activation
        nodeProcessor.classList.remove('active');
        nodeController.classList.add('active');

        fetch('http://localhost:8080/product/analyze', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ transcript: text })
        })
        .then(res => {
          if (!res.ok) throw new Error("HTTP " + res.status);
          return res.json();
        })
        .then(data => {
          const painpoint = data.painPoint || 'Unknown pain point';
          const category = data.category || 'General';
          const recommendation = data.recommendation || 'No recommendation';
          const impactScore = data.impactScore || 50;
          let sentimentText = impactScore > 70 ? 'Negative' : 'Positive';

          // Update UI
          resPainpoint.textContent = painpoint;
          resCategory.textContent = category.toUpperCase();
          resImpact.textContent = impactScore.toString();

          productJsonOutput.textContent = JSON.stringify(data, null, 2);

          // Add dynamically to backlog lists if not already there
          const rating = sentimentText === 'Positive' ? 5 : 1;
          const newReview = {
            id: 'r' + (reviews.length + 1),
            platform: 'Voice Ingest (Backend)',
            rating: rating,
            content: text,
            sentiment: sentimentText,
            gap: painpoint,
            user: 'Real User Feedback',
            date: new Date().toISOString().split('T')[0]
          };

          reviews.unshift(newReview);
          updateStats();
          renderBacklogTable();

          if (dotProduct) dotProduct.className = 'agent-dot active';

          // Turn off Controller node after action finish
          setTimeout(() => {
            nodeController.classList.remove('active');
          }, 1500);
        })
        .catch(err => {
          console.error(err);
          resPainpoint.innerHTML = '<span style="color:var(--danger)">Backend Connection Error</span>';
          if (dotProduct) dotProduct.className = 'agent-dot error';
          setTimeout(() => {
            nodeController.classList.remove('active');
          }, 1500);
        });

      }, 1000);
    }, 1000);
  }

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
  loadReviews();
});
