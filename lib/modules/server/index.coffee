path =    require 'path'
fs =      require 'fs'

express = require 'express'
_ =       require 'lodash'
engines = require 'consolidate'

logger =  require '../../util/logger'

class MimosaServer

  lifecycleRegistration: (config, register) ->
    return unless config.isServer
    register ['buildDone'], 'server', @_startServer

  _startServer: (config, options, next) =>
    if (config.server.useDefaultServer)
      @_startDefaultServer(config, next)
    else
      @_startProvidedServer(config, next)

  _startDefaultServer: (config, done) ->
    logger.debug "Setting up default express server"

    app = express()
    server = app.listen config.server.port, ->
      logger.success "Mimosa's bundled Express started at http://localhost:#{config.server.port}#{config.server.base}"
      done()

    app.configure =>
      app.set 'port', config.server.port
      app.set 'views', config.server.views.path
      app.engine config.server.views.extension, engines[config.server.views.compileWith]
      app.set 'view engine', config.server.views.extension
      app.use express.bodyParser()
      app.use express.methodOverride()
      app.use (req, res, next) ->
        res.header 'Cache-Control', 'no-cache'
        next()

      if config.server.useReload
        opts =
          server: server
          basedir: config.server.views.path
          watchdir: config.watch.compiledDir
          skipAdding: true
          exclude: ["almond\.js"]
          additionaldirs: [config.server.views.path]

        app.use (require 'watch-connect')(opts)

      app.use express.compress()
      app.use config.server.base, app.router
      app.use express.static(config.watch.compiledDir)

    if config.server.views.html
      name = if config.optimize
        'index-optimize'
      else
        'index'
      app.get '/', (req, res) -> res.render name
    else
      options =
        reload:    config.server.useReload
        optimize:  config.optimize ? false
        cachebust: if process.env.NODE_ENV isnt "production" then "?b=#{(new Date()).getTime()}" else ''

      logger.debug "Options for index:\n#{JSON.stringify(options, null, 2)}"

      # TODO, consider a configurable object of, action/url/viewname
      app.get '/', (req, res) -> res.render 'index', options

  _startProvidedServer: (config, done) ->
    fs.exists config.server.path, (exists) =>
      if exists
        server = require config.server.path
        if server.startServer
          logger.success "Mimosa is starting your server: #{config.server.path}"
          conf = _.extend({}, config)
          server.startServer(conf)
        else
          logger.error "Found provided server located at #{config.server.path} (#{serverPath}) but it does not contain a 'startServer' method."
      else
        logger.error "Attempted to start the provided server located at #{config.server.path} (#{serverPath}), but could not find it."
      done()

module.exports = new MimosaServer()