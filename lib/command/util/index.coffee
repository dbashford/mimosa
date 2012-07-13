path   = require 'path'

glob =  require 'glob'
color = require('ansi-color').set
_     = require 'lodash'

logger = require '../../util/logger'
defaults = require './defaults'

gatherCompilerInfo = (callback) ->
  compilerPath = path.join __dirname, '..', '..', 'compilers'
  files = glob.sync "#{compilerPath}/**/*-compiler.coffee"
  compilers =
    css:[{prettyName:"None", fileName:"none"}]
    javascript:[{prettyName:"None", fileName:"none"}]
    template:[{prettyName:"None", fileName:"none"}]

  gatheredCount = 0
  gatheredInfoForCompiler = =>
    callback(compilers) if ++gatheredCount is files.length

  for file in files
    comp = require(file)
    compilerInfo = {prettyName:comp.prettyName(), fileName:path.basename(file, ".coffee").replace("-compiler",""), extensions:comp.defaultExtensions()}
    if comp.checkIfExists?
      infoClone = _.clone(compilerInfo)
      fileClone = _.clone(file)
      comp.checkIfExists (exists) =>
        unless exists
          infoClone.prettyName = infoClone.prettyName + color(" (This is not installed and would need to be before use)", "yellow+bold")
        _findCompilers(fileClone, compilers).push infoClone
        gatheredInfoForCompiler()
    else
      compilerInfo.exists = true
      _findCompilers(file, compilers).push compilerInfo
      gatheredInfoForCompiler()

_findCompilers = (file, compilers) ->
  # use regex to do this a bit better
  dirname = path.dirname(file)

  endsWith = (str, endsWith) ->
    str.slice(-endsWith.length) is endsWith

  if endsWith(dirname, 'css') then compilers.css
  else if endsWith(dirname, 'template') then compilers.template
  else if endsWith(dirname, 'javascript') then compilers.javascript
  else
    logger.fatal "Bad file in compilers directory: #{file}"
    process.exit(1)

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

processConfig = (server, callback) ->
  configPath = path.resolve 'mimosa-config.coffee'
  try
    {config} = require configPath
  catch err
    logger.warn "No configuration file found (mimosa-config.coffee), using all defaults."
    logger.warn "Run 'mimosa config' to copy the default Mimosa configuration to the current directory."
    config = {}

  defaults.applyAndValidateDefaults config, server, (err, newConfig) =>
    if err
      logger.fatal "Unable to start Mimosa, #{err} configuration(s) problems listed above."
      process.exit 1
    else
      newConfig.root = path.dirname configPath
      callback(newConfig)

module.exports = {
  processConfig: processConfig
  fetchConfiguredCompilers: fetchConfiguredCompilers
  gatherCompilerInfo:gatherCompilerInfo
}