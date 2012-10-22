watch =  require 'chokidar'
logger = require 'mimosa-logger'

LifeCycle = require './lifecycle'
modules =   require '../modules'

class Cleaner

  constructor: (@config, initCallback) ->
    @lifecycle = new LifeCycle(@config, modules.basic, initCallback)
    @_startWatcher()

  _startWatcher:  ->
    watcher = watch.watch(@config.watch.sourceDir, {persistent:false})
    watcher.on "add", (f) => @lifecycle.remove(f) unless @_ignored(f)

  _ignored: (fileName) ->
    if @config.watch.exclude and fileName.match @config.watch.exclude
      logger.debug "Ignoring file [[ #{fileName} ]], matches exclude"
      true
    else
      false

module.exports = Cleaner
