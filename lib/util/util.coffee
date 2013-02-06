path   = require 'path'
fs     = require 'fs'

color  = require('ansi-color').set
logger = require 'logmimosa'
_      = require 'lodash'

configurer = require './configurer'
compilerCentral = require '../modules/compilers'

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

exports.processConfig = (opts, callback) ->

  config = {}
  mainConfigPath = _findConfigPath "mimosa-config"
  if mainConfigPath?
    try
      {config} = require mainConfigPath
    catch err
      return logger.fatal "Improperly formatted configuration file [[ #{mainConfigPath} ]]: #{err}"
  else
    logger.warn "No configuration file found (mimosa-config.coffee/mimosa-config.js), running from current directory using Mimosa's defaults."
    logger.warn "Run 'mimosa config' to copy the default Mimosa configuration to the current directory."

  logger.debug "Your mimosa config:\n#{JSON.stringify(config, null, 2)}"

  if opts.profile
    profileConfigPath = _findConfigPath path.join("profiles", opts.profile)
    if profileConfigPath?
      try
        profileConfig = require(profileConfigPath).config
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