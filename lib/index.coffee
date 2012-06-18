require 'sugar'
path =     require 'path'
color  =   require("ansi-color").set
logger =   require './util/logger'
args =     require "nomnom"
express =  require 'express'
defaults = require './util/defaults'

class Mimosa

  constructor: ->
    configPath = path.resolve 'config.coffee'
    {config} = require configPath
    @root = path.dirname configPath
    @config = defaults(config)
    @parseCLI()

  parseCLI: ->
    args.command('watch')
      .option 'server',
        flag: true
        abbr: 's'
        help: 'run a server that will serve up the destination directory'
      .option 'port',
        abbr: 'p'
        help: 'port you would like to run the server on, defaults to:4321'
        metavar: 'PORT'
      .callback (opts) =>
        @watch(opts)
      .help "watch the filesystem and compile assets"

    args.option 'version',
      flag: true
      help: 'print version and exit'
      callback: -> "version 1.2.4"

    args.parse()

  watch: (opts) ->
    @startServer(opts.port) if opts.server

    compilers = [new (require("./compilers/copy"))(@config)]
    for category, catConfig of @config.compilers
      try
        compiler = require("./compilers/#{category}/#{catConfig.compileWith}")
        compilers.push(new compiler(@config))
        logger.info "Adding compiler: #{category}/#{catConfig.compileWith}"
      catch err
        logger.info "Unable to find matching compiler for #{category}/#{catConfig.compileWith}: #{err}"

    watcher = require('./watch/watcher')(@config.watch, @root)
    watcher.registerCompilers(compilers)

  startServer: (port = 4321) ->
    app = express.createServer()

    app.configure =>
      app.set('views', "#{__dirname}/views")
      app.set('view engine', 'jade')
      app.use (req, res, next) ->
        res.header 'Cache-Control', 'no-cache'
        next()
      app.use express.static("#{@root}/public/")

    app.get '/', (req, res) ->
      res.render 'index', { title: 'Mimosa\'s Express!' }

    app.listen parseInt port, 10

    logger.success "Mimosa started at http://localhost:#{port}/"


module.exports = new Mimosa