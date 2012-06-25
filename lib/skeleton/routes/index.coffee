index = (useReload) ->

  (req, res) ->
    isProduction = process.env.NODE_ENV is 'production'
    res.render 'index', { title: "Mimosa's Express", reload:useReload, production:isProduction}

exports.index = index