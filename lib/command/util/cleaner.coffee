watch =     require 'chokidar'
logger =    require 'mimosa-logger'

LifeCycle = require '../../lifecycle'
modules = require '../../modules'

class Cleaner

  constructor: (@config, initCallback) ->
    @lifecycle = new LifeCycle(@config, modules.basic, initCallback)
    @_startWatcher()

  _startWatcher:  ->
    watcher = watch.watch(@config.watch.sourceDir, {persistent:false})
    watcher.on "add", (f) => @lifecycle.remove(f) unless @_ignored(f)

  _ignored: (fileName) ->
    if @config.watch.ignored.some((str) -> fileName.indexOf(str) >= 0 )
      logger.debug "Ignoring file, matches #{@config.watch.ignored}"
      true
    else
      false

module.exports = Cleaner
