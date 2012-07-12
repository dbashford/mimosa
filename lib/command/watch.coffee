express =  require 'express'
path =     require 'path'
fs =       require 'fs'

gzip =     require 'gzippo'

util =     require './util'
logger =   require '../util/logger'
Watcher =  require './util/watcher'

watch = (opts) =>
  util.processConfig opts?.server, (config) =>
    compilers = util.fetchConfiguredCompilers(config, true)
    new Watcher(config, compilers, true, startServer if opts?.server)

startServer = (config) =>
  if (config.server.useDefaultServer) then startDefaultServer(config) else startProvidedServer(config)

startDefaultServer = (config) ->
  app = express()
  server = app.listen 3000, ->
    logger.success "Mimosa's bundled Express started at http://localhost:#{config.server.port}/", true

  app.configure =>
    app.set 'port', config.server.port || 3000
    app.set 'views', "#{__dirname}/views"
    app.set 'view engine', 'jade'
    app.use express.favicon()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router
    app.use (req, res, next) ->
      res.header 'Cache-Control', 'no-cache'
      next()
    if config.server.useReload
      app.use (require 'watch-connect')(config.watch.compiledDir, server, {verbose: false, skipAdding:true})
    app.use config.server.base, gzip.staticGzip(config.watch.compiledDir)

  production = process.env.NODE_ENV is 'production'
  reload = config.server.useReload and not production
  useBuilt = production and config.require.optimizationEnabled

  app.get '/', (req, res) =>
    res.render 'index', { title: 'Mimosa\'s Express', reload:reload, production:production, useBuilt:useBuilt}

startProvidedServer = (config) ->
  serverPath = path.resolve config.server.path
  fs.exists serverPath, (exists) =>
    if exists
      server = require serverPath
      if server.startServer
        logger.success "Mimosa is starting your server: #{config.server.path}", true
        server.startServer(config.watch.compiledDir, config.server.useReload, config.require.optimizationEnabled)
      else
        logger.error "Found provided server located at #{config.server.path} (#{serverPath}) but it does not contain a 'startServer' method."
    else
      logger.error "Attempted to start the provided server located at #{config.server.path} (#{serverPath}), but could not find it."

register = (program, callback) =>
  program
    .command('watch')
    .description("watch the filesystem and compile assets")
    .option("-s, --server", "run a server that will serve up the assets in the compiled directory")
    .action(callback)
    .on '--help', =>
      logger.green('  The watch command will observe your source directory and compile or copy your assets when they change.')
      logger.green('  When the watch command starts up, it will make an initial pass through your assets and compile or copy')
      logger.green('  any assets that are newer then their companion compiled assets in the compiled directory.  The watch command')
      logger.green('  will remain running when executed, and must be terminated with CNTL-C.')
      logger.blue( '\n    $ mimosa watch\n')
      logger.green('  Pass a server flag and Mimosa will start-up a server that will serve up the assets Mimosa compiles.  You have')
      logger.green('  the opportunity, via Mimosa\'s config, to provide Mimosa a hook to your own server if you have one.  If you')
      logger.green('  do not have a server, Mimosa will use an embedded server to serve up the assets.  Server configuration options')
      logger.green('  and explanations can be found in the \'server\' settings in the mimosa-config.')
      logger.blue( '\n    $ mimosa watch --server')
      logger.blue( '    $ mimosa watch -s\n')

module.exports = (program) ->
  register(program, watch)