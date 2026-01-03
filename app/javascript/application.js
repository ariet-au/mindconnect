import "@hotwired/turbo-rails"
import "scroll_tracker"
import "controllers"


import "trix"
import "@rails/actiontext"




document.addEventListener("turbo:load", function() {
  if (window.amplitude) {
    // This tells Amplitude "I moved to a new page" even without a refresh
    window.amplitude.track('Page View', { url: window.location.pathname });
  }
});