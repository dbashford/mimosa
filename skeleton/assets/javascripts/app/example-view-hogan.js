define(['jquery', 'templates'], function($, templates) {
  var ExampleView = (function() {

    function ExampleView() {}

    ExampleView.prototype.render = function(element) {
      $(element).append(templates.example.render({name: 'Hogan', css: 'CSSHERE'}, templates));
      $(element).append(templates['another-example'].render({name: 'Hogan'}, templates));
    };

    return ExampleView;

  })();
  return ExampleView;
});