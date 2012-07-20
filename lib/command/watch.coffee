path =     require 'path'
fs =       require 'fs'

gzip =     require 'gzippo'
express =  require 'express'

util =     require './util'
logger =   require '../util/logger'
Watcher =  require './util/watcher'

watch = (opts) =>
  util.processConfig opts?.server, (config) =>
    config.optimize = opts?.optimize
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
      options =
        server:server
        watchdir:config.watch.compiledDir
        verbose: false
        skipAdding:true
        ignore:["almond.js"]
      app.use (require 'watch-connect')(options)

    app.use config.server.base, gzip.staticGzip(config.watch.compiledDir)

  options =
    title:    'Mimosa\'s Express'
    reload:   config.server.useReload
    optimize: config.optimize ? false
    env:env:  process.env.NODE_ENV ? "development"

  app.get '/', (req, res) -> res.render 'index', options

startProvidedServer = (config) ->
  fs.exists config.server.path, (exists) =>
    if exists
      server = require config.server.path
      if server.startServer
        logger.success "Mimosa is starting your server: #{config.server.path}", true
        server.startServer(config.watch.compiledDir, config.server.useReload, config.optimize)
      else
        logger.error "Found provided server located at #{config.server.path} (#{serverPath}) but it does not contain a 'startServer' method."
    else
      logger.error "Attempted to start the provided server located at #{config.server.path} (#{serverPath}), but could not find it."

register = (program, callback) =>
  program
    .command('watch')
    .description("watch the filesystem and compile assets")
    .option("-s, --server",   "run a server that will serve up the assets in the compiled directory")
    .option("-o, --optimize", "run require.js optimization after each js file compile")
    .action(callback)
    .on '--help', =>
      logger.green('  The watch command will observe your source directory and compile or copy your assets when they change.')
      logger.green('  When the watch command starts up, it will make an initial pass through your assets and compile or copy')
      logger.green('  any assets that are newer then their companion compiled assets in the compiled directory.  The watch')
      logger.green('  command will remain running when executed, and must be terminated with CNTL-C.')
      logger.blue( '\n    $ mimosa watch\n')
      logger.green('  Pass a \'server\' flag and Mimosa will start-up a server that will serve up the assets Mimosa compiles.')
      logger.green('  You have the opportunity, via Mimosa\'s config, to provide Mimosa a hook to your own server if you have')
      logger.green('  one.  If you do not have a server, Mimosa will use an embedded server to serve up the assets.  Server')
      logger.green('  configuration options and explanations can be found in the \'server\' settings in the mimosa-config.')
      logger.blue( '\n    $ mimosa watch --server')
      logger.blue( '    $ mimosa watch -s\n')
      logger.green('  Pass an \'optimize\' flag and Mimosa will use requirejs to optimize your assets and provide you with')
      logger.green('  single files for the named requirejs modules.  It will do this any time a JavaScript asset is changed.')
      logger.blue( '\n    $ mimosa watch --optimize')
      logger.blue( '    $ mimosa watch -o\n')

module.exports = (program) ->
  register(program, watch)