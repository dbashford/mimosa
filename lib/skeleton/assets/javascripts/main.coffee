require
  paths:
    jquery: 'vendor/jquery'
  , ['jquery', 'templates']
  , ($, templates) ->
    $('body').append(templates.example({name:'Handlebars'}))