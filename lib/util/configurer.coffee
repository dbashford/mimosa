"use strict"

path = require 'path'
fs =   require 'fs'

wrench = require 'wrench'
logger = require 'logmimosa'
_      = require 'lodash'

util   = require './util'
validators = require './validators'
moduleManager = require '../modules'

class MimosaConfigurer

  # watch defaults, other defaults reside in modules
  baseDefaults:
    minMimosaVersion:null
    modules: ['lint', 'server', 'require', 'minify', 'live-reload']
    watch:
      sourceDir: "assets"
      compiledDir: "public"
      javascriptDir: "javascripts"
      exclude: [/[/\\](\.|~)[^/\\]+$/]
      throttle: 0

  applyAndValidateDefaults: (config, configPath, callback) =>
    moduleNames = config.modules ? @baseDefaults.modules
    moduleManager.getConfiguredModules moduleNames, (modules) =>

      @modules = modules
      config.root = configPath
      config = @_applyDefaults(config)
      [errors, config] = @_validateSettings(config)
      err = if errors.length is 0
        logger.debug "No mimosa config errors"
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
      if val? and typeof val is 'object' and not Array.isArray(val) and typeof obj[k] is typeof val
        @_extend obj[k], val
      else
        obj[k] = val
    obj

  _applyDefaults: (config) ->
    @_extend @_moduleDefaults(), config

  _manipulateConfig: (config) ->
    config.extensions = {javascript: ['js'], css: ['css'], template: [], copy: []}
    config.watch.compiledJavascriptDir = validators.determinePath config.watch.javascriptDir, config.watch.compiledDir
    config

  _validateSettings: (config) ->
    errors = @_validateWatchConfig(config)

    if errors.length is 0
      config = @_manipulateConfig(config)

    for mod in @modules when mod.validate?

      if mod.defaults?
        config = _.clone(config, true)
        allConfigKeys = Object.keys(config)
        defaults = mod.defaults()
        modKeys = if typeof defaults is "object" and not Array.isArray()
          Object.keys(defaults)
        else
          []

        allConfigKeys.forEach (key) ->
          unless modKeys.indexOf(key) > -1
            if typeof config[key] is "object"
              util.deepFreeze(config[key])
      else
        util.deepFreeze(config)

      moduleErrors = mod.validate(config, validators)
      errors.push moduleErrors... if moduleErrors

    # return to unfrozen
    config = _.clone(config, true)

    [errors, config]

  _validateWatchConfig: (config) =>
    errors = []

    if config.minMimosaVersion?
      if config.minMimosaVersion.match(/^(\d+\.){2}(\d+)$/)
        currVersion =  require('../../package.json').version
        versionPieces = currVersion.split('.')
        minVersionPieces = config.minMimosaVersion.split('.')

        isHigher = false
        for i in [0..2]
          if +versionPieces[i] > +minVersionPieces[i]
            isHigher = true

          unless isHigher
            if +versionPieces[i] < +minVersionPieces[i]
              return ["Your version of Mimosa [[ #{currVersion} ]] is less than the required version for this project [[ #{config.minMimosaVersion} ]]"]
      else
        errors.push "minMimosaVersion must take the form 'number.number.number', ex: '0.7.0'"

    validators.multiPathMustExist(errors, "watch.sourceDir", config.watch.sourceDir, config.root)

    unless config.isVirgin
      if typeof config.watch.compiledDir is "string"
        config.watch.compiledDir = validators.determinePath config.watch.compiledDir, config.root
        if not fs.existsSync(config.watch.compiledDir) and not config.isForceClean
          logger.info "Did not find compiled directory [[ #{config.watch.compiledDir} ]], so making it for you"
          wrench.mkdirSyncRecursive config.watch.compiledDir, 0o0777
      else
        errors.push "watch.compiledDir must be a string"

    if typeof config.watch.javascriptDir is "string"
      jsDir = path.join config.watch.sourceDir, config.watch.javascriptDir
      unless config.isVirgin
        validators.doesPathExist(errors,"watch.javascriptDir", jsDir)
    else
      errors.push "watch.javascriptDir must be a string"

    if Array.isArray(config.watch.exclude)
       regexes = []
       newExclude = []
       for exclude in config.watch.exclude
         if typeof exclude is "string"
           newExclude.push validators.determinePath exclude, config.watch.sourceDir
         else if exclude instanceof RegExp
           regexes.push exclude.source
         else
           errors.push "watch.exclude must be an array of strings and/or regexes."
           break

       if regexes.length > 0
         config.watch.excludeRegex = new RegExp regexes.join("|"), "i"

       config.watch.exclude = newExclude
    else
      errors.push "watch.exclude must be an array"

    unless typeof config.watch.throttle is "number"
      errors.push "watch.throttle must be a number"

    errors

  _configTop: ->
    """
    # All of the below are mimosa defaults and only need to be uncommented in the event you want
    # to override them.
    #
    # IMPORTANT: Be sure to comment out all of the nodes from the base to the option you want to
    # override. If you want to turn change the source directory you would need to uncomment watch
    # and sourceDir. Also be sure to respect coffeescript indentation rules.  2 spaces per level
    # please!

    exports.config = {

      # minMimosaVersion:null   # The minimum Mimosa version that must be installed to use the
                                # project. Defaults to null, which means Mimosa will not check
                                # the version.  This is a no-nonsense way for big teams to ensure
                                # everyone stays up to date with the blessed Mimosa version for a
                                # project.

      ###
      The list of Mimosa modules to use for this application. The defaults (lint, server, require,
      minify, live-reload) come bundled with Mimosa and do not need to be installed.  The 'mimosa-'
      that preceeds all Mimosa module names is assumed, however you can use it if you want.  If a
      module is listed here that Mimosa is unaware of, Mimosa will attempt to install it.
      ###
      # modules: ['lint', 'server', 'require', 'minify', 'live-reload']

      # watch:
        # sourceDir: "assets"                # directory location of web assets, can be relative to
                                             # the project root, or absolute
        # compiledDir: "public"              # directory location of compiled web assets, can be
                                             # relative to the project root, or absolute
        # javascriptDir: "javascripts"       # Location of precompiled javascript (i.e.
                                             # coffeescript), must be relative to sourceDir
        # exclude: [/[/\\\\](\\.|~)[^/\\\\]+$/]   # regexes matching the files to be entirely
                                             # ignored by mimosa, the default matches files that
                                             # start with a period.
        # throttle: 0                        # number of file adds the watcher handles before
                                             # taking a 100 millisecond pause to let those files
                                             # finish their processing. This helps avoid EMFILE
                                             # issues for projects containing large numbers of
                                             # files that all get copied at once. If the throttle
                                             # is set to 0, no throttling is performed. Recommended
                                             # to leave this set at 0, thedefault, until you start
                                             # encountering EMFILE problems.

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

    if moduleManager.configModuleString?
      configText = configText.replace("  # modules: ['lint', 'server', 'require', 'minify', 'live-reload']", "  modules: " + moduleManager.configModuleString)

    configText

defs = new MimosaConfigurer()

module.exports =
  applyAndValidateDefaults: defs.applyAndValidateDefaults
  buildConfigText: defs.buildConfigText