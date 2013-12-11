/// <reference path="../vendor/require.d.ts" />

define(['jquery', 'templates'], function($, templates) {
  var ExampleView = (function() {

    function ExampleView() {}

    ExampleView.prototype.render = function(element) {
      $(element).append(templates.example({name: 'Underscore', css: 'CSSHERE'}));
      $(element).append(templates['another-example']({name: 'Underscore'}));
    };

    return ExampleView;

  })();
  return ExampleView;
});