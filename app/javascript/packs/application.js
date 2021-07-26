// app/javascript/packs/application.js
// See
// https://railsguides.jp/webpacker.html

// ======================================================================
//
console.log('Hello World from Webpacker')
//
// ======================================================================


/* Default */
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"

Rails.start()
Turbolinks.start()


/* Bootstrap */
import bootstrap from 'bootstrap/dist/js/bootstrap';
// Bootstrap popover
document.addEventListener('DOMContentLoaded', function() {
  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
  var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl, {
      trigger: 'focus'
    });
  });
})


/* AOS */
import AOS from 'aos';
document.addEventListener('DOMContentLoaded', function() {
  AOS.init({
    startEvent: 'turbolinks:load' // if you are using turbolinks
  });
});


/* Create chart */
// https://chartkick.com/
require("chartkick")
require("chart.js")

// Plotly.js
// https://classic.yarnpkg.com/en/package/plotly.js-basic-dist
var Plotly = require('plotly.js-dist')
global.Plotly = Plotly
//console.log('Plotly.js. version: ' + Plotly.version)


/* Custom JS */
import "../src/custom.js";


// ======================================================================
//
console.log('End from Webpacker')
//
// ======================================================================
