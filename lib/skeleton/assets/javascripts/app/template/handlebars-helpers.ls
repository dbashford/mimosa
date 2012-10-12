define ['vendor/handlebars'], (Handlebars) ->
  Handlebars.registerHelper 'example-helper', ->
    new Handlebars.SafeString "This is coming from a Handlebars helper function written in LiveScript"
