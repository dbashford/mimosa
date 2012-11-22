watch =     require 'chokidar'
logger =    require 'logmimosa'

Workflow = require './workflow'

class Watcher

  adds:[]

  constructor: (@config, modules, @persist, @initCallback) ->
    @throttle = @config.watch.throttle
    @workflow = new Workflow(@config, modules, @_buildDoneCallback)
    @_startWatcher()

    logger.info "Watching #{@config.watch.sourceDir}" if @persist

    if @throttle > 0
      logger.debug "Throttle is set, setting interval at 100 milliseconds"
      @intervalId = setInterval(@_pullFiles, 100)
      @_pullFiles()

  _buildDoneCallback: =>
    logger.buildDone()
    clearInterval(@intervalId) if @intervalId? and !@persist
    @initCallback(@config) if @initCallback?

  _startWatcher: ->
    watcher = watch.watch(@config.watch.sourceDir, {ignored:@_ignoreFunct, persistent:@persist})
    watcher.on "error", (error) -> logger.warn "File watching error: #{error}"
    watcher.on "change", @workflow.update
    watcher.on "unlink", @workflow.remove
    watcher.on "add", (f) => if @throttle > 0 then @adds.push(f) else @workflow.add(f)

  _pullFiles: =>
    return if @adds.length is 0
    filesToAdd = if @adds.length <= @throttle
      @adds.splice(0, @adds.length)
    else
      @adds.splice(0, @throttle)
    @workflow.add(f) for f in filesToAdd

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

module.exports = Watcher
