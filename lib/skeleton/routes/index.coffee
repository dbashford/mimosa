index = (useReload) ->

  (req, res) ->
    res.render 'index', { title: 'Express', reload:useReload, production:process.NODE_ENV is 'production'}

exports.index = index