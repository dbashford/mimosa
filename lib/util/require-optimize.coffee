requirejs = require 'requirejs'
logger =    require './logger'
path = require 'path'

class Optimizer

  _performOptimization: ->
    if process.env.NODE_ENV is 'production'
      logger.info "Beginning requirejs optimization"
      requirejs.optimize @config, (buildResponse) ->
        logger.success "Requirejs optimization complete.  The compiled file is ready for use.", true

  optimize: (config) =>
    return unless config.require.optimizationEnabled
    unless @config?
      @config = config.require
      @config.baseUrl = path.join(config.root, config.watch.compiledDir, config.compilers.javascript.directory)
      @config.out = path.join(@config.baseUrl, config.require.out)
      @config.include = [config.require.name]
      @config.insertRequire = [config.require.name]
      @config.wrap = true
      @config.name = 'vendor/almond'

    @_performOptimization()

exports.optimize = new Optimizer().optimize