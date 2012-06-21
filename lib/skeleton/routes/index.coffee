index = (useReload) ->

  (req, res) ->
    res.render 'index', { title: 'Express', reload:useReload, production:process.env.NODE_ENV is 'production'}

exports.index = index