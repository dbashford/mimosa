index = (useReload, optimize) ->

  options =
    title:     "Express"
    reload:    useReload
    optimize:  optimize ? false
    cachebust: if process.env.NODE_ENV isnt "production" then "?b=#{(new Date()).getTime()}" else ''

  (req, res) -> res.render 'index', options

exports.index = index