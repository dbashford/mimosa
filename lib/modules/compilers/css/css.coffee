fs =     require 'fs'
path =   require 'path'

wrench = require 'wrench'
_ =      require 'lodash'

logger =           require '../../../util/logger'

module.exports = class AbstractCSSCompiler

  constructor: (@config) ->

  process: (fileName, sooper) ->
    if @_isInclude(fileName)
      @_compileBasesForInclude(fileName)
    else
      @processWatchedDirectories()

  _compileBasesForInclude: (fileName) ->
    bases = @includeToBaseHash[fileName]
    if bases?
      logger.debug "Bases files for [[ #{fileName} ]]\n#{bases.join('\n')}"
      for base in bases
        @readAndCompile(base)
        @processWatchedDirectories()
    else
      logger.warn "Orphaned partial #{fileName}"
      @done()

  doneStartup: =>
    @processWatchedDirectories()

    baseFilesToCompileNow = []

    # Determine if any includes necessitate a base file compile
    for include, bases of @includeToBaseHash
      for base in bases
        basePath = @findCompiledPath(base)
        if fs.existsSync basePath
          includeTime = fs.statSync(path.join @config.root, include).mtime
          baseTime = fs.statSync(basePath).mtime
          if includeTime > baseTime
            logger.debug "Base [[ #{base} ]] needs compiling because [[ #{include} ]] has been changed recently"
            baseFilesToCompileNow.push(base)
        else
          logger.debug "Base file [[ #{base} ]] hasn't been compiled yet, needs compiling"
          baseFilesToCompileNow.push(base)

    # Determine if any bases need to be compiled based on their own merit
    for base in @baseFiles
      baseCompiledPath = @findCompiledPath(base)
      if fs.existsSync baseCompiledPath
        baseSrcPath = path.join @config.root, base
        if fs.statSync(baseSrcPath).mtime > fs.statSync(baseCompiledPath).mtime
          logger.debug "Base file [[ #{baseSrcPath} ]] needs to be compiled, it has been changed recently"
          baseFilesToCompileNow.push(base)
      else
        logger.debug "Base file [[ #{baseCompiledPath} ]] hasn't been compiled yet, needs compiling"
        baseFilesToCompileNow.push(base)

    baseFilesToCompileNow = _.uniq(baseFilesToCompileNow)

    @initBaseFilesToCompile = baseFilesToCompileNow.length
    if @initBaseFilesToCompile is 0
      logger.debug "No base files to compile, done with startup"
      @_doneStartup()
    else
      @constructor::done = =>
        if !@startupFinished and @initBaseFilesToCompile is 0
          @_doneStartup()

      for base in baseFilesToCompileNow
        logger.debug "Compiling base file [[ #{base} ]]"
        @readAndCompile(base)

  processWatchedDirectories: =>
    @includeToBaseHash = {}
    @allFiles = @_getAllFiles()

    oldBaseFiles = @baseFiles ?= []
    @baseFiles = @_determineBaseFiles()
    allBaseFiles = _.union oldBaseFiles, @baseFiles

    # Change in base files to be compiled, cleanup and message
    if (allBaseFiles.length isnt oldBaseFiles.length or allBaseFiles.length isnt @baseFiles.length) and oldBaseFiles.length > 0
      logger.info "The list of CSS files that Mimosa will compile has changed. Mimosa will now compile the following root files to CSS:"
      logger.info baseFile for baseFile in @baseFiles

    @_importsForFile(baseFile, baseFile) for baseFile in @baseFiles

  _getAllFiles: =>
    files = wrench.readdirSyncRecursive(@config.watch.sourceDir)
      .map (file) =>
        path.join(@config.watch.sourceDir, file)
      .filter (file) =>
        @extensions.some (ext) ->
          file.slice(-ext.length) is ext

    logger.debug "All files for extensions [[ #{@extensions} ]]:\n#{files.join('\n')}"

    files

  # get all imports for a given file, and recurse through
  # those imports until entire tree is built
  _importsForFile: (baseFile, file) ->
    imports = fs.readFileSync(file, 'ascii').match(@importRegex)
    return unless imports?

    logger.debug "Imports for file [[ #{file} ]]: #{imports}"

    for anImport in imports
      @importRegex.lastIndex = 0
      importPath = @importRegex.exec(anImport)[1]
      fullImportFilePath = @_getImportFilePath(baseFile, importPath)

      includeFiles = @allFiles.filter (f) =>
        f = f.replace(path.extname(f), '') unless @partialKeepsExtension
        f.slice(-fullImportFilePath.length) is fullImportFilePath

      for includeFile in includeFiles
        hash = @includeToBaseHash[includeFile]
        if hash?
          logger.debug "Adding base file [[ #{baseFile} ]] to list of base files for include [[ #{includeFile} ]]"
          hash.push(baseFile) if hash.indexOf(baseFile) is -1
        else
          logger.debug "Creating base file entry for include file [[ #{includeFile} ]], adding base file [[ #{baseFile} ]]"
          @includeToBaseHash[includeFile] = [baseFile]
        @_importsForFile(baseFile, includeFile)