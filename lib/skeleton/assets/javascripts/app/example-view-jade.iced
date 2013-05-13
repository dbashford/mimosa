define ['jquery', 'templates'], ($, templates) ->

  class ExampleView

    render: (element) ->
      $(element).append templates.example({name:'Jade', css:'CSSHERE'})
      $(element).append templates['another-example']({name:'Jade'})

  ExampleView