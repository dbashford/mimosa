watch =     require 'chokidar'
logger =    require 'logmimosa'

Workflow = require './workflow'

class Watcher

  adds:[]

  constructor: (@config, modules, @persist, @initCallback) ->
    @throttle = @config.watch.throttle
    @workflow = new Workflow @config, modules, @_buildDoneCallback
    @workflow.initBuild @_startWatcher

  _startWatcher: =>

    watchConfig =
      ignored:@_ignoreFunct
      persistent:@persist
      interval: @config.watch.interval
      binaryInterval: @config.watch.binaryInterval
      usePolling: @config.watch.usePolling

    watcher = watch.watch @config.watch.sourceDir, watchConfig

    process.on 'STOPMIMOSA', ->
      watcher.close()

    watcher.on "error", (error) -> logger.warn "File watching error: #{error}"
    watcher.on "change", (f) => @_fileUpdated('update', f)
    watcher.on "unlink", @workflow.remove
    watcher.on "ready", @workflow.ready
    watcher.on "add", (f) =>
      if @throttle > 0
        @adds.push(f)
      else
        @_fileUpdated('add', f)

    if @persist
      logger.info "Watching [[ #{@config.watch.sourceDir} ]]"

    if @throttle > 0
      logger.debug "Throttle is set, setting interval at 100 milliseconds"
      @intervalId = setInterval(@_pullFiles, 100)
      @_pullFiles()

  _fileUpdated: (eventType, f) =>
    # sometimes events can be sent before
    # file isn't finished being written
    if @config.watch.delay > 0
      setTimeout =>
       @workflow[eventType](f)
      , @config.watch.delay
    else
      @workflow[eventType](f)

  _buildDoneCallback: =>
    logger.buildDone()
    clearInterval(@intervalId) if @intervalId? and !@persist
    @initCallback(@config) if @initCallback?

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
      for exclude in @config.watch.exclude
        if name.indexOf(exclude) is 0
          logger.debug "Ignoring file [[ #{name} ]], matches exclude string path"
          return true
    false

module.exports = Watcher
