define ['jquery', 'templates', 'vendor/nunjucks-slim'], ($, templates, nunjucks) ->

  class ExampleView

    render: (element) ->
      $(element).append nunjucks.render("example", {name:'nunjucks', css:'CSSHERE'})

  ExampleView