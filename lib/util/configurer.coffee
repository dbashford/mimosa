path = require 'path'
fs =   require 'fs'

wrench = require 'wrench'
logger = require 'logmimosa'
_      = require 'lodash'

moduleManager = require('../modules')

class MimosaConfigurer

  # watch defaults, other defaults reside in modules
  baseDefaults:
    modules: ['lint', 'server', 'require', 'minify']
    watch:
      sourceDir: "assets"
      compiledDir: "public"
      javascriptDir: "javascripts"
      exclude: ["[/\\\\]\\.\\w+$"]
      throttle: 0

  applyAndValidateDefaults: (config, configPath, callback) =>
    moduleNames = config.modules ? @baseDefaults.modules
    moduleManager.getConfiguredModules moduleNames, (modules) =>

      @modules = modules
      config.root = path.dirname(configPath)
      config = @_applyDefaults(config)
      errors = @_validateSettings(config)
      err = if errors.length is 0
        logger.debug "No mimosa config errors"
        config = @_manipulateConfig(config)
        null
      else
        errors

      callback(err, config, modules)

  _moduleDefaults: ->
    defs = {}
    for mod in @modules when mod.defaults?
      _.extend(defs, mod.defaults())
    _.extend(defs, @baseDefaults)
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
    @_extend @_moduleDefaults(), config

  _manipulateConfig: (config) ->
    config.extensions = {javascript: ['js'], css: ['css'], template: [], copy: []}
    config.watch.sourceDir =             path.join config.root, config.watch.sourceDir
    config.watch.compiledDir =           path.join config.root, config.watch.compiledDir
    config.watch.compiledJavascriptDir = path.join config.watch.compiledDir, config.watch.javascriptDir

    if config.watch.exclude?.length > 0
      config.watch.exclude = new RegExp config.watch.exclude.join("|"), "i"

    config

  _validateSettings: (config) ->
    errors = []
    for mod in @modules when mod.validate?
      moduleErrors = mod.validate(config)
      errors.push moduleErrors... if moduleErrors

    if typeof config.watch.sourceDir is "string"
      @_testPathExists(config.watch.sourceDir, "watch.sourceDir", errors)
    else
      errors.push "watch.sourceDir must be a string"

    unless config.isVirgin
      if typeof config.watch.compiledDir is "string"
        if not fs.existsSync(config.watch.compiledDir) and not config.isForceClean
          logger.info "Did not find compiled directory [[ #{config.watch.compiledDir} ]], so making it for you"
          wrench.mkdirSyncRecursive config.watch.compiledDir, 0o0777
      else
        errors.push "watch.compiledDir must be a string"

    if typeof config.watch.javascriptDir is "string"
      jsDir = path.join config.watch.sourceDir, config.watch.javascriptDir
      unless config.isVirgin
        @_testPathExists(jsDir,"watch.javascriptDir", errors)
    else
      errors.push "watch.javascriptDir must be a string"

    if Array.isArray(config.watch.exclude)
      for ex in config.watch.exclude
        unless typeof ex is "string"
          errors.push "watch.exclude must be an array of strings"
          break
    else
      errors.push "watch.exclude must be an array"

    unless typeof config.watch.throttle is "number"
      errors.push "watch.throttle must be a number"

    errors

  _testPathExists: (filePath, name, errors) ->
    unless fs.existsSync filePath
      return errors.push "#{name} (#{filePath}) cannot be found"

    if fs.statSync(filePath).isFile()
      return errors.push "#{name} (#{filePath}) cannot be found, expecting a directory and is a file"

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
      # modules: ['lint', 'server', 'require', 'minify']   # The list of Mimosa modules to use for this application. The defaults
                                                           # (lint, server, require, minify) come bundled with Mimosa and do not
                                                           # need to be installed.  The 'mimosa-' that preceeds all Mimosa module
                                                           # names is assumed, however you can use it if you want.  If a module
                                                           # is listed here that Mimosa is unaware of, Mimosa will attempt to
                                                           # install it.

      # watch:
        # sourceDir: "assets"             # directory location of web assets
        # compiledDir: "public"           # directory location of compiled web assets
        # javascriptDir: "javascripts"    # Location of precompiled javascript (coffeescript for instance), and therefore
                                          # also the location of the compiled javascript.
        # exclude: ["[/\\\\\\\\]\\\\.\\\\w+$"]    # regexes matching the files to be entirely ignored by mimosa, the default matches
                                          # files that start with a period.  Be sure to double escape.
        # throttle: 0                     # number of file adds the watcher handles before taking a 100 millisecond pause to let
                                          # those files finish their processing. This helps avoid EMFILE issues for projects
                                          # containing large numbers of files that all get copied at once. If the throttle is
                                          # set to 0, no throttling is performed. Recommended to leave this set at 0, the
                                          # default, until you start encountering EMFILE problems.

    """

  _configBottom: -> "\n}"

  buildConfigText: =>
    modules = moduleManager.all
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