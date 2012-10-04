path =      require 'path'

wrench =    require 'wrench'
watch =     require 'chokidar'
_ =         require 'lodash'

logger =    require '../../util/logger'
LifeCycle = require '../../lifecycle'
modules = require '../../modules'

class Watcher

  adds:[]

  constructor: (@config, @persist, @initCallback) ->
    @throttle = @config.watch.throttle
    @lifecycle = new LifeCycle(@config, modules, @_startupDoneCallback)
    @_startWatcher()

    logger.info "Watching #{@config.watch.sourceDir}" if @persist

    if @throttle > 0
      logger.debug "Throttle is set, setting interval at 100 milliseconds"
      @intervalId = setInterval(@_pullFiles, 100)
      @_pullFiles()

  _startupDoneCallback: =>
    logger.startupDone()
    clearInterval(@intervalId) if @intervalId? and !@persist
    @initCallback(@config) if @initCallback?

  _startWatcher:  ->
    watcher = watch.watch(@config.watch.sourceDir, {persistent:@persist})
    watcher.on "error", (error) -> logger.debug "File watching error: #{error}"
    watcher.on "change", (f) => @lifecycle.update(f) unless @_ignored(f)
    watcher.on "unlink", (f) => @lifecycle.remove(f) unless @_ignored(f)
    watcher.on "add", (f) =>
      unless @_ignored(f)
        if @throttle > 0 then @adds.push(f) else @lifecycle.add(f)

  _pullFiles: =>
    return if @adds.length is 0
    filesToAdd = if @adds.length <= @throttle
      @adds.splice(0, @adds.length)
    else
      @adds.splice(0, @throttle)
    @lifecycle.add(f) for f in filesToAdd

  _ignored: (fileName) ->
    if @config.watch.ignored.some((str) -> fileName.indexOf(str) >= 0 )
      logger.debug "Ignoring file, matches #{@config.watch.ignored}"
      true
    else
      false

module.exports = Watcher
