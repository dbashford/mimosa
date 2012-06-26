index = (useReload, useBuilt) ->

  isProduction = process.env.NODE_ENV is 'production'
  reload = useReload and not isProduction
  useBuilt = isProduction and useBuilt

  (req, res) ->
    res.render 'index', {title: "Express", reload: reload, production: isProduction, useBuilt:useBuilt}

exports.index = index