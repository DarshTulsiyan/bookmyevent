// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
document.addEventListener("turbo:load", () => {
  document.querySelectorAll('main [role="alert"]').forEach((alert) => {
    setTimeout(() => {
      alert.remove();
    }, 4000);
  });
});
