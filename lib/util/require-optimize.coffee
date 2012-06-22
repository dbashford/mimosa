requirejs = require 'requirejs'
logger =    require './logger'
path = require 'path'

class Optimizer

  _performOptimization: (config) ->
    if process.env.NODE_ENV is 'production'
      logger.info "Beginning requirejs optimization"
      requirejs.optimize config, (buildResponse) ->
        logger.success "Requirejs optimization complete.  The compiled file is ready for use."

  optimize: (config) =>
    rConfig = config.require
    rConfig.baseUrl = path.join(config.root, config.watch.compiledDir, config.compilers.javascript.directory)
    rConfig.out = path.join(rConfig.baseUrl, config.require.out)
    rConfig.include = config.require.name
    rConfig.insertRequire = config.require.name
    rConfig.wrap = true
    rConfig.name = 'vendor/almond'

    @_performOptimization(rConfig)

exports.optimize = new Optimizer().optimize