fs = require 'fs'
path = require 'path'

csslint = require("csslint").CSSLint
wrench = require 'wrench'

SingleFileCompiler = require '../single-file'
logger =             require '../../util/logger'

module.exports = class AbstractCSSCompiler extends SingleFileCompiler

  outExtension: 'css'

  constructor: (config) ->
    super(config, config.compilers.css)

    return if @config.lint.enabled is false

    @rules = {}
    for rule in csslint.getRules()
      @rules[rule.id] = 1 unless config.compilers.css.lint.rules[rule.id] is false

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
    fileName = fileName.replace(@fullConfig.root, '').substring(1)
    bases = @includeToBaseHash[fileName]
    if bases?
      for base in bases
        @readAndCompile(base)
        @processWatchedDirectories()
    else
      logger.warn "Orphaned include #{fileName}"
      @done()

  doneStartup: =>
    baseFilesToCompileNow = []

    # Determine if any includes necessitate a base file compile
    for include, bases of @includeToBaseHash
      includeTime = fs.statSync(path.join @fullConfig.root, include).mtime
      for base in bases
        basePath = @findCompiledPath(base)
        if path.existsSync basePath
          baseTime = fs.statSync(basePath).mtime
          baseFilesToCompileNow.push(base) if includeTime > baseTime
        else
          baseFilesToCompileNow.push(base)

    # Determine if any bases need to be compiled based on their own merit
    for base in @baseFiles
      baseCompiledPath = @findCompiledPath(base)
      if path.existsSync baseCompiledPath
        baseSrcPath = path.join @fullConfig.root, base
        baseFilesToCompileNow.push(base) if fs.statSync(baseSrcPath).mtime > fs.statSync(baseCompiledPath).mtime
      else
        baseFilesToCompileNow.push(base)

    baseFilesToCompileNow = baseFilesToCompileNow.unique()

    @initBaseFilesToCompile = baseFilesToCompileNow.length
    if @initBaseFilesToCompile is 0
      @_startupFinished()
    else
      @readAndCompile(base) for base in baseFilesToCompileNow

  processWatchedDirectories: =>
    @includeToBaseHash = {}
    @allFiles = @getAllFiles()

    oldBaseFiles = @baseFiles ?= []
    @baseFiles = @_determineBaseFiles()
    allBaseFiles = oldBaseFiles.union(@baseFiles)

    # Change in base files to be compiled, cleanup and message
    if (allBaseFiles.length isnt oldBaseFiles.length or allBaseFiles.length isnt @baseFiles.length) and oldBaseFiles.length > 0
      logger.info "The list of CSS files that Mimosa will compile has changed. Mimosa will now compile the following root files to CSS:"
      logger.info baseFile for baseFile in @baseFiles

    @_importsForFile(baseFile, baseFile) for baseFile in @baseFiles

  afterCompile: (source, destFileName) =>
    return if @config.lint.enabled is false
    return unless source?.length > 0

    result = csslint.verify source, @rules
    @writeMessage(message, destFileName) for message in result.messages

  writeMessage: (message, destFileName) ->
    output = "CSSLint Warning: #{message.message} In #{destFileName},"
    output += " on line #{message.line}, column #{message.col}," if message.line?
    output += " from CSSLint rule ID '#{message.rule.id}'."
    logger.warn output

  getAllFiles: =>
    wrench.readdirSyncRecursive(@srcDir)
      .map( (file) => path.join(@srcDir, file))
      .filter (file) => @config.extensions.some (ext) -> file.endsWith(ext)

  # get all imports for a given file, and recurse through
  # those imports until entire tree is built
  _importsForFile: (baseFile, file) ->
    imports = fs.readFileSync(file, 'ascii').match(@importRegex)
    return unless imports?

    for anImport in imports
      @importRegex.lastIndex = 0
      importPath = @importRegex.exec(anImport)[1]
      fullImportFilePath = @_getImportFilePath(baseFile, importPath)
      includeFiles = @allFiles.filter (f) -> f.has(fullImportFilePath)
      for includeFile in includeFiles
        hash = @includeToBaseHash[includeFile]
        if hash?
          hash.push(baseFile) if hash.indexOf(baseFile) is -1
        else
          @includeToBaseHash[includeFile] = [baseFile]
        @_importsForFile(baseFile, includeFile)

  _startupFinished: =>
    @startupDoneCallback()
    @startupFinished = true