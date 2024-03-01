// @TODO: jQuery events listeners not firing?
$(document).on('ready', function() {
  $('.chosen-select').chosen();
});

// @WORKS: Vanilla JS - Calling jQuery Chosen
document.addEventListener('DOMContentLoaded', function() {
  var elements = document.querySelectorAll('.chosen-select');
  Array.prototype.forEach.call(elements, function(el, i){
    console.log("Vanilla JS Chosen Select");
    $('.chosen-select').chosen();
  });
});
