path  = require 'path'
fs    = require 'fs'

color = require('ansi-color').set
_     = require 'lodash'

logger = require '../../util/logger'
fileUtils = require '../../util/file'

defaults = require './defaults'

baseDirRegex = /([^[\/\\\\]*]*)$/

gatherProjectPossibilities = (callback) ->
  compilerPath = path.join __dirname, '..', '..', 'compilers'
  files = fileUtils.glob "#{compilerPath}/**/*-compiler.coffee"
  logger.debug "Compilers:\n#{files.join('\n')}"
  compilers = {css:[], javascript:[], template:[]}

  for file in files
    comp = require(file)
    comp.fileName = path.basename(file, ".coffee").replace("-compiler","")
    key = baseDirRegex.exec(path.dirname(file))[0]
    compilers[key].push comp

  for comp in compilers.css
    # just need to check SASS
    if comp.checkIfExists?
      comp.checkIfExists (exists) =>
        unless exists
          logger.debug "Compiler for file [[ #{comp.fileName} ]], is not installed/available"
          comp.prettyName = comp.prettyName + color(" (This is not installed and would need to be before use)", "yellow+bold")
        callback(compilers)
      break

fetchConfiguredCompilers = (config, persist = false) ->
  compilers = [new (require("../../compilers/copy"))(config)]
  for category, catConfig of config.compilers
    try
      continue if catConfig.compileWith is "none"
      compiler = require "../../compilers/#{category}/#{catConfig.compileWith}-compiler"
      compilers.push(new compiler(config))
      logger.info "Adding compiler: #{category}/#{catConfig.compileWith}-compiler" if persist
    catch err
      logger.info "Unable to find matching compiler for #{category}/#{catConfig.compileWith}: #{err}"
  compilers

processConfig = (opts, callback) ->
  configPath = _findConfigPath()
  {config} = require configPath if configPath?
  unless config?
    logger.warn "No configuration file found (mimosa-config.coffee), running from current directory using Mimosa's defaults."
    logger.warn "Run 'mimosa config' to copy the default Mimosa configuration to the current directory."
    config = {}
    configPath = path.dirname path.resolve('right-here.foo')

  logger.debug "Your mimosa config:\n#{JSON.stringify(config, null, 2)}"

  config.virgin =       opts?.virgin
  config.isServer =     opts?.server
  config.optimize =     opts?.optimize
  config.min =          opts?.minify
  config.isForceClean = opts?.force

  defaults.applyAndValidateDefaults config, configPath, (err, newConfig) =>
    if err
      logger.fatal "Unable to start Mimosa, #{err} configuration(s) problems listed above."
      process.exit 1
    else
      callback(newConfig)

_findConfigPath = (configPath = path.resolve('mimosa-config.coffee')) ->
  if fs.existsSync configPath
    logger.debug "Found mimosa-config: [[ #{configPath} ]]"
    configPath
  else
    logger.debug "Unable to find mimosa-config at #{configPath}"
    configPath = path.join(path.dirname(configPath), '..', 'mimosa-config.coffee')
    logger.debug "Trying #{configPath}"
    if configPath.length is 'mimosa-config.coffee'.length + 1
      logger.debug "Unable to find mimosa-config"
      return null
    _findConfigPath(configPath)

module.exports = {
  processConfig: processConfig
  fetchConfiguredCompilers: fetchConfiguredCompilers
  projectPossibilities:gatherProjectPossibilities
}