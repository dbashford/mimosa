index = (useReload, optimize) ->

  options =
    title:    "Express"
    reload:   useReload
    optimize: optimize ? false
    env:      process.env.NODE_ENV ? "development"

  (req, res) -> res.render 'index', options

exports.index = index