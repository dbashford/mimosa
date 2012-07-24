fs =     require 'fs'
path =   require 'path'

wrench = require 'wrench'
_ =      require 'lodash'
clean  = require 'clean-css'

SingleFileCompiler = require '../single-file'
logger =             require '../../util/logger'
Linter =             require '../../util/lint/css'

module.exports = class AbstractCSSCompiler extends SingleFileCompiler

  outExtension: 'css'

  constructor: (config) ->
    super(config, config.compilers.css)

    @notifyOnSuccess = config.growl.onSuccess.css

    if config.lint.compiled.css
      @linter = new Linter(config.lint.rules.css)

  created: (fileName) =>
    if @startupFinished then @process(fileName, (f) => super(f)) else @done()

  updated: (fileName) =>
    @process(fileName, (f) => super(f))

  removed: (fileName) =>
    @process(fileName, (f) => super(f))

  process: (fileName, sooper) ->
    if @_isInclude(fileName)
      @_compileBasesForInclude(fileName)
    else
      sooper(fileName)
      @processWatchedDirectories()

  _compileBasesForInclude: (fileName) ->
    bases = @includeToBaseHash[fileName]
    if bases?
      for base in bases
        @readAndCompile(base)
        @processWatchedDirectories()
    else
      logger.warn "Orphaned partial #{fileName}"
      @done()

  doneStartup: =>
    baseFilesToCompileNow = []

    # Determine if any includes necessitate a base file compile
    for include, bases of @includeToBaseHash
      includeTime = fs.statSync(path.join @fullConfig.root, include).mtime
      for base in bases
        basePath = @findCompiledPath(base)
        if fs.existsSync basePath
          baseTime = fs.statSync(basePath).mtime
          baseFilesToCompileNow.push(base) if includeTime > baseTime
        else
          baseFilesToCompileNow.push(base)

    # Determine if any bases need to be compiled based on their own merit
    for base in @baseFiles
      baseCompiledPath = @findCompiledPath(base)
      if fs.existsSync baseCompiledPath
        baseSrcPath = path.join @fullConfig.root, base
        baseFilesToCompileNow.push(base) if fs.statSync(baseSrcPath).mtime > fs.statSync(baseCompiledPath).mtime
      else
        baseFilesToCompileNow.push(base)

    baseFilesToCompileNow = _.uniq(baseFilesToCompileNow)

    @initBaseFilesToCompile = baseFilesToCompileNow.length
    if @initBaseFilesToCompile is 0
      @_doneStartup()
    else
      AbstractCSSCompiler::done = =>
        if !@startupFinished and @initBaseFilesToCompile is 0
          @_doneStartup()

      @readAndCompile(base) for base in baseFilesToCompileNow

  init: =>
    @processWatchedDirectories()

  processWatchedDirectories: =>
    @includeToBaseHash = {}
    @allFiles = @getAllFiles()

    oldBaseFiles = @baseFiles ?= []
    @baseFiles = @_determineBaseFiles()
    allBaseFiles = _.union oldBaseFiles, @baseFiles

    # Change in base files to be compiled, cleanup and message
    if (allBaseFiles.length isnt oldBaseFiles.length or allBaseFiles.length isnt @baseFiles.length) and oldBaseFiles.length > 0
      logger.info "The list of CSS files that Mimosa will compile has changed. Mimosa will now compile the following root files to CSS:"
      logger.info baseFile for baseFile in @baseFiles

    @_importsForFile(baseFile, baseFile) for baseFile in @baseFiles

  afterCompile: (destFileName, source) =>
    return unless source?.length > 0
    @linter.lint(destFileName, source) if @linter

    if @fullConfig.optimize
      source = clean.process source

    source

  getAllFiles: =>
    wrench.readdirSyncRecursive(@srcDir)
      .map (file) =>
        path.join(@srcDir, file)
      .filter (file) =>
        @config.extensions.some (ext) ->
          file.slice(-ext.length) is ext

  # get all imports for a given file, and recurse through
  # those imports until entire tree is built
  _importsForFile: (baseFile, file) ->
    imports = fs.readFileSync(file, 'ascii').match(@importRegex)
    return unless imports?

    for anImport in imports
      @importRegex.lastIndex = 0
      importPath = @importRegex.exec(anImport)[1]
      fullImportFilePath = @_getImportFilePath(baseFile, importPath)
      includeFiles = @allFiles.filter (f) ->
        f = f.replace(path.extname(f), '')
        f.slice(-fullImportFilePath.length) is fullImportFilePath

      for includeFile in includeFiles
        hash = @includeToBaseHash[includeFile]
        if hash?
          hash.push(baseFile) if hash.indexOf(baseFile) is -1
        else
          @includeToBaseHash[includeFile] = [baseFile]
        @_importsForFile(baseFile, includeFile)