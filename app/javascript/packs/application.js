// app/javascript/packs/application.js

/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// ======================================================================
//
console.log('Hello World from Webpacker')
//
// ======================================================================


require("@rails/ujs").start()
require("turbolinks").start()

// jquery and popper is included in bootstrap,
// If include these, it will be conflicted
// https://rubyyagi.com/how-to-use-bootstrap-and-jquery-in-rails-6-with-webpacker/
import 'bootstrap'

// To solve Uncaught ReferenceError, $ is not defined
var jQuery = require('jquery')
// include jQuery in global and window scope (so you can access it globally)
// in your web browser, when you type $('.div'), it is actually refering to global.$('.div')
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;

// Bootstrap popover
document.addEventListener("turbolinks:load", function() {
    $(function () {
        $('[data-toggle="popover"]').popover({
            trigger: 'focus'
        })
    })
})

// AOS from yarn
import AOS from 'aos';
document.addEventListener('DOMContentLoaded', function() {
    AOS.init({
        startEvent: 'turbolinks:load' // if you are using turbolinks
    });
});

// Create chart
// https://chartkick.com/
require("chartkick")
require("chart.js")

// Plotly.js
// https://classic.yarnpkg.com/en/package/plotly.js-basic-dist
var Plotly = require('plotly.js-dist')
global.Plotly = Plotly
//console.log('Plotly.js. version: ' + Plotly.version)



// ======================================================================
//
console.log('End from Webpacker')
//
// ======================================================================
