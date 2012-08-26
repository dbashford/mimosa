path = require 'path'
fs =   require 'fs'

_ = require 'lodash'
requirejs = require 'requirejs'

logger =    require '../logger'
requireRegister = require './register'
minifier = require '../minify'

class Optimizer

  constructor: ->
    almondInPath  = path.join __dirname, "..", "assets", "almond.js"
    @almondText = fs.readFileSync almondInPath, "ascii"
    @almondText = minifier.minify(almondInPath, @almondText)

  optimize: (config, fileName) =>
    return unless config.optimize
    if fileName?
      logger.debug "Going to optimize for #{fileName}"

    if @currentlyRunning
      return logger.debug "...but nevermind, optmization is already running."

    @currentlyRunning = true

    if config.require.optimize.inferConfig is false
      logger.debug "Optimizer will not be inferring config"
      ors = config.require.optimize.overrides
      if Object.keys(ors).length is 0
        logger.warn "inferConfig set to false, but no overrides have been provided"
        logger.warn "Cannot run optmization"
        @_done()
      else
        # See https://github.com/jrburke/r.js/issues/262, must verify here to stop r.js from process.exit
        unless ors.name? or ors.include? or ors.modules?
          logger.error "Missing either a 'name', 'include' or 'modules' option in your require overrides"
          logger.warn "Cannot run optmization, require.optimize.overrides is missing key value(s)"
          return @_done()

        unless ors.out? or ors.dir?
          logger.error "Missing either an \"out\" or \"dir\" config value. If using \"appDir\" for a full project optimization, use \"dir\". If you want to optimize to one file, use \"out\"."
          logger.warn "Cannot run optmization, require.optimize.overrides is missing key value(s)"
          return @_done()

        @_executeOptimize config.require.optimize.overrides, @_done
    else
      files = if fileName
        logger.debug "Looking for main modules that need optimizing for file [[ #{fileName} ]]"
        requireRegister.treeBasesForFile(fileName)
      else
        requireRegister.treeBases()

      @_optimizeForFiles(files, config)

  _optimizeForFiles: (files, config) =>
    numFiles = files.length
    logger.debug "Mimosa found #{numFiles} base config files"
    if numFiles is 0
      logger.warn "No main modules found.  Not running optimization."
      return @_done()

    baseUrl = path.join config.watch.compiledDir, config.compilers.javascript.directory
    name = config.require.optimize.overrides.name
    if (name? and name isnt 'almond') or name is null
      logger.info "r.js name changed from default of 'almond', no not using almond.js"
    else
      almondOutPath = path.join baseUrl, "almond.js"
      fs.writeFileSync almondOutPath, @almondText, 'ascii'

    numProcessed = 0
    done = => @_done(almondOutPath) if ++numProcessed >= numFiles

    for file in files
      runConfig = @_setupConfigForModule(config, file, baseUrl)
      logger.info "Beginning requirejs optimization for module [[ #{runConfig.include[0]} ]]"
      @_executeOptimize(runConfig, done)

  _done: (almondOutPath)->
    @currentlyRunning = false
    if almondOutPath?
      logger.debug "Removing Almond at [[ #{almondOutPath} ]]"
      fs.unlinkSync almondOutPath if fs.existsSync almondOutPath
    logger.info "Requirejs optimization complete."

  _executeOptimize: (runConfig, callback) =>
    logger.debug "Mimosa is going to run r.js optimization with the following config:\n#{JSON.stringify(runConfig, null, 2)}"
    try
      requirejs.optimize runConfig, (buildResponse) =>
        logger.success "The compiled file [[ #{runConfig.out} ]] is ready for use.", true
        callback()
    catch err
      logger.error "Error occured inside r.js optimizer, error is as follows... #{err}"
      callback()

  _setupConfigForModule: (config, file, baseUrl) =>
    runConfig = _.extend({}, config.require.optimize.overrides)
    name = @_makeRelativeModulePath(file, baseUrl)

    runConfig.baseUrl = baseUrl             unless runConfig.baseUrl? or runConfig.baseUrl is null
    runConfig.mainConfigFile = file         unless runConfig.mainConfigFile? or runConfig.mainConfigFile is null
    runConfig.findNestedDependencies = true unless runConfig.findNestedDependencies? or runConfig.findNestedDependencies is null
    runConfig.include = [name]              unless runConfig.include? or runConfig.include is null
    runConfig.insertRequire = [name]        unless runConfig.insertRequire? or runConfig.insertRequire is null
    runConfig.wrap = true                   unless runConfig.wrap? or runConfig.wrap is null
    runConfig.name = 'almond'               unless runConfig.name? or runConfig.name is null
    runConfig.out = if runConfig.out
      path.join runConfig.baseUrl, runConfig.out
    else
      path.join runConfig.baseUrl, name + "-built.js"

    runConfig

  _makeRelativeModulePath: (aPath, baseUrl) ->
    aPath.replace(baseUrl + path.sep, '').replace('.js', '')

exports.optimize = new Optimizer().optimize