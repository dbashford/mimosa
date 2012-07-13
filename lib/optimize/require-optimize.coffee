requirejs = require 'requirejs'
logger =    require '../util/logger'
path = require 'path'
fs = require 'fs'

class Optimizer

  optimize: (config) =>
    return if @alreadyRunning # hack right now
    @alreadyRunning = true

    return unless (config.require.optimizationEnabled and process.env.NODE_ENV is 'production') or
      config.require.forceOptimization

    unless @config?
      @config = config.require
      @config.baseUrl = path.join(config.watch.compiledDir, config.compilers.javascript.directory)
      @config.out = path.join(@config.baseUrl, config.require.out)
      @config.include = [config.require.name]
      @config.insertRequire = [config.require.name]
      @config.wrap = true
      @config.name = 'almond'

    almondInPath  = path.join(__dirname, "almond.js")
    almondOutPath = path.join(@config.baseUrl, "almond.js")
    fs.readFile almondInPath, "ascii", (err, data) =>
      return logger.error "Cannot read Almond" if err?
      fs.writeFile almondOutPath, data, 'ascii', (err) =>
        return logger.error "Cannot write Almond" if err?
        logger.info "Beginning requirejs optimization"
        requirejs.optimize @config, (buildResponse) =>
          logger.success "Requirejs optimization complete.  The compiled file is ready for use.", true
          fs.unlink almondOutPath
          @alreadyRunning = false

exports.optimize = new Optimizer().optimize