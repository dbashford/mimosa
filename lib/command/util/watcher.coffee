path =      require 'path'

wrench =    require 'wrench'
watch =     require 'chokidar'
_ =         require 'lodash'

logger =    require '../../util/logger'
compilerCentral = require '../../modules/compilers'

LifeCycle = require '../../lifecycle'

modules = require '../../modules'

class Watcher

  totalStartupFiles:0
  startupFilesDone:0
  adds:[]

  constructor: (@config, @persist, @initCallback) ->
    @throttle = @config.watch.throttle

    @lifecycle = new LifeCycle(@config, modules)

    {@compilerExtensionHash, @compilers} = compilerCentral.getCompilers(@config)
    #compiler.setFileDone(@fileDone) for compiler in @compilers
    templateLibraryWithFiles = 0
    for compiler in @compilers
      files = wrench.readdirSyncRecursive(@config.watch.sourceDir).filter (f) =>
        ext = path.extname(f)
        ext.length > 1 and compiler.extensions.indexOf(ext.substring(1)) >= 0

      logger.debug "File count for extension(s) [[ #{compiler.extensions} ]]: #{files.length}"

      @totalStartupFiles += files.length
      if files.length > 0 and compiler.template
        templateLibraryWithFiles++

    if templateLibraryWithFiles > 1 and _.isString(@config.template.outputFileName)
      logger.error "More than one template library is being used, but multiple template.outputFileName entries not found." +
        " You will want to configure a map of outfileFileName entries in your config, otherwise you will only get" +
        " template output for one of the libraries."

    @_startWatcher()
    logger.info "Watching #{@config.watch.sourceDir}" if @persist

    if @throttle > 0
      logger.debug "Throttle is set, setting interval at 100 milliseconds"
      @intervalId = setInterval(@_pullFiles, 100)
      @_pullFiles()

  _startWatcher:  ->
    watcher = watch.watch(@config.watch.sourceDir, {persistent:@persist})
    watcher.on "error", (error) -> logger.debug "File watching error: #{error}"
    watcher.on "change", (f) => #@_findCompiler(f)?.updated(f)
    watcher.on "unlink", (f) => #@_findCompiler(f)?.removed(f)
    watcher.on "add", (f) => @lifecycle.add(f)
      #if @throttle > 0 then @adds.push(f) else @_findCompiler(f)?.created(f)

  _pullFiles: =>
    return if @adds.length is 0
    filesToAdd = if @adds.length <= @throttle
      @adds.splice(0, @adds.length)
    else
      @adds.splice(0, @throttle)
    @_findCompiler(f)?.created(f) for f in filesToAdd

  fileDone: =>
    if ++@startupFilesDone is @totalStartupFiles
      clearInterval(@intervalId) if @intervalId? and !@persist
      @_processFinishedCompilers()
      postStartups = 0
      postStartups++ for compiler in @compilers when compiler.postStartup?
      if compiler.postStartup?
        postStartups++
        compiler.setFileDone(@startupDone(compiler))

  startupDone: (compiler) =>
    #if compiler.startupDone
    compiler.setFileDone(->) for compiler in @compilers
    #optimizer.optimize(@config)
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
