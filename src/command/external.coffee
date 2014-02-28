modules = require '../modules'
configurer = require '../util/configurer'
Watcher =  require '../util/watcher'
Cleaner = require '../util/cleaner'
logger = require 'logmimosa'

registerCommand = (buildFirst, isDebug, callback) ->

  # manage multiple formats
  if callback
    if isDebug
      logger.setDebug()
      process.env.DEBUG = true
  else
    callback = isDebug

  configurer {}, (config, mods) ->
    if buildFirst
      config.isClean = true
      new Cleaner config, mods, ->
        config.isClean = false
        new Watcher config, mods, false, ->
          logger.success "Finished build"
          callback config
    else
      callback config

module.exports = (program) ->
  for mod in modules.modulesWithCommands()
    # older API just took two commands, newer API,
    # as of 2.1.10 allows passing of logger
    if mod.registerCommand.length is 2
      mod.registerCommand program, registerCommand
    else
      mod.registerCommand program, logger, registerCommand
