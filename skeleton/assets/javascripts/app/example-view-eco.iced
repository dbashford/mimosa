define ['jquery', 'templates'], ($, templates) ->

  class ExampleView

    render: (element) ->
      $(element).append templates.example({name:'ECO', css:'CSSHERE'})
      $(element).append templates['another-example']({name:'ECO'})

  ExampleView