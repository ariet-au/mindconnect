// app/javascript/scroll_tracker.js

let maxScrollPercent = 0; // keep track of max scroll per page
let scrollTimeout = null;

function sendScroll(scrollTop, scrollPercent) {
  if (!document.querySelector('meta[name="csrf-token"]')) return;

  fetch("/page_view_events", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
    },
    body: JSON.stringify({
      event_type: "scroll",
      url: window.location.pathname,
      metadata: { scroll_top: scrollTop, scroll_percent: scrollPercent }
    })
  });
  maxScrollPercent = scrollPercent;
}

// Handle scroll, only send if new max
function trackScroll() {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const scrollPercent = Math.round((scrollTop / docHeight) * 100);

  if (scrollPercent > maxScrollPercent) {
    if (scrollTimeout) clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(() => sendScroll(scrollTop, scrollPercent), 200);
  }
}

// Attach listeners safely on Turbo page load
function initScrollTracker() {
  maxScrollPercent = 0;

  // Remove previous listener if exists to prevent duplicates
  window.removeEventListener("scroll", trackScroll);
  window.addEventListener("scroll", trackScroll);
}

// Send final scroll on page exit
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
  }
}

// Turbo-safe initialization
document.addEventListener("turbo:load", initScrollTracker);
window.addEventListener("beforeunload", sendFinalScroll);
