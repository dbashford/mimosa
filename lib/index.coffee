require 'sugar'
path =     require 'path'
fs =       require 'fs'
{exec} =   require 'child_process'

program = require 'commander'
express =  require 'express'
wrench =   require 'wrench'
glob =     require 'glob'

logger =   require './util/logger'
defaults = require './util/defaults'
version =  require('../package.json').version
Watcher =  require('./watch/watcher')

class Mimosa

  constructor: ->
    @cli()

  cli: ->
    program.version(version)

    program
      .command('config')
      .description("copy the default Mimosa config into the current folder")
      .action(=> @copyConfig())
      .on '--help', =>
        logger.green('  The config command will copy the default Mimosa config to the current directory.')
        logger.green('  There are no options for the config command.')
        console.log()
        logger.blue( '    $ mimosa config')
        console.log()

    program
      .command('clean')
      .description("clean out all of the compiled assets from the compiled directory")
      .action(=> @processConfig(false, => @clean()))
      .on '--help', =>
        logger.green('  The clean command will remove all of the compiled assets from the configured compiledDir and ')
        logger.green('  any empty directories after the compiled assets are removed. It will also remove any Mimosa')
        logger.green('  copied assets, like template libraries. It will not remove anything that did not originate')
        logger.green('  from the source directory.')
        console.log()
        logger.blue( '    $ mimosa clean')
        console.log()

    program
      .command('build')
      .description("make a single pass through assets and compile them")
      .option("-o, --optimize", "run require.js optimization after building")
      .action( (opts)=> @processConfig(false, => @build(opts)))
      .on '--help', =>
        logger.green('  The build command will make a single pass through your assets and bulid any that need building')
        logger.green('  and then exit.')
        console.log()
        logger.blue( '    $ mimosa build')
        console.log()
        logger.green('  Pass an optimize flag and Mimosa will use requirejs to optimize your assets and provide you with')
        logger.green('  single files for the named requirejs modules. ')
        console.log()
        logger.blue( '    $ mimosa build --optimize')
        logger.blue( '    $ mimosa build -o')
        console.log()

    program
      .command('watch')
      .description("watch the filesystem and compile assets")
      .option("-s, --server", "run a server that will serve up the assets in the compiled directory")
      .action((opts)=> @processConfig opts?.server, => @watch(true, @startServer if opts?.server))
      .on '--help', =>
        logger.green('  The watch command will observe your source directory and compile or copy your assets when they change.')
        logger.green('  When the watch command starts up, it will make an initial pass through your assets and compile or copy')
        logger.green('  any assets that are newer then their companion compiled assets in the compiled directory.  The watch command')
        logger.green('  will remain running when executed, and must be terminated with CNTL-C.')
        console.log()
        logger.blue( '    $ mimosa watch')
        console.log()
        logger.green('  Pass a server flag and Mimosa will start-up a server that will serve up the assets Mimosa compiles.  You have')
        logger.green('  the opportunity, via Mimosa\'s config, to provide Mimosa a hook to your own server if you have one.  If you')
        logger.green('  do not have a server, Mimosa will use an embedded server to serve up the assets.  Server configuration options')
        logger.green('  and explanations can be found in the \'server\' settings in the mimosa-config.')
        console.log()
        logger.blue( '    $ mimosa watch --server')
        logger.blue( '    $ mimosa watch -s')
        console.log()

    program
      .command('new [name]')
      .description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup")
      .option("-n, --noexpress", "do not include express in the application setup")
      .action((name, opts)=> @create(name, opts) )
      .on '--help', =>
        logger.green('  The new command will create a directory using the name provided, and place a default project skeleton')
        logger.green('  inside of it.  That project skeleton will by default include an basic Express app, with sample routes')
        logger.green('  and views.  It will also include some sample assets (CoffeeScript, SASS, Handlebars) to get you started.')
        console.log()
        logger.blue( '    $ mimosa new [nameOfProject]')
        console.log()
        logger.green('  Pass a \'noexpress flag\' to not include the basic Express app.  With this set up, if you choose to have')
        logger.green('  Mimosa serve up your assets, it will do so with an embedded Mimosa Express app, and not with one inside')
        logger.green('  your project')
        console.log()
        logger.blue( '    $ mimosa watch --noexpress')
        logger.blue( '    $ mimosa watch -n')
        console.log()

    program.parse process.argv

  processConfig: (server, callback) ->
    configPath = path.resolve 'mimosa-config.coffee'
    try
      {config} = require configPath
    catch err
      logger.warn "No configuration file found (mimosa-config.coffee), using all defaults."
      logger.warn "Run 'mimosa config' to copy the default Mimosa configuration to the current directory."
      config = {}

    defaults config, server, (err, newConfig) =>
      if err
        logger.fatal "Unable to start Mimosa, #{err} configuration(s) problems listed above."
        process.exit 1
      else
        newConfig.root = path.dirname configPath
        @config = newConfig
        callback()

  clean: ->
    srcDir = @config.watch.sourceDir
    files = wrench.readdirSyncRecursive(srcDir)

    compilers = @fetchCompilers()

    compiler.cleanup() for compiler in compilers when compiler.cleanup?

    for file in files
      isDirectory = fs.statSync(path.join(srcDir, file)).isDirectory()
      continue if isDirectory

      compiledPath = path.join @config.root, @config.watch.compiledDir, file

      extension = path.extname(file)
      if extension?.length > 0
        extension = extension.substring(1)
        compiler = compilers.find (comp) ->
          for ext in comp.getExtensions()
            return true if extension is ext
          return false
        if compiler? and compiler.getOutExtension()
          compiledPath = compiledPath.replace(/\.\w+$/, ".#{compiler.getOutExtension()}")

      fs.unlinkSync compiledPath if path.existsSync compiledPath

    directories = files.filter (f) -> fs.statSync(path.join(srcDir, f)).isDirectory()
    directories = directories.sortBy('length', true)
    for dir in directories
      dirPath = path.join(@config.root, @config.watch.compiledDir, dir)
      if path.existsSync dirPath
        fs.rmdir dirPath, (err) ->
          if err?.code is not "ENOTEMPTY"
            logger.error "Unable to delete directory, #{dirPath}"
            logger.error err

    logger.success "#{path.join(@config.root, @config.watch.compiledDir)} has been cleaned."

  copyConfig: ->
    configPath = path.join __dirname, 'skeleton', "mimosa-config.coffee"
    configFileContents = fs.readFileSync(configPath)
    currPath = path.join path.resolve(''), "mimosa-config.coffee"
    fs.writeFile currPath, configFileContents, 'ascii'
    logger.success "Copied default config file into current directory."

  build: (opts) ->
    logger.info "Beginning build"
    if opts.optimize then @config.require.forceOptimization = true
    @watch(false, @buildFinished)

  buildFinished: -> logger.success("Finished build")

  fetchCompilers: (persist = false) ->
    compilers = [new (require("./compilers/copy"))(@config)]
    for category, catConfig of @config.compilers
      try
        continue if catConfig.compileWith is "none"
        compiler = require("./compilers/#{category}/#{catConfig.compileWith}")
        compilers.push(new compiler(@config))
        logger.info "Adding compiler: #{category}/#{catConfig.compileWith}" if persist
      catch err
        logger.info "Unable to find matching compiler for #{category}/#{catConfig.compileWith}: #{err}"
    compilers

  watch: (persist, callback) ->
    compilers = @fetchCompilers(persist)
    new Watcher(@config, compilers, persist, callback)

  startServer: =>
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

    production = process.env.NODE_ENV is 'production'
    reload = @config.server.useReload and not production
    useBuilt = production and @config.require.optimizationEnabled

    app.get '/', (req, res) =>
      res.render 'index', { title: 'Mimosa\'s Express', reload:reload, production:production, useBuilt:useBuilt}

    app.listen @config.server.port

    logger.success "Mimosa's bundled Express started at http://localhost:#{@config.server.port}/"

  startProvidedServer: ->
    serverPath = path.resolve @config.server.path
    path.exists serverPath, (exists) =>
      if exists
        server = require serverPath
        if server.startServer
          logger.info "Mimosa is starting the Express server at #{@config.server.path}"
          server.startServer(@config.watch.compiledDir, @config.server.useReload, @config.require.optimizationEnabled)
        else
          logger.error "Found provided server located at #{@config.server.path} (#{serverPath}) but it does not contain a 'startServer' method."
      else
        logger.error "Attempted to start the provided server located at #{@config.server.path} (#{serverPath}), but could not find it."

  create: (name, opts) ->
    return logger.error "Must provide a name for the new project" unless name? and name.length > 0
    skeletonPath = path.join __dirname, 'skeleton'
    currPath = path.join(path.resolve(''), name)

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

      configPath = path.join(currPath, "mimosa-config.coffee")
      fs.readFile configPath, "ascii", (err, data) ->
        data = data.replace "# server:", "server:"
        data = data.replace "# useDefaultServer: false", "useDefaultServer: true"

        logger.info "Altering configuration to not use express"
        fs.writeFile(configPath, data)
        logger.success "New project creation complete!"
        logger.success "Move into the '#{name}' directory and execute 'mimosa watch --server' to monitor the file system, then start coding!"
    else
      logger.info "Installing node modules "
      currentDir = process.cwd()
      process.chdir currPath
      exec "npm install", (err, sout, serr) ->
        process.chdir currentDir
        logger.success "New project creation complete!"
        logger.success "Move into the '#{name}' directory and execute 'mimosa watch --server' to monitor the file system, then start coding!"

module.exports = new Mimosa