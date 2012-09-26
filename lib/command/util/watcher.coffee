path =      require 'path'

wrench =    require 'wrench'
watch =     require 'chokidar'
_ =         require 'lodash'

logger =    require '../../util/logger'
compilerCentral = require '../../modules/compilers'
LifeCycle = require '../../lifecycle'
modules = require '../../modules'

class Watcher

  adds:[]

  constructor: (@config, @persist, @initCallback) ->
    @throttle = @config.watch.throttle
    @lifecycle = new LifeCycle(@config, modules, @_startupDoneCallback)
    {@compilerExtensionHash, @compilers} = compilerCentral.getCompilers(@config)

    templateLibraryWithFiles = 0
    for compiler in @compilers
      files = wrench.readdirSyncRecursive(@config.watch.sourceDir).filter (f) =>
        ext = path.extname(f)
        ext.length > 1 and compiler.extensions.indexOf(ext.substring(1)) >= 0

      logger.debug "File count for extension(s) [[ #{compiler.extensions} ]]: #{files.length}"

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

  _startupDoneCallback: =>
    clearInterval(@intervalId) if @intervalId? and !@persist
    @initCallback(@config)

  _startWatcher:  ->
    watcher = watch.watch(@config.watch.sourceDir, {persistent:@persist})
    watcher.on "error", (error) -> logger.debug "File watching error: #{error}"
    watcher.on "change", (f) => #@_findCompiler(f)?.updated(f)
    watcher.on "unlink", (f) => #@_findCompiler(f)?.removed(f)
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
