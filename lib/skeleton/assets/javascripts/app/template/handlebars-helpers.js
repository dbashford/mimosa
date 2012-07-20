define(['vendor/handlebars'], function(Handlebars) {
  Handlebars.registerHelper('example-helper', function() {
    new Handlebars.SafeString("This is coming from a Handlebars helper function written in CoffeeScript");
  });
});