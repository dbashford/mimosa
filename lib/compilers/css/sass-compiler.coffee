AbstractCssCompiler = require './css'
fs = require 'fs'
wrench = require 'wrench'
path = require 'path'
{spawn, exec} = require 'child_process'
logger = require '../../util/logger'

module.exports = class SassCompiler extends AbstractCssCompiler

  importRegex: /@import ['"](.*)['"]/g

  @prettyName        = -> "SASS"
  @defaultExtensions = -> ["scss", "sass"]
  @checkIfExists     = (callback) ->
    exec 'sass --version', (error, stdout, stderr) ->
      callback(if error then false else true)

  constructor: (config) ->
    super(config)
    SassCompiler.checkIfExists (exists) ->
      unless exists
        logger.error "SASS is configured as the CSS compiler, but you don't seem to have SASS installed"
        logger.error "SASS is a Ruby gem, information can be found here: http://sass-lang.com/tutorial.html"
        logger.error "SASS can be installed by executing this command: gem install sass"

    exec 'compass --version', (error, stdout, stderr) =>
      @hasCompass = not error

  created: (fileName) =>
    if @startupFinished then @process(fileName, (f) => super(f)) else @done()

  updated: (fileName) =>
    @process(fileName, (f) => super(f))

  removed: (fileName) =>
    @process(fileName, (f) => super(f))

  process: (fileName, sooper) ->
    if @_isPartial(fileName)
      @_compileBasesForPartial(fileName)
    else
      sooper(fileName)
      @processWatchedDirectories()

  doneStartup: =>
    baseSassFilesToCompileNow = []

    # Determine if any partials necessitate a base file compile
    for partial, bases of @partialToBaseHash
      partialTime = fs.statSync(path.join @fullConfig.root, partial).mtime
      for base in bases
        basePath = @findCompiledPath(base)
        if path.existsSync basePath
          baseTime = fs.statSync(basePath).mtime
          baseSassFilesToCompileNow.push(base) if partialTime > baseTime
        else
          baseSassFilesToCompileNow.push(base)

    # Determine if any bases need to be compiled based on their own merit
    for base in @baseSassFiles
      baseCompiledPath = @findCompiledPath(base)
      if path.existsSync baseCompiledPath
        baseSrcPath = path.join @fullConfig.root, base
        baseSassFilesToCompileNow.push(base) if fs.statSync(baseSrcPath).mtime > fs.statSync(baseCompiledPath).mtime
      else
        baseSassFilesToCompileNow.push(base)

    baseSassFilesToCompileNow = baseSassFilesToCompileNow.unique()

    @initBaseFilesToCompile = baseSassFilesToCompileNow.length
    if @initBaseFilesToCompile is 0
      @_startupFinished()
    else
      @readAndCompile(base) for base in baseSassFilesToCompileNow

  compile: (sassText, fileName, destinationFile, callback) =>
    return @_compile(sassText, fileName, destinationFile, callback) if @hasCompass?

    compileOnDelay = =>
      if @hasCompass?
        @_compile(sassText, fileName, destinationFile, callback)
      else
        setTimeout compileOnDelay, 100
    do compileOnDelay

  _compile: (sassText, fileName, destinationFile, callback) =>
    result = ''
    error = null
    options = ['--stdin', '--load-path', @srcDir, '--load-path', path.dirname(fileName), '--no-cache']
    options.push '--compass' if @hasCompass
    options.push '--scss' if /\.scss$/.test fileName
    sass = spawn 'sass', options
    sass.stdin.end sassText
    sass.stdout.on 'data', (buffer) -> result += buffer.toString()
    sass.stderr.on 'data', (buffer) ->
      error ?= ''
      error += buffer.toString()
    sass.on 'exit', (code) =>
      callback(error, result, destinationFile)

      unless @startupFinished
        @_startupFinished() if --@initBaseFilesToCompile is 0

  _startupFinished: =>
    @startupDoneCallback()
    @startupFinished = true

  _isPartial: (fileName) -> path.basename(fileName).startsWith('_')

  _compileBasesForPartial: (fileName) ->
    fileName = fileName.replace(@fullConfig.root, '').substring(1)
    bases = @partialToBaseHash[fileName]
    if bases?
      for base in bases
        @readAndCompile(base)
        @processWatchedDirectories()
    else
      logger.warn "Orphaned partial #{fileName}"
      @done()

  processWatchedDirectories: =>
    @partialToBaseHash = {}
    @sassFiles = wrench.readdirSyncRecursive(@srcDir)
      .map( (file) => path.join(@srcDir, file))
      .filter (file) => @config.extensions.some (ext) -> file.endsWith(ext)
    @baseSassFiles = @sassFiles.filter (file) =>
      not @_isPartial(file) and not file.has('compass')

    @_importsForFile(baseFile, baseFile) for baseFile in @baseSassFiles

  # get all imports for a given file, and recurse through
  # those imports until entire tree is built
  _importsForFile: (baseFile, file) ->
    imports = fs.readFileSync(file, 'ascii').match(@importRegex)
    return unless imports?

    for anImport in imports
      @importRegex.lastIndex = 0
      importPath = @importRegex.exec(anImport)[1]
      pathMadePartial = importPath.replace(/(\w+\.|\w+$)/, '_$1')
      partialFiles = @sassFiles.filter (file) -> file.has(pathMadePartial)
      for partialFile in partialFiles
        hash = @partialToBaseHash[partialFile]
        if !hash?
          @partialToBaseHash[partialFile] = [baseFile]
        else
          hash.push(baseFile) if hash.indexOf(baseFile) is -1
        @_importsForFile(baseFile, partialFile)