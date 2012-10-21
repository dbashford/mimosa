path = require 'path'
fs =   require 'fs'

wrench = require 'wrench'
logger = require 'mimosa-logger'
_      = require 'lodash'

modules = require('../modules').all

class MimosaConfigurer

  # watch defaults, other defaults reside in modules
  watchDefaults:
    watch:
      sourceDir: "assets"
      compiledDir: "public"
      javascriptDir: "javascripts"
      exclude: ["[/\\\\]\\.\\w+$"]
      throttle: 0

  applyAndValidateDefaults: (config, configPath, callback) =>
    config.root = path.dirname(configPath)
    config = @_applyDefaults(config)
    errors = @_validateSettings(config)
    err = if errors.length is 0
      logger.debug "No mimosa config errors"
      null
    else
      errors

    callback(err, config)

  _moduleDefaults: ->
    defs = {}
    for mod in modules when mod.defaults?
      _.extend(defs, mod.defaults())
    _.extend(defs, @watchDefaults)
    defs

  _extend: (obj, props) ->
    Object.keys(props).forEach (k) =>
      val = props[k]
      if val? and typeof val is 'object' and not Array.isArray(val)
        @_extend obj[k], val
      else
        obj[k] = val
    obj

  _applyDefaults: (config) ->
    config = @_extend @_moduleDefaults(), config

    config.extensions = {javascript: ['js'], css: ['css'], template: [], copy: []}
    config.watch.sourceDir =             path.join config.root, config.watch.sourceDir
    config.watch.compiledDir =           path.join config.root, config.watch.compiledDir
    config.watch.compiledJavascriptDir = path.join config.watch.compiledDir, config.watch.javascriptDir

    if config.watch.exclude?.length > 0
      config.watch.exclude = new RegExp config.watch.exclude.join("|"), "i"

    config

  _validateSettings: (config) ->
    errors = []
    for mod in modules when mod.validate?
      moduleErrors = mod.validate(config)
      errors.push moduleErrors... if moduleErrors

    @_testPathExists(config.watch.sourceDir, "watch.sourceDir", true, errors)
    unless config.isVirgin
      if !fs.existsSync(config.watch.compiledDir) and !config.isForceClean
        logger.info "Did not find compiled directory [[ #{config.watch.compiledDir} ]], so making it for you"
        wrench.mkdirSyncRecursive config.watch.compiledDir, 0o0777

      @_testPathExists(config.server.path, "server.path", false, errors) if config.isServer and not config.server.useDefaultServer

    jsDir = path.join(config.watch.sourceDir, config.watch.javascriptDir)
    @_testPathExists(jsDir,"watch.javascriptDir", true, errors) unless config.isVirgin

    errors

  _testPathExists: (filePath, name, isDirectory, errors) ->
    unless fs.existsSync filePath
      return errors.push "#{name} (#{filePath}) cannot be found"

    stats = fs.statSync filePath
    if isDirectory and stats.isFile()
      return errors.push "#{name} (#{filePath}) cannot be found, expecting a directory and is a file"

    if not isDirectory and stats.isDirectory()
      return errors.push "#{name} (#{filePath}) cannot be found, expecting a file and is a directory"

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
        # exclude: ["[/\\\\]\\.\\w+$"]    # regexes matching the files to be entirely ignored by mimosa, the default matches
                                          # files that start with a period.  Be sure to double escape.
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