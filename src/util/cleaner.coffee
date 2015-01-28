watch =  require 'chokidar'
logger = require 'logmimosa'
_ = require 'lodash'

Workflow = require './workflow'

class Cleaner

  constructor: (@config, modules, @initCallback) ->
    @workflow = new Workflow _.clone(@config, true), modules, @_cleanDone
    @workflow.initClean @_startWatcher

  _startWatcher: =>
    watchConfig =
      ignored:@_ignoreFunct
      persistent:false
      interval: @config.watch.interval
      binaryInterval: @config.watch.binaryInterval
      usePolling: @config.watch.usePolling

    @watcher = watch.watch @config.watch.sourceDir, watchConfig
    @watcher.on "add", @workflow.clean
    @watcher.on "ready", @workflow.ready


  _cleanDone: =>
    @workflow.postClean =>
      @watcher.close()
      @initCallback()

  _ignoreFunct: (name) =>
    if @config.watch.excludeRegex?
      if name.match(@config.watch.excludeRegex)
        logger.debug "Ignoring file [[ #{name} ]], matches exclude regex"
        return true
    if @config.watch.exclude?
      if @config.watch.exclude.indexOf(name) > -1
        logger.debug "Ignoring file [[ #{name} ]], matches exclude string path"
        return true
    false

module.exports = Cleaner
