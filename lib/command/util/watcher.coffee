path =      require 'path'

watch =     require 'chokidar'
_ =         require 'lodash'

logger =    require '../../util/logger'
optimizer = require '../../util/require/optimize'
compilerCentral = require '../../compilers'

class Watcher

  compilersDone:0
  adds:[]

  constructor: (@config, @persist, @initCallback) ->
    {@compilerExtensionHash, @compilers} = compilerCentral.buildCompilerExtensionHash(@config)
    @throttle = @config.watch.throttle

    compiler.setStartupDoneCallback(@compilerDone) for compiler in @compilers
    @startWatcher()

    logger.info "Watching #{@config.watch.sourceDir}" if @persist

    if @throttle > 0
      logger.debug "Throttle is set, setting interval at 100 milliseconds"
      @intervalId = setInterval(@pullFiles, 100)
      @pullFiles()

  startWatcher: (persist) ->
    watcher = watch.watch(@config.watch.sourceDir, {persistent:@persist})
    watcher.on "error", (error) -> logger.debug "File watching error: #{error}"
    watcher.on "change", (f) => @_findCompiler(f)?.updated(f)
    watcher.on "unlink", (f) => @_findCompiler(f)?.removed(f)
    watcher.on "add", (f) =>
      if @throttle > 0 then @adds.push(f) else @_findCompiler(f)?.created(f)

  pullFiles: =>
    return if @adds.length is 0
    filesToAdd = if @adds.length <= @throttle
      @adds.splice(0, @adds.length)
    else
      @adds.splice(0, @throttle)
    @_findCompiler(f)?.created(f) for f in filesToAdd

  compilerDone: =>
    if ++@compilersDone is @compilers.length
      clearInterval(@intervalId) if @intervalId? and !@persist
      compiler.initializationComplete() for compiler in @compilers
      optimizer.optimize(@config)
      @initCallback(@config) if @initCallback?

  _findCompiler: (fileName) ->
    if @config.watch.ignored.some((str) -> fileName.indexOf(str) >= 0 )
      return logger.debug "Ignoring file, matches #{@config.watch.ignored}"

    extension = path.extname(fileName).substring(1)
    return unless extension?.length > 0

    compiler = @compilerExtensionHash[extension]

    return compiler if compiler
    logger.warn "No compiler has been registered: #{extension}, #{fileName}"
    null

module.exports = Watcher
