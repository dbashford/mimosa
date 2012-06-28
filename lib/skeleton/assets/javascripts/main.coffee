require
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    jquery: 'vendor/jquery'
  , ['jquery', 'templates']
  , ($, templates) ->
    $('body').append(templates.example({name:'Handlebars'}))
    $('body').append(templates['another-example']())