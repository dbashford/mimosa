index = (useReload) ->

  (req, res) ->
    console.log process.env.NODE_ENV is 'production'
    isProduction = process.env.NODE_ENV is 'production'
    res.render 'index', { title: 'Express', reload:useReload, production:isProduction}

exports.index = index