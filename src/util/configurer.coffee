"use strict"

path = require 'path'
fs =   require 'fs'

wrench = require 'wrench'
logger = require 'logmimosa'
_      = require 'lodash'
coffeescript = require 'coffee-script'
validators =   require 'validatemimosa'

moduleManager = require '../modules'
Module =        require 'module'
fileUtils =     require '../util/file'

PRECOMPILE_FUN_REGION_START_RE         = /^(.*)\smimosa-config:\s*{/
PRECOMPILE_FUN_REGION_END_RE           = /\smimosa-config:\s*}/
PRECOMPILE_FUN_REGION_SEARCH_LINES_MAX = 5
PRECOMPILE_FUN_REGION_LINES_MAX        = 100

baseDefaults =
  minMimosaVersion:null
  requiredMimosaVersion:null
  modules: [ 'copy', 'jshint', 'csslint', 'server', 'require', 'minify-js', 'minify-css', 'live-reload', 'bower']
  resortCompilers: true
  timer:
    enabled: false
  watch:
    sourceDir: "assets"
    compiledDir: "public"
    javascriptDir: "javascripts"
    exclude: [/[/\\](\.|~)[^/\\]+$/]
    throttle: 0
    interval: 100
    binaryInterval: 300
    usePolling: true
    delay: 0
  vendor:
    javascripts: "javascripts/vendor"
    stylesheets: "stylesheets/vendor"

_extend = (obj, props, resetObjAndRetry) ->
  Object.keys(props).forEach (k) ->
    val = props[k]

    # if value is an object, but not an array or not a regex, might need to recurse
    if val? and (typeof val is 'object') and (not Array.isArray(val)) and (not (val instanceof RegExp))

      if obj is null
        # value is an object, but the object to override is null.
        # need to reset it back up a call in the call chain and retry
        # the _extend, resetting here results in properties not sticking
        resetObjAndRetry()
      else
        # if everything is still an object, need to recurse again
        # to pull child properties
        if (typeof obj[k] is typeof val)
          _extend obj[k], val, ->
            obj[k] = {}
            _extend obj[k], val
        else
          obj[k] = val
    else
      obj[k] = val
  obj

_findConfigPath = (file) ->
  for ext in [".coffee", ".js", ""]
    configPath = path.resolve("#{file}#{ext}")
    return configPath if fs.existsSync configPath

_validateWatchConfig = (config) ->
  errors = []

  if config.minMimosaVersion? and config.requiredMimosaVersion?
    return ["Cannot have both minMimosaVersion and requiredMimosaVersion"]

  if config.minMimosaVersion?
    if config.minMimosaVersion.match(/^(\d+\.){2}(\d+)$/)
      currVersion =  require('../../package.json').version
      versionPieces = currVersion.split('.')
      minVersionPieces = config.minMimosaVersion.split('.')

      isHigher = false
      for i in [0..2]
        piece = minVersionPieces[i].split('-')[0]
        vPiece = versionPieces[i].split('-')[0]
        if +vPiece > +piece
          isHigher = true

        unless isHigher
          if +vPiece < +piece
            return ["Your version of Mimosa [[ #{currVersion} ]] is less than the required minimum version for this project [[ #{config.minMimosaVersion} ]]"]
    else
      errors.push "minMimosaVersion must take the form 'number.number.number', ex: '1.1.0'"

  if config.requiredMimosaVersion?
    if config.requiredMimosaVersion.match(/^(\d+\.){2}(\d+)$/)
      currVersion = require('../../package.json').version
      unless currVersion is config.requiredMimosaVersion
        return ["Your version of Mimosa [[ #{currVersion} ]] does not match the required version for this project [[ #{config.requiredMimosaVersion} ]]"]
    else
      errors.push "requiredMimosaVersion must take the form 'number.number.number', ex: '1.1.0'"

  config.watch.sourceDir = validators.multiPathMustExist(errors, "watch.sourceDir", config.watch.sourceDir, config.root)

  return errors if errors.length > 0

  if typeof config.watch.compiledDir is "string"
    config.watch.compiledDir = validators.determinePath config.watch.compiledDir, config.root
    if not fs.existsSync(config.watch.compiledDir) and not config.isForceClean
      if config.logger?.info?
        if config.logger.info.enabled
          logger.info "Did not find compiled directory [[ #{config.watch.compiledDir} ]], so making it for you"
      else
        logger.info "Did not find compiled directory [[ #{config.watch.compiledDir} ]], so making it for you"
      wrench.mkdirSyncRecursive config.watch.compiledDir, 0o0777
  else
    errors.push "watch.compiledDir must be a string"

  if typeof config.watch.javascriptDir is "string"
    jsDir = path.join config.watch.sourceDir, config.watch.javascriptDir
    validators.doesPathExist(errors,"watch.javascriptDir", jsDir)
  else
    if config.watch.javascriptDir is null
      # Allow to blank out javascriptDir when not strictly web app
      config.watch.javascriptDir = ""
    else
      errors.push "watch.javascriptDir must be a string or null"

  validators.ifExistsFileExcludeWithRegexAndString(errors, "watch.exclude", config.watch, config.watch.sourceDir)

  unless typeof config.watch.throttle is "number"
    errors.push "watch.throttle must be a number"

  unless typeof config.watch.interval is "number"
    errors.push "watch.interval must be a number"

  unless typeof config.watch.binaryInterval is "number"
    errors.push "watch.binaryInterval must be a number"

  if validators.ifExistsIsBoolean(errors, "watch.usePolling", config.watch.usePolling)
    if process.platform isnt 'win32' and config.watch.usePolling is false
      msg = """
          You have turned polling off (usePolling:false) but you are on not on Windows. If you
          experience EMFILE issues, this is why. usePolling:false does not function properly on
          other operating systems.
        """
      if config.logger?.warn?
        if config.logger.warn.enabled
          logger.info msg
      else
        logger.info msg

  if validators.ifExistsIsObject(errors, "vendor config", config.vendor)
    if validators.ifExistsIsString(errors, "vendor.javascripts", config.vendor.javascripts)
      js = config.vendor.javascripts.split('/').join(path.sep)
      config.vendor.javascripts = path.join config.watch.sourceDir, js

    if validators.ifExistsIsString(errors, "vendor.stylesheets", config.vendor.stylesheets)
      ss = config.vendor.stylesheets.split('/').join(path.sep)
      config.vendor.stylesheets = path.join config.watch.sourceDir, ss

  errors

