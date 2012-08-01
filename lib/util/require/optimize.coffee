path = require 'path'
fs =   require 'fs'

requirejs = require 'requirejs'

logger =    require '../logger'

_ = require 'lodash'

requireRegister = require './register'

class Optimizer

  constructor: ->
    almondInPath  = path.join __dirname, "..", "assets", "almond.js"
    @almondText = fs.readFileSync almondInPath, "ascii"

  optimize: (config, fileName) =>
    return unless config.optimize
    return if @alreadyRunning # hack right now
    @alreadyRunning = true

    files = if fileName then requireRegister.treeBasesForFile(fileName) else requireRegister.treeBases()
    numFiles = files.length
    numProcessed = 0
    done = (almondOutPath) =>
      if ++numProcessed >= numFiles
        @alreadyRunning = false
        logger.info "Cleaning up..."
        fs.unlink almondOutPath
        logger.info "Requirejs optimization complete."

    if files?.length > 0
      baseUrl = path.join config.watch.compiledDir, config.compilers.javascript.directory
      almondOutPath = path.join baseUrl, "almond.js"
      fs.writeFile almondOutPath, @almondText, 'ascii', (err) =>
        return logger.error "Cannot write Almond, #{err}" if err?
        for file in files
          runConfig = @setupConfig(config, file, baseUrl)
          logger.info "Beginning requirejs optimization for module [[#{runConfig.include[0]}]]"
          try
            requirejs.optimize runConfig, (buildResponse) =>
              logger.success "The compiled file [[#{runConfig.out}]] is ready for use.", true
              done(almondOutPath)
          catch err
            logger.error err
            done(almondOutPath)

  setupConfig: (config, file, baseUrl) =>
    runConfig = _.extend({}, config.require.optimize)
    runConfig.baseUrl = baseUrl unless runConfig.baseUrl

    name = file.replace(runConfig.baseUrl + path.sep, '').replace('.js', '')

    paths = {}
    for alias, configPath of requireRegister.configPaths(file)
      paths[alias] = configPath.replace(runConfig.baseUrl + path.sep, '').replace('.js', '')

    runConfig.paths = paths          unless runConfig.paths
    runConfig.include = [name]       unless runConfig.include
    runConfig.insertRequire = [name] unless runConfig.insertRequire
    runConfig.wrap = true            unless runConfig.wrap
    runConfig.name = 'almond'        unless runConfig.name
    runConfig.out = if runConfig.out
      path.join runConfig.baseUrl, runConfig.out
    else
      path.join runConfig.baseUrl, name + "-built.js"

    runConfig

exports.optimize = new Optimizer().optimize