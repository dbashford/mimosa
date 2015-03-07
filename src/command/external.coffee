retrieveConfig = (opts, callback) ->
  logger = require 'logmimosa'

  if opts.mdebug
    logger.setDebug()
    process.env.DEBUG = true

  configurer = require '../util/configurer'
  configurer opts, (config, mods) ->
    if opts.buildFirst
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
    logger = require 'logmimosa'
    mod.registerCommand program, logger, retrieveConfig
