define(['jquery', 'vendor/ractive', 'templates'], function($, Ractive, templates) {
  var ExampleView = (function() {

    function ExampleView() {}

    ExampleView.prototype.render = function(element) {
      $(element).append("<div id='ractive1'></div>");
      $(element).append("<div id='ractive2'></div>");
      new Ractive({
        el: '#ractive1',
        template: templates.example,
        partials:templates,
        data: {
          name:'Ractive',
          css:'CSSHERE'}});

      new Ractive({
        el: '#ractive2',
        template: templates['another-example'],
        data:{
          name:'Ractive'}});
    };

    return ExampleView;

  })();
  return ExampleView;
});