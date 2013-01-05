modules = require '../modules'
util =    require '../util/util'
Watcher =  require '../util/watcher'
Cleaner = require '../util/cleaner'
logger = require 'logmimosa'

module.exports = (program) ->

  for mod in modules.modulesWithCommands()
    mod.registerCommand program, (buildFirst, callback) ->
      util.processConfig {}, (config, mods) =>

        if buildFirst
          config.isClean = true
          new Cleaner config, mods, ->
            config.isClean = false
            new Watcher config, mods, false, ->
              logger.success "Finished build"
              callback(config)
        else
          callback(config)