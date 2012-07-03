path   = require 'path'

logger = require '../../util/logger'
defaults = require './defaults'

fetchCompilers = (config, persist = false) ->
  compilers = [new (require("../../compilers/copy"))(config)]
  for category, catConfig of config.compilers
    try
      continue if catConfig.compileWith is "none"
      compiler = require("../../compilers/#{category}/#{catConfig.compileWith}")
      compilers.push(new compiler(config))
      logger.info "Adding compiler: #{category}/#{catConfig.compileWith}" if persist
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

  defaults config, server, (err, newConfig) =>
    if err
      logger.fatal "Unable to start Mimosa, #{err} configuration(s) problems listed above."
      process.exit 1
    else
      newConfig.root = path.dirname configPath
      callback(newConfig)

module.exports = {
  processConfig: processConfig
  fetchCompilers: fetchCompilers
}