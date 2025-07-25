// utc_time_converter.js
document.addEventListener("turbo:load", function () {
  document.querySelectorAll(".utc-date-time-range").forEach(function (el) {
    const startUtc = el.dataset.startUtc;
    if (!startUtc) return;

    const endUtc = el.dataset.endUtc;

    const startDate = new Date(startUtc);

    // Use Intl.DateTimeFormat to get the user's timezone name in long format
    const userTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;

    // Date options
    const optionsDate = { year: "numeric", month: "short", day: "2-digit" };
    const optionsTime = { hour: "2-digit", minute: "2-digit", hour12: true, timeZone: userTimeZone };

    const localDateStr = startDate.toLocaleDateString(undefined, optionsDate);
    const startTimeStr = startDate.toLocaleTimeString(undefined, optionsTime);

    if (endUtc) {
      const endDate = new Date(endUtc);
      const endTimeStr = endDate.toLocaleTimeString(undefined, optionsTime);

      el.textContent = `${localDateStr}, ${startTimeStr} - ${endTimeStr} (${userTimeZone})`;
    } else {
      el.textContent = `${localDateStr}, ${startTimeStr} (${userTimeZone})`;
    }
  });
});
