path   = require 'path'
fs     = require 'fs'

color  = require('ansi-color').set
logger = require 'logmimosa'
_      = require 'lodash'

configurer = require './configurer'
compilerCentral = require '../modules/compilers'

PRECOMPILE_FUN_REGION_START_RE         = /^(.*)\smimosa-config:\s*{/
PRECOMPILE_FUN_REGION_END_RE           = /\smimosa-config:\s*}/
PRECOMPILE_FUN_REGION_SEARCH_LINES_MAX = 5
PRECOMPILE_FUN_REGION_LINES_MAX        = 100

exports.projectPossibilities = (callback) ->
  compilers = compilerCentral.compilersByType()

  # just need to check SASS
  for comp in compilers.css
    # this won't work as is if a second compiler needs to shell out
    if comp.checkIfExists?
      comp.checkIfExists (exists) =>
        unless exists
          logger.debug "Compiler for file [[ #{comp.fileName} ]], is not installed/available"
          comp.prettyName = comp.prettyName + color(" (This is not installed and would need to be before use)", "yellow+bold")
        callback(compilers)
      break

exports.requireConfig = requireConfig = (configPath) ->
  if path.extname configPath
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
    configModule = new (require "module") configPath
    configModule._compile config, configPath
    configModule.exports

exports.processConfig = (opts, callback) ->

  config = {}
  mainConfigPath = _findConfigPath "mimosa-config"
  if mainConfigPath?
    try
      {config} = requireConfig mainConfigPath
    catch err
      return logger.fatal "Improperly formatted configuration file [[ #{mainConfigPath} ]]: #{err}"
  else
    logger.warn "No configuration file found (mimosa-config.coffee/mimosa-config.js), running from current directory using Mimosa's defaults."
    logger.warn "Run 'mimosa config' to copy the default Mimosa configuration to the current directory."

  logger.debug "Your mimosa config:\n#{JSON.stringify(config, null, 2)}"

  if opts.profile
    unless config.profileLocation
      config.profileLocation = "profiles"

    profileConfigPath = _findConfigPath path.join(config.profileLocation, opts.profile)
    if profileConfigPath?
      try
        profileConfig = requireConfig(profileConfigPath).config
      catch err
        return logger.fatal "Improperly formatted configuration file [[ #{profileConfigPath} ]]: #{err}"

      logger.debug "Profile config:\n#{JSON.stringify(profileConfig, null, 2)}"

      config = configurer.extend(config, profileConfig)
      logger.debug "mimosa config after profile applied:\n#{JSON.stringify(config, null, 2)}"
    else
      return logger.fatal "Profile provided but not found at [[ #{path.join('profiles', opts.profile)} ]]"

  config.isVirgin =     opts?.virgin
  config.isServer =     opts?.server
  config.isOptimize =   opts?.optimize
  config.isMinify =     opts?.minify
  config.isForceClean = opts?.force
  config.isClean =      opts?.clean
  config.isBuild =      opts?.build
  config.isWatch =      opts?.watch
  config.isPackage =    opts?.package
  config.isInstall =    opts?.install

  configurer.applyAndValidateDefaults config, (err, newConfig, modules) =>
    if err
      logger.error "Unable to start Mimosa for the following reason(s):\n * #{err.join('\n * ')} "
      process.exit 1
    else
      logger.debug "Full mimosa config:\n#{JSON.stringify(newConfig, null, 2)}"
      logger.setConfig(newConfig)
      callback(newConfig, modules)

exports.deepFreeze = (o) ->
  if o?
    Object.freeze(o)
    Object.getOwnPropertyNames(o).forEach (prop) =>
      if o.hasOwnProperty(prop) and o[prop] isnt null and
      (typeof o[prop] is "object" || typeof o[prop] is "function") and
      not Object.isFrozen(o[prop])
        exports.deepFreeze o[prop]

_findConfigPath = (file) ->
  configCoffee = path.resolve("#{file}.coffee")
  if fs.existsSync configCoffee
    configCoffee
  else
    configJs = path.resolve("#{file}.js")
    if fs.existsSync configJs
      configJs


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
