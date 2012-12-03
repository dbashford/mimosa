/// <reference path="../vendor/require.d.ts" />

define(['jquery'], function($) {
  var ExampleView = (function() {

    function ExampleView() {}

    ExampleView.prototype.render = function(element) {
      $(element).append("<div class='name'>This is coming directly from a view, not from a micro template</div>");
      $(element).append("<div class='styled'>And its all been styled (poorly) using CSSHERE</div>");
    };

    return ExampleView;

  })();
  return ExampleView;
});