# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "scroll_tracker", to: "scroll_tracker.js"


pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"


# Pin FullCalendar and its dependencies from local files
