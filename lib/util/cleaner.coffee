watch =  require 'chokidar'
logger = require 'logmimosa'

Workflow = require './workflow'
modules =   require '../modules'

class Cleaner

  constructor: (@config, initCallback) ->
    @workflow = new Workflow(@config, modules.basic, initCallback)
    @_startWatcher()

  _startWatcher:  ->
    watcher = watch.watch(@config.watch.sourceDir, {persistent:false})
    watcher.on "add", (f) => @workflow.remove(f) unless @_ignored(f)

  _ignored: (fileName) ->
    if @config.watch.exclude and fileName.match @config.watch.exclude
      logger.debug "Ignoring file [[ #{fileName} ]], matches exclude"
      true
    else
      false

module.exports = Cleaner
