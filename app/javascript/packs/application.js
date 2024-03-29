// app/javascript/packs/application.js
// See
// https://railsguides.jp/webpacker.html

// ======================================================================
console.log('Begin of application.js')


/* Default */
import Rails from "@rails/ujs"
Rails.start()

import Turbolinks from "turbolinks"
Turbolinks.start()


/* jQuery */
// Use for ajax
//import $ from 'jquery'; Not work
// To solve Uncaught ReferenceError, $ is not defined
var jQuery = require('jquery')
// include jQuery in global and window scope (so you can access it globally)
// in your web browser, when you type $('.div'), it is actually refering to global.$('.div')
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;


/* Bootstrap */
import bootstrap from 'bootstrap/dist/js/bootstrap';
// Bootstrap popover
document.addEventListener('turbolinks:load', function() {
  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
  var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl, {
      trigger: 'focus'
    });
  });
})


/* AOS */
import AOS from 'aos';
document.addEventListener('turbolinks:load', function() {
  AOS.init({
    startEvent: 'turbolinks:load' // if you are using turbolinks
  });
});
// Add for DOMContentLoaded, due to turbolink not loaded on first load
// TODO find the reason
document.addEventListener('DOMContentLoaded', function() {
  AOS.init({
    startEvent: 'turbolinks:load' // if you are using turbolinks
  });
});



/* Create chart */
// https://chartkick.com/
require("chartkick")
require("chart.js")


/* Custom JS */
import "../src/custom.js";



// ======================================================================
console.log('End of application.js')
