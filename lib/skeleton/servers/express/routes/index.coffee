index = (config) ->

  options =
    reload:    config.server.useReload
    optimize:  config.optimize ? false
    cachebust: if process.env.NODE_ENV isnt "production" then "?b=#{(new Date()).getTime()}" else ''

  (req, res) -> res.render 'index', options

exports.index = index