define ['jquery', 'templates'], ($, templates) ->

  class ExampleView

    render: (element) ->
      $(element).append templates.example({name:'EJS', css:'CSSHERE'})
      $(element).append templates['another-example']({name:'EJS'})

  ExampleView