define ['jquery', 'templates'], ($, templates) ->

  class ExampleView

    render: (element) ->
      $(element).append templates.example.render({name:'Hogan', css:'CSSHERE'}, templates)
      $(element).append templates['another-example'].render({name:'Hogan'}, templates)

  ExampleView