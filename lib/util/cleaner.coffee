watch =  require 'chokidar'
logger = require 'logmimosa'
_ = require 'lodash'

Workflow = require './workflow'
modules =   require '../modules'

class Cleaner

  constructor: (@config, initCallback) ->
    @workflow = new Workflow(_.clone(@config, true), modules.basic, initCallback)
    @_startWatcher()

  _startWatcher: ->
    watcher = watch.watch(@config.watch.sourceDir, {ignored:@_ignoreFunct, persistent:false})
    watcher.on "add", @workflow.remove

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