_requireConfig = (configPath) ->
  extname = path.extname configPath
  if extname
    if extname is ".coffee"
      coffeescript.register()
    require configPath
  else
    raw = fs.readFileSync configPath, "utf8"
    # Strip UTF-8 BOM.
    config = if raw.charCodeAt(0) is 0xFEFF then raw.substring 1 else raw
    precompileFunSource = _extractPrecompileFunctionSource config
    if precompileFunSource.length > 0
      try
        config = eval("(#{precompileFunSource.replace /;\s*$/, ''})")(config)
      catch err
        if err instanceof SyntaxError
          err.message = "[precompile region] " + err.message
        throw err
    configModule = new Module path.resolve(configPath)
    configModule.filename = configModule.id
    configModule.paths = Module._nodeModulePaths path.dirname(configModule.id)
    configModule._compile config, configPath
    configModule.loaded = yes
    configModule.exports

# Get source of bootstrap function for precompiling mimosa-config file.
#
# Function region is bounded by required marker lines which aren't included
# in returned function source. Prefix of start marker line is stripped from
# every function source line.
#
# If function region wasn't found or exceeded limit of lines, empty string
# is returned.
_extractPrecompileFunctionSource = (configSource) ->
  pos = configLinesRead = functionRegionLinesRead = 0

  while (pos < configSource.length) and
        (if functionRegionLinesRead
          functionRegionLinesRead < PRECOMPILE_FUN_REGION_LINES_MAX
        else
          configLinesRead < PRECOMPILE_FUN_REGION_SEARCH_LINES_MAX)

    # Find next source line.
    newlinePos = configSource.indexOf "\n", pos
    newlinePos = configSource.length if newlinePos == -1
    sourceLine = configSource.substr pos, (newlinePos - pos)
    pos = newlinePos + 1

    unless functionRegionLinesRead
      # Test read source line for being marker of function region start.
      if markerLinePrefix = PRECOMPILE_FUN_REGION_START_RE.exec(sourceLine)?[1]
        functionRegionLinesRead = 1
        functionSource = ""
      else
        configLinesRead++
    else
      # Check if marker of function region end was just read.
      return functionSource if PRECOMPILE_FUN_REGION_END_RE.test sourceLine
      functionRegionLinesRead++
      functionSource += "#{sourceLine.replace markerLinePrefix, ''}\n"

  return ""

_setUpHelpers = (config) ->
  config.helpers =
    file:
      write: fileUtils.writeFile

  config.log = logger

