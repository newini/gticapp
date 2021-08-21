/* Change navbar bkg color on Scroll */
window.onscroll = function() { scrollFunction() };

function scrollFunction() {
  if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
    document.getElementById("navbar").classList.add('navbar-scroll');
  } else {
    document.getElementById("navbar").classList.remove('navbar-scroll');
  }
}

/* Background color */
document.addEventListener('DOMContentLoaded', applyDarkTheme);
document.addEventListener('turbolinks:load', applyDarkTheme);

function applyDarkTheme() {
  const dark_theme_media = window.matchMedia("(prefers-color-scheme: dark)");
  if (dark_theme_media.matches) {
    // navbar
    document.getElementById("navbar").classList.remove('bg-light');
    document.getElementById("navbar").classList.remove('navbar-light');
    document.getElementById("navbar").classList.add('bg-dark');
    document.getElementById("navbar").classList.add('navbar-dark');
    // footer
    document.getElementById('footer').classList.remove('bg-light');
    document.getElementById('footer').classList.add('bg-dark');
    // Cards
    var cardList = [].slice.call(document.querySelectorAll('.card'));
    cardList.forEach( (card) => {
      card.classList.add('bg-dark');
    });
    // tables
    var tableList = [].slice.call(document.querySelectorAll('.table'));
    tableList.forEach( (table) => {
      table.classList.add('table-dark');
    });
  }
}
