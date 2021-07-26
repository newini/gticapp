/* Change navbar bkg color on Scroll */
window.onscroll = function() { scrollFunction() };

function scrollFunction() {
  if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
    document.getElementById("navbar").classList.add('navbar-scroll');
  } else {
    document.getElementById("navbar").classList.remove('navbar-scroll');
  }
}
