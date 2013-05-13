define ['jquery', 'templates'], ($, templates) ->

  class ExampleView

    render: (element) ->
      $(element).append templates.example({name:'Underscore', css:'CSSHERE'})
      $(element).append templates['another-example']({name:'Underscore'})

  ExampleView