ExampleView <-! require(
  url-args: "b=#{new Date!getTime!}"
  paths:
    jquery: \vendor/jquery
  <[ app/example-view ]>
  _)
view = new ExampleView!
  ..render \body
