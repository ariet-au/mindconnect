// app/javascript/activity_tracker.js

let maxScrollPercent = 0;
let scrollTimeout = null;

const getHeaders = () => ({
  "Content-Type": "application/json",
  "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
});

function sendEvent(type, metadata = {}) {
  const csrfToken = document.querySelector('meta[name="csrf-token"]');
  if (!csrfToken) {
    console.warn("[Tracker] Missing CSRF token. Event not sent.");
    return;
  }

  fetch("/page_view_events", {
    method: "POST",
    headers: getHeaders(),
    body: JSON.stringify({
      event_type: type,
      url: window.location.pathname,
      metadata: metadata
    })
  }).then(response => {
    if (response.ok) {
      console.log(`[Tracker] Successfully sent ${type}:`, metadata);
    } else {
      console.error(`[Tracker] Failed to send ${type}. Status: ${response.status}`);
    }
  }).catch(err => console.error("[Tracker] Network error:", err));
}

// --- Click Tracking ---
function trackClick(e) {
  const target = e.target.closest('a, button, [data-track-info]');
  if (!target) return;

  const clickData = {
    event_name: target.dataset.trackInfo || "unnamed_click",
    experiment_name: target.dataset.experimentName || null,
    variant: target.dataset.variant || null,
    text: target.innerText?.trim().substring(0, 30),
    element_class: target.className || null
  };

  sendEvent("click", clickData);
}

// --- Scroll Tracking ---
function trackScroll() {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  if (docHeight <= 0) return;

  const scrollPercent = Math.round((scrollTop / docHeight) * 100);

  if (scrollPercent > maxScrollPercent) {
    if (scrollTimeout) clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(() => {
      sendEvent("scroll", { scroll_top: scrollTop, scroll_percent: scrollPercent });
      maxScrollPercent = scrollPercent;
    }, 1000); // 1s debounce to avoid spamming logs
  }
}

// --- Lifecycle & Impression Management ---
function initTrackers() {
  maxScrollPercent = 0;
  console.log("[Tracker] Initializing for page:", window.location.pathname);

  // 1. Record Impressions
  const experimentElements = document.querySelectorAll('[data-experiment-name]');
  const recordedExperiments = new Set();

  experimentElements.forEach(el => {
    const expName = el.dataset.experimentName;
    const variant = el.dataset.variant;

    if (expName && !recordedExperiments.has(expName)) {
      sendEvent("experiment_impression", {
        experiment_name: expName,
        variant: variant
      });
      recordedExperiments.add(expName);
    }
  });

  // 2. Listeners
  window.removeEventListener("scroll", trackScroll);
  document.removeEventListener("click", trackClick);

  window.addEventListener("scroll", trackScroll);
  document.addEventListener("click", trackClick);
}

function sendFinalScroll() {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const scrollPercent = Math.round((scrollTop / docHeight) * 100);

  if (scrollPercent > maxScrollPercent) {
    const beaconData = JSON.stringify({
      event_type: "scroll",
      url: window.location.pathname,
      metadata: { scroll_top: scrollTop, scroll_percent: scrollPercent }
    });
    navigator.sendBeacon("/page_view_events", beaconData);
    console.log("[Tracker] Sent final scroll via Beacon:", scrollPercent);
  }
}

document.addEventListener("turbo:load", initTrackers);
window.addEventListener("beforeunload", sendFinalScroll);