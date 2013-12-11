define ['jquery', 'templates'], ($, templates) ->

  class ExampleView

    render: (element) ->
      $(element).append templates.example({name:'LoDash', css:'CSSHERE'})
      $(element).append templates['another-example']({name:'LoDash'})

  ExampleView