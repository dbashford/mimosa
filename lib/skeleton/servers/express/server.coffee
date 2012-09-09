express =        require 'express'
reloadOnChange = require 'watch-connect'
gzip =           require 'gzippo'
engines =        require 'consolidate'

routes  =        require './routes'

exports.startServer = (config) ->

  publicPath = config.watch.compiledDir

  app = express()
  server = app.listen config.server.port, ->
    console.log "Express server listening on port %d in %s mode", server.address().port, app.settings.env

  app.get '/', routes.index(config)

  app.configure ->
    app.set 'port', config.server.port
    app.set 'views', config.server.views.path
    app.engine config.server.views.extension, engines[config.server.views.compileWith]
    app.set 'view engine', config.server.views.extension
    app.use express.favicon()
    app.use express.bodyParser()
    app.use express.methodOverride()
    if config.server.useReload
      options =
        server:server
        basedir: config.server.views.path
        watchdir:publicPath
        skipAdding: !config.server.views.html
        exclude:["almond\.js"]
        additionaldirs:[config.server.views.path]
      app.use reloadOnChange(options)
    app.use config.server.base, app.router
    app.use gzip.staticGzip(publicPath)

  app.configure 'development', ->
    app.use express.errorHandler()

