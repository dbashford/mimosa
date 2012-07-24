path = require 'path'
fs =   require 'fs'

requirejs = require 'requirejs'

logger =    require './logger'

class Optimizer

  constructor: ->
    almondInPath  = path.join __dirname, "assets", "almond.js"
    @almondText = fs.readFileSync almondInPath, "ascii"

  optimize: (config) =>
    return unless config.optimize

    return if @alreadyRunning # hack right now
    @alreadyRunning = true

    @setupConfig(config)

    almondOutPath = path.join @config.baseUrl, "almond.js"
    fs.writeFile almondOutPath, @almondText, 'ascii', (err) =>
      return logger.error "Cannot write Almond, #{err}" if err?
      logger.info "Beginning requirejs optimization"
      try
        requirejs.optimize @config, (buildResponse) =>
          logger.success "Requirejs optimization complete.  The compiled file is ready for use.", true
          @done(almondOutPath)
      catch err
        logger.error err
        @done(almondOutPath)


  setupConfig: (config) =>
    unless @config?
      @config = config.require
      @config.baseUrl = path.join config.watch.compiledDir, config.compilers.javascript.directory
      @config.out = path.join @config.baseUrl, config.require.out
      @config.include = [config.require.name]
      @config.insertRequire = [config.require.name]
      @config.wrap = true
      @config.name = 'almond'

  done: (almondOutPath) =>
    @alreadyRunning = false
    fs.unlink almondOutPath

exports.optimize = new Optimizer().optimize