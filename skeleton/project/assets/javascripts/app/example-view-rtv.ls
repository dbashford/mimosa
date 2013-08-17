define ['jquery', 'vendor/ractive', 'templates'], ($, Ractive, templates) ->

  class ExampleView

    render: (element) ->
      $(element).append("<div id='ractive1'></div>")
      $(element).append("<div id='ractive2'></div>")

      rac1 =
        el: '#ractive1'
        template: templates.example
        partials: templates
        data:
          name:'Ractive'
          css:'CSSHERE'

      rac2 =
        el: '#ractive2'
        template: templates['another-example']
        data:
          name:'Ractive'

      new Ractive rac1
      new Ractive rac2
