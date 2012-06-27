watch =     require 'chokidar'
color =     require("ansi-color").set
path =      require 'path'
wrench =    require 'wrench'
fs =        require 'fs'
logger =    require '../util/logger'
optimizer = require '../util/require-optimize'

class Watcher

  constructor: (@config, @compilers, persist, @initCallback) ->
    compiler.setDoneCallback(@compilerDone) for compiler in @compilers

    srcDir = path.join(@config.root, @config.watch.sourceDir)
    files = wrench.readdirSyncRecursive(srcDir)
    files = files.filter (file) => fs.statSync(path.join(srcDir, file)).isFile()
    @fileCount = files.length
    @compiledTotal = 0

    watcher = watch.watch(srcDir, {persistent:persist})
    watcher.on "change", (f) => @_findCompiler(f)?.updated(f)
    watcher.on "unlink", (f) => @_findCompiler(f)?.removed(f)
    watcher.on "add",    (f) => @_findCompiler(f)?.created(f)

    logger.info "Watching #{srcDir}" if persist

  # On startup, when all compilers done, let them know, and trigger optimize
  compilerDone: =>
    if ++@compiledTotal is @fileCount
      compiler.doneStartup() for ext, compiler of @compilers
      optimizer.optimize(@config)
      @initCallback() if @initCallback?

  _findCompiler: (fileName) ->
    return if @config.watch.ignored.some((str) -> fileName.has(str))
    extension = path.extname(fileName).substring(1)
    return unless extension?.length > 0
    compiler = @compilers.find (comp) ->
      for ext in comp.getExtensions()
        return true if extension is ext
      return false
    return compiler if compiler
    logger.warn "No compiler has been registered: #{extension}"
    null

module.exports = Watcher
