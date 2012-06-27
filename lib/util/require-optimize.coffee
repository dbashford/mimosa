requirejs = require 'requirejs'
logger =    require './logger'
path = require 'path'

class Optimizer

  optimize: (config) =>
    return unless (config.require.optimizationEnabled and process.env.NODE_ENV is 'production') or
      config.require.forceOptimization

    unless @config?
      @config = config.require
      @config.baseUrl = path.join(config.root, config.watch.compiledDir, config.compilers.javascript.directory)
      @config.out = path.join(@config.baseUrl, config.require.out)
      @config.include = [config.require.name]
      @config.insertRequire = [config.require.name]
      @config.wrap = true
      @config.name = 'vendor/almond'

    logger.info "Beginning requirejs optimization"
    requirejs.optimize @config, (buildResponse) ->
      logger.success "Requirejs optimization complete.  The compiled file is ready for use.", true

exports.optimize = new Optimizer().optimize