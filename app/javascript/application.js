import "@hotwired/turbo-rails"
import "scroll_tracker"
import "controllers"


import "trix"
import "@rails/actiontext"




document.addEventListener("turbo:load", () => {
  if (window.amplitude) {
    window.amplitude.track("Page Viewed", {
      path: window.location.pathname,
      title: document.title
    });
  }
});