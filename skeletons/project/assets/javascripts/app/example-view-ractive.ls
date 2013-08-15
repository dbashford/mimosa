define ['jquery', 'vendor/ractive', 'templates'], ($, Ractive, templates) ->

  class ExampleView

    render: (element) ->
      $(element).append("<div id='ractive1'></div>")
      $(element).append("<div id='ractive2'></div>")
      new Ractive
        el: '#ractive1'
        template: templates.example
        partials: templates
        data:
          name:'Ractive'
          css:'CSSHERE'

      new Ractive
        el: '#ractive2'
        template: templates['another-example']
        data:
          name:'Ractive'