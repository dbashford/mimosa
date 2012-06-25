index = (useReload) ->

  isProduction = process.env.NODE_ENV is 'production'
  reload = useReload and not isProduction

  (req, res) ->
    res.render 'index', {title: "Express", reload: reload, production: isProduction}

exports.index = index