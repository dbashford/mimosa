path = require 'path'
fs =   require 'fs'

wrench = require 'wrench'
logger = require 'mimosa-logger'
_      = require 'lodash'

modules = require('../modules').all

class MimosaConfigurer

  fatalErrors: 0

  # watch defaults, other defaults reside in modules
  watchDefaults:
    watch:
      sourceDir: "assets"
      compiledDir: "public"
      javascriptDir: "javascripts"
      ignored: [".sass-cache"]
      throttle: 0

  applyAndValidateDefaults: (config, configPath, callback) =>
    @root = path.dirname(configPath)
    config = @_applyDefaults(config)
    @_validateSettings(config)
    err = if @fatalErrors is 0
      logger.debug "No mimosa config errors"
      null
    else
      @fatalErrors
    callback(err, config)

  _moduleDefaults: ->
    defs = {}
    for mod in modules when mod.defaults?
      modDefs = mod.defaults()
      console.log modDefs
      _.extend(defs, modDefs)

    _.extend(defs, @watchDefaults)

    console.log defs
    defs

  _extend: (obj, props) ->
    Object.keys(props).forEach (k) =>
      val = props[k]
      if val? and _.isObject(val)
        @_extend obj[k], val
      else
        obj[k] = val
    obj

  _applyDefaults: (config) ->
    config = @_extend @_moduleDefaults(), config

    config.extensions = {javascript: ['js'], css: ['css'], template: [], copy: []}
    config.watch.sourceDir =             path.join @root, config.watch.sourceDir
    config.watch.compiledDir =           path.join @root, config.watch.compiledDir
    config.watch.compiledJavascriptDir = path.join config.watch.compiledDir, config.watch.javascriptDir

    # TODO, validate extensionOverride compiler names

    config.server.path = path.join @root, config.server.path
    if config.server.views.compileWith is "html"
      config.server.views.compileWith = "ejs"
      config.server.views.html = true
    config.server.views.path =         path.join @root, config.server.views.path

    # need to set some requirejs stuf
    if config.isOptimize and config.isMinify
      logger.info "Optimize and minify both selected, setting r.js optimize property to 'none'"
      config.require.optimize.overrides.optimize = "none"

    # helpful shortcuts
    config.requireRegister = config.require.verify.enabled or config.isOptimize

    logger.debug "Full mimosa config:\n#{JSON.stringify(config, null, 2)}"

    config

  _validateSettings: (config) ->
    @_testPathExists(config.watch.sourceDir, "watch.sourceDir", true)
    unless config.isVirgin
      if !fs.existsSync(config.watch.compiledDir) and !config.isForceClean
        logger.info "Did not find compiled directory [[ #{config.watch.compiledDir} ]], so making it for you"
        wrench.mkdirSyncRecursive config.watch.compiledDir, 0o0777

      @_testPathExists(config.server.path, "server.path", false) if config.isServer and not config.server.useDefaultServer

    # TODO, compilers: overrides paths

    jsDir = path.join(config.watch.sourceDir, config.watch.javascriptDir)
    @_testPathExists(jsDir,"watch.javascriptDir", true) unless config.isVirgin

  _testPathExists: (filePath, name, isDirectory) ->
    unless fs.existsSync filePath
      logger.fatal "#{name} (#{filePath}) cannot be found"
      return @fatalErrors++

    stats = fs.statSync filePath
    if (isDirectory and stats.isFile())
      logger.fatal "#{name} (#{filePath}) cannot be found, expecting a directory and is a file"
      return @fatalErrors++

    if (!isDirectory and stats.isDirectory())
      logger.fatal "#{name} (#{filePath}) cannot be found, expecting a file and is a directory"
      return @fatalErrors++

  _configTop: ->
    """
    # All of the below are mimosa defaults and only need to be uncommented
    # in the event you want to override them.
    #
    # IMPORTANT: Be sure to comment out all of the nodes from the base to the
    # option you want to override.  If you want to turn change the source directory
    # you would need to uncomment watch and sourceDir. Also be sure to respect
    # coffeescript indentation rules.  2 spaces per level please!

    exports.config = {
      # watch:
        # sourceDir: "assets"             # directory location of web assets
        # compiledDir: "public"           # directory location of compiled web assets
        # javascriptDir: "javascripts"    # Location of precompiled javascript (coffeescript for instance), and therefore
                                          # also the location of the compiled javascript.
        # ignored: [".sass-cache"]        # files to not watch on file system, any file containing one of the strings listed here
                                          # will be skipped
        # throttle: 0                     # number of file adds the watcher handles before taking a 100 millisecond pause to let
                                          # those files finish their processing. This helps avoid EMFILE issues for projects
                                          # containing large numbers of files that all get copied at once. If the throttle is
                                          # set to 0, no throttling is performed. Recommended to leave this set at 0, the
                                          # default, until you start encountering EMFILE problems.

    """

  _configBottom: -> "\n}"

  buildConfigText: =>
    configText = @_configTop()
    for mod in modules
      if mod.placeholder?
        ph = mod.placeholder()
        configText += ph if ph?
    configText += @_configBottom()
    configText

defs = new MimosaConfigurer()

module.exports =
  applyAndValidateDefaults: defs.applyAndValidateDefaults
  buildConfigText: defs.buildConfigText