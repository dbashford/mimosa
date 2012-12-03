/// <reference path="../vendor/require.d.ts" />

define(['jquery', 'templates'], function($, templates) {
  var ExampleView = (function() {

    function ExampleView() {}

    ExampleView.prototype.render = function(element) {
      templates.render('example', {name: 'Dust', css: 'CSSHERE'}, function(error, output) {
        $(element).append(output);
      });

      templates.render('another-example', {name: 'Dust'}, function(error, output) {
        $(element).append(output);
      });
    };

    return ExampleView;

  })();
  return ExampleView;
});