_validateSettings = (config, modules) ->
  errors = _validateWatchConfig(config)

  if errors.length is 0
    config.extensions =
      javascript: ['js']
      css: ['css']
      template: []
      copy: []
      misc:[]
    config.watch.compiledJavascriptDir = validators.determinePath config.watch.javascriptDir, config.watch.compiledDir
  else
    return [errors, {}]

  currentlyNeedsClean = false
  for mod in modules
    continue unless mod.validate?

    moduleErrors = mod.validate config, validators
    if moduleErrors? and Array.isArray(moduleErrors) and moduleErrors.length
      errors.push moduleErrors...
    else
      if not currentlyNeedsClean and config.needsClean
        currentlyNeedsClean = true
        logger.debug "The #{mod.__mimosaModuleName} module has requested a clean be performed before building the application"

  [errors, config]

_moduleDefaults = (modules) ->
  defs = {}
  for mod in modules when mod.defaults?
    _.extend(defs, mod.defaults())
  _.extend(defs, baseDefaults)
  defs

_applyAndValidateDefaults = (config, callback) ->
  moduleNames = config.modules ? baseDefaults.modules
  moduleManager.getConfiguredModules moduleNames, (modules) ->
    config.root = process.cwd()
    config = _extend _moduleDefaults(modules), config
    _setUpHelpers(config)
    [errors, config] = _validateSettings(config, modules)
    err = if errors.length is 0
      logger.debug "No mimosa config errors"
      null
    else
      errors

    callback(err, config, modules)

processConfig = (opts, callback) ->
  config = {}
  mainConfigPath = _findConfigPath "mimosa-config"
  if mainConfigPath?
    try
      {config} = _requireConfig mainConfigPath
    catch err
      return logger.fatal "Improperly formatted configuration file [[ #{mainConfigPath} ]]: #{err}"
  else
    logger.warn "No configuration file found (mimosa-config.coffee/mimosa-config.js/mimosa-config), running from current directory using Mimosa's defaults."
    logger.warn "Run 'mimosa config' to copy the default Mimosa configuration to the current directory."

  defaultProfileLocation = path.join( process.cwd(), ".mimosa_profile")
  if fs.existsSync( defaultProfileLocation )
    defaultProfileText = fs.readFileSync( defaultProfileLocation, "utf8" )
    if defaultProfileText.trim().length > 0
      defaultProfiles = defaultProfileText.split("\n")
      if opts.profile
        opts.profile = [defaultProfiles, opts.profile].join('#')
      else
        opts.profile = defaultProfiles.join("#")

  if opts.profile
    logger.info( "Applying build profiles:", opts.profile.split("#").join(", ") )

    unless config.profileLocation
      config.profileLocation = "profiles"

    opts.profile.split("#").forEach (profileName) ->

      profileConfigPath = _findConfigPath path.join(config.profileLocation, profileName)
      if profileConfigPath?
        try
          profileConfig = _requireConfig(profileConfigPath).config
        catch err
          return logger.fatal "Improperly formatted configuration file [[ #{profileConfigPath} ]]: #{err}"

        if logger.isDebug()
          logger.debug "Profile config:\n#{JSON.stringify(profileConfig, null, 2)}"

        config = _extend config, profileConfig

        if logger.isDebug()
          logger.debug "mimosa config after profile applied:\n#{JSON.stringify(config, null, 2)}"
      else
        return logger.fatal "Profile provided but not found at [[ #{path.join('profiles', profileName)} ]]"

  config.isServer =    opts?.server
  config.isOptimize =  opts?.optimize
  config.isMinify =    opts?.minify
  config.isForceClean = opts?.force
  config.isClean =     opts?.clean
  config.isBuild =     opts?.build
  config.isWatch =     opts?.watch
  config.isPackage =   opts?.package
  config.isInstall =   opts?.install
  config.exitOnError = opts?.errorout

  _applyAndValidateDefaults config, (err, newConfig, modules) ->
    if err
      logger.error "Unable to start Mimosa for the following reason(s):\n * #{err.join('\n * ')} "
      process.exit 1
    else
      _setModulesIntoConfig newConfig
      logger.setConfig newConfig

      if logger.isDebug()
        util = require('util')
        logger.debug "******************"
        logger.debug "Your mimosa config:\n#{JSON.stringify(config, null, 2)}"
        logger.debug "******************"
        logger.debug "Full mimosa config:\n#{util.inspect(newConfig)}"
        logger.debug "******************"

      callback newConfig, modules

_setModulesIntoConfig = (config) ->
  config.installedModules = {}
  moduleManager.getConfiguredModules().forEach  (mod) ->
    config.installedModules[mod.__mimosaModuleName] = mod

module.exports = processConfig
