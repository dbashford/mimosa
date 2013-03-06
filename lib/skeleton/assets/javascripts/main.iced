await require
  urlArgs: "b=#{new Date().getTime()}"
  paths:
    jquery: 'vendor/jquery'
  , ['app/example-view']
  , defer ExampleView
view = new ExampleView()
view.render 'body'
