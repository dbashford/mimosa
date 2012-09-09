index = (config) ->

  options =
    reload:    config.server.useReload
    optimize:  config.optimize ? false
    cachebust: if process.env.NODE_ENV isnt "production" then "?b=#{(new Date()).getTime()}" else ''

  # In the event plain html pages are being used, need to
  # switch to different page for optimized view
  name = if config.optimize and config.server.views.html
    "index-optimize"
  else
    "index"

  (req, res) -> res.render name, options

exports.index = index