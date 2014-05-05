
registerCommand = (buildFirst, isDebug, callback) ->
  logger = require 'logmimosa'

  # manage multiple formats
  if callback
    if isDebug
      logger.setDebug()
      process.env.DEBUG = true
  else
    callback = isDebug

  configurer = require '../util/configurer'
  configurer {}, (config, mods) ->
    if buildFirst
      Cleaner = require '../util/cleaner'
      Watcher =  require '../util/watcher'

      config.isClean = true
      new Cleaner config, mods, ->
        config.isClean = false

        new Watcher config, mods, false, ->
          logger.success "Finished build"
          callback config
    else
      callback config

module.exports = (program) ->
  modules = require '../modules'
  for mod in modules.modulesWithCommands()
    # older API just took two commands, newer API,
    # as of 2.1.10 allows passing of logger
    if mod.registerCommand.length is 2
      mod.registerCommand program, registerCommand
    else
      logger = require 'logmimosa'
      mod.registerCommand program, logger, registerCommand
