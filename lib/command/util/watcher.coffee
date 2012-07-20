path =      require 'path'

watch =     require 'chokidar'
_ =         require 'lodash'

logger =    require '../../util/logger'
optimizer = require '../../util/require-optimize'

class Watcher

  compilersDone:0

  constructor: (@config, @compilers, persist, @initCallback) ->
    compiler.setStartupDoneCallback(@compilerDone) for compiler in @compilers

    watcher = watch.watch(@config.watch.sourceDir, {persistent:persist})
    watcher.on "change", (f) => @_findCompiler(f)?.updated(f)
    watcher.on "unlink", (f) => @_findCompiler(f)?.removed(f)
    watcher.on "add",    (f) => @_findCompiler(f)?.created(f)

    logger.info "Watching #{@config.watch.sourceDir}" if persist

  compilerDone: =>
    if ++@compilersDone is @compilers.length
      optimizer.optimize(@config)
      compiler.initializationComplete() for compiler in @compilers
      @initCallback(@config) if @initCallback?

  _findCompiler: (fileName) ->
    return if @config.watch.ignored.some((str) -> fileName.indexOf(str) >= 0 )

    extension = path.extname(fileName).substring(1)
    return unless extension?.length > 0

    compiler = _.find @compilers, (comp) ->
      for ext in comp.getExtensions()
        return true if extension is ext
      return false

    return compiler if compiler
    logger.warn "No compiler has been registered: #{extension}, #{fileName}"
    null

module.exports = Watcher
