require 'sugar'
path =     require 'path'
fs =       require 'fs'
{exec} =   require 'child_process'

color  =   require('ansi-color').set
args =     require 'nomnom'
express =  require 'express'
wrench =   require 'wrench'
glob =     require 'glob'

logger =   require './util/logger'
defaults = require './util/defaults'
version =  require('../package.json').version

class Mimosa

  constructor: -> @cli()

  cli: ->
    args.command('watch')
      .option 'server',
        flag: true
        abbr: 's'
        help: 'run a server that will serve up the destination directory'
      .help("watch the filesystem and compile assets")
      .callback (opts) =>
        @processConfig =>
          @watch(opts)

    args.command('new')
      .option 'name'
        flag: false
        abbr: 'n'
        help: 'name for your project, mimosa will create a directory by this name and place the skeleton inside'
        required:true
      .option 'noexpress'
        flag: true
        help: 'do not build express into the application setup'
      .help("build out a skeleton matching Mimosa's defaults, which includes a basic Express setup")
      .callback (opts) =>
        @build(opts)

    args.command('config')
      .help("copy the default mimosa config into the current folder")
      .callback => @copyConfig()

    args.option 'version',
      flag: true
      help: 'print version and exit'
      callback: -> version

    args.parse()

  processConfig: (callback) ->
    configPath = path.resolve 'config.coffee'
    try
      {config} = require configPath
    catch err
      logger.info "No configuration file found (config.coffee), using all defaults."
      config = {}

    defaults config, (err, newConfig) =>
      if err
        logger.fatal "Unable to start Mimosa, #{err} configuration(s) problems listed above."
        process.exit 1
      else
        newConfig.root = path.dirname configPath
        @config = newConfig
        callback()

  copyConfig: ->
    configPath = path.join __dirname, 'skeleton', "config.coffee"
    configFileContents = fs.readFileSync(configPath)
    currPath = path.join path.resolve(''), "config.coffee"
    fs.writeFile currPath, configFileContents, 'ascii'
    logger.success "Copied default config file into current directory."

  watch: (opts) ->
    @startServer() if opts.server

    compilers = [new (require("./compilers/copy"))(@config)]
    for category, catConfig of @config.compilers
      try
        continue if catConfig.compileWith is "none"
        compiler = require("./compilers/#{category}/#{catConfig.compileWith}")
        compilers.push(new compiler(@config))
        logger.info "Adding compiler: #{category}/#{catConfig.compileWith}"
      catch err
        logger.info "Unable to find matching compiler for #{category}/#{catConfig.compileWith}: #{err}"

    watcher = require('./watch/watcher')(@config)
    watcher.registerCompilers(compilers)

  startServer: ->
    if (@config.server.useDefaultServer) then @startDefaultServer() else @startProvidedServer()

  startDefaultServer: ->
    production = process.env.NODE_ENV is 'production'

    app = express.createServer()

    app.configure =>
      app.set('views', "#{__dirname}/views")
      app.set('view engine', 'jade')
      app.use (req, res, next) ->
        res.header 'Cache-Control', 'no-cache'
        next()
      if @config.server.useReload
        app.use (require 'watch-connect')(@config.watch.compiledDir, app, {verbose: false, skipAdding:true})
      app.use @config.server.base, express.static(@config.watch.compiledDir)

    app.get '/', (req, res) =>
      res.render 'index', { title: 'Mimosa\'s Express', reload:@config.server.useReload and not production, production:production}

    app.listen @config.server.port

    logger.success "Mimosa started at http://localhost:#{@config.server.port}/"

  startProvidedServer: ->
    serverPath = path.resolve @config.server.path
    path.exists serverPath, (exists) =>
      if exists
        server = require serverPath
        if server.startServer
          server.startServer(@config.watch.compiledDir, @config.server.useReload)
        else
          logger.error "Found provided server located at #{@config.server.path} (#{serverPath}) but it does not contain a 'startServer' method."
      else
        logger.error "Attempted to start the provided server located at #{@config.server.path} (#{serverPath}), but could not find it."

  build: (opts) ->
    return logger.error "Must provide a name for the new project" unless opts.name? and opts.name.length > 0
    skeletonPath = path.join __dirname, 'skeleton'
    currPath = path.join(path.resolve(''), opts.name)

    logger.info "Copying skeleton project over"
    wrench.copyDirSyncRecursive(skeletonPath, currPath)

    # for some insane reason I can't quite figure out
    # won't copy over a public directory, so hack it out here
    logger.info "Cleaning up..."
    newPublicPath = path.join(currPath, 'public')
    oldPublicPath = path.join(currPath, 'publicc')
    fs.renameSync(oldPublicPath, newPublicPath)
    glob "#{currPath}/**/.gitkeep", (err, files) ->
      fs.unlinkSync(file) for file in files

    # remove express files/directories and update config to point to default server
    if opts.noexpress
      logger.info "Removing unnecessary express artifacts"
      fs.unlinkSync(path.join(currPath, "server.coffee"))
      fs.unlinkSync(path.join(currPath, "package.json"))
      wrench.rmdirSyncRecursive(path.join(currPath, "views"))
      wrench.rmdirSyncRecursive(path.join(currPath, "routes"))

      configPath = path.join(currPath, "config.coffee")
      fs.readFile configPath, "ascii", (err, data) ->
        data = data.replace "# server:", "server:"
        data = data.replace "# useDefaultServer: false", "useDefaultServer: true"

        logger.info "Altering configuration to not use express"
        fs.writeFile(configPath, data)
        logger.success "New project creation complete!"
        logger.success "Move into the '#{opts.name}' directory and execute 'mimosa watch --server' to monitor the file system, then start coding!"
    else
      logger.info "Installing node modules "
      currentDir = process.cwd()
      process.chdir currPath
      exec "npm install", (err, sout, serr) ->
        process.chdir currentDir
        logger.success "New project creation complete!"
        logger.success "Move into the '#{opts.name}' directory and execute 'mimosa watch --server' to monitor the file system, then start coding!"

module.exports = new Mimosa