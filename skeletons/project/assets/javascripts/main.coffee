require
  urlArgs: "b=#{(new Date()).getTime()}"
  paths:
    jquery: 'vendor/jquery/jquery'
  , ['app/example-view']
  , (ExampleView) ->
    view = new ExampleView()
    view.render('body')