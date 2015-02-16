watch =     require 'chokidar'
logger =    require 'logmimosa'
watchUtil = require( "./watch-util" )

Workflow = require './workflow'

class Watcher

  adds:[]

  constructor: (@config, modules, @persist, @initCallback) ->
    @throttle = @config.watch.throttle
    @workflow = new Workflow @config, modules, @_buildDoneCallback
    @workflow.initBuild @_startWatcher

  _startWatcher: =>
    watchConfig = watchUtil.watchConfig( @config, true );
    watcher = watch.watch @config.watch.sourceDir, watchConfig

    @stopWatching = ->
      if @intervalId
        clearInterval(@intervalId)
      watcher.close();

    process.on 'STOPMIMOSA', @stopWatching

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

    if @intervalId? and !@persist
      clearInterval(@intervalId)

    if @initCallback?
      @initCallback(@config)

  _pullFiles: =>
    if @adds.length is 0
      return

    filesToAdd = if @adds.length <= @throttle
      @adds.splice(0, @adds.length)
    else
      @adds.splice(0, @throttle)

    for f in filesToAdd
      @workflow.add(f)

module.exports = Watcher
