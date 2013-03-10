ExampleView <-! require(
  url-args: "b=#{new Date!getTime!}"
  paths:
    jquery: \vendor/jquery
  shim:
    prelude: exports: \prelude
  <[ app/example-view prelude ]>
  _)
view = new ExampleView!
  ..render \body
