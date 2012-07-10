express =        require 'express'
reloadOnChange = require 'watch-connect'
gzip =           require 'gzippo'

routes  =        require './routes'

exports.startServer = (publicPath, useReload, optimize) ->

  app = module.exports = express.createServer()

  # Configuration

  app.configure ->
    app.set 'views', "#{__dirname}/views"
    app.set 'view engine', 'jade'
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router
    app.use reloadOnChange(publicPath, app, {verbose: false, skipAdding:true}) if useReload
    app.use gzip.staticGzip(publicPath)

  app.configure 'development', ->
    app.use express.errorHandler({ dumpExceptions: true, showStack: true })

  app.configure 'production', ->
    app.use express.errorHandler()
    app.use gzip.gzip()

  # Routes

  app.get '/', routes.index(useReload, optimize)

  app.listen 3000, ->
    console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
