watch =     require 'chokidar'
path =      require 'path'
logger =    require '../util/logger'
optimizer = require '../optimize/require-optimize'

class Watcher

  compilersDone:0

  constructor: (@config, @compilers, persist, @initCallback) ->
    compiler.setStartupDoneCallback(@compilerDone) for compiler in @compilers
    srcDir = path.join(@config.root, @config.watch.sourceDir)

    watcher = watch.watch(srcDir, {persistent:persist})
    watcher.on "change", (f) => @_findCompiler(f)?.updated(f)
    watcher.on "unlink", (f) => @_findCompiler(f)?.removed(f)
    watcher.on "add",    (f) => @_findCompiler(f)?.created(f)

    logger.info "Watching #{srcDir}" if persist

  compilerDone: =>
    if ++@compilersDone is @compilers.length
      optimizer.optimize(@config)
      compiler.initializationComplete() for compiler in @compilers
      @initCallback(@config) if @initCallback?

  _findCompiler: (fileName) ->
    return if @config.watch.ignored.some((str) -> fileName.has(str))

    extension = path.extname(fileName).substring(1)
    return unless extension?.length > 0

    compiler = @compilers.find (comp) ->
      for ext in comp.getExtensions()
        return true if extension is ext
      return false
    return compiler if compiler
    logger.warn "No compiler has been registered: #{extension}, #{fileName}"
    null

module.exports = Watcher
