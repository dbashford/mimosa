"use strict"

fs =     require 'fs'
path =   require 'path'

_ =      require 'lodash'
logger =    require 'logmimosa'

fileUtils = require '../../../util/file'

module.exports = class CSSCompiler

  constructor: (config, @extensions, @compiler) ->
    if @compiler.init
      @compiler.init(config, @extensions)

  registration: (config, register) ->
    register ['buildExtension'], 'init',    @_processWatchedDirectories, [@extensions[0]]
    register ['buildExtension'], 'init',    @_findBasesToCompileStartup, [@extensions[0]]
    register ['buildExtension'], 'compile', @_compile,                   [@extensions[0]]

    register ['add'],                               'init',         @_processWatchedDirectories, @extensions
    register ['remove','cleanFile'],                'init',         @_checkState,                @extensions
    register ['add','update','remove','cleanFile'], 'init',         @_findBasesToCompile,        @extensions
    register ['add','update','remove'],             'compile',      @_compile,                   @extensions
    register ['update','remove'],                   'afterCompile', @_processWatchedDirectories, @extensions

  # for clean
  _checkState: (config, options, next) =>
    if @includeToBaseHash?
      next()
    else
      @_processWatchedDirectories(config, options, -> next())

  _findBasesToCompile: (config, options, next) =>
    options.files = []
    if @_isInclude(options.inputFile, @includeToBaseHash)
      bases = @includeToBaseHash[options.inputFile]
      if bases?
        logger.debug "Bases files for [[ #{options.inputFile} ]]\n#{bases.join('\n')}"
        for base in bases
          options.files.push @__baseOptionsObject(base, options)
      else
        # valid only for SASS which has naming convension for partials
        unless options.lifeCycleType is 'remove'
          logger.warn "Orphaned partial file: [[ #{options.inputFile} ]]"
    else
      unless options.lifeCycleType is 'remove'
        options.files.push @__baseOptionsObject(options.inputFile, options)

    next()

  __baseOptionsObject: (base, options) ->
    destFile = options.destinationFile(base)

    inputFileName:base
    outputFileName:destFile
    inputFileText:null
    outputFileText:null

  _compile: (config, options, next) =>
    hasFiles = options.files?.length > 0
    return next() unless hasFiles

    if @delayedCompilerLib
      @compiler.compilerLib = require @compiler.libName
      @delayedCompilerLib = null

    i = 0
    newFiles = []
    done = (file) ->
      newFiles.push file if file
      if ++i is options.files.length
        options.files = newFiles
        next()

    options.files.forEach (file) =>
      fs.exists file.inputFileName, (exists) =>
        if exists
          @compiler.compile file, config, options, (err, result) =>
            if err
              logger.error "File [[ #{file.inputFileName} ]] failed compile. Reason: #{err}", {exitIfBuild:true}
            else
              file.outputFileText = result

            done(file)
        else
          done(file)

  _findBasesToCompileStartup: (config, options, next) =>
    baseFilesToCompileNow = []

    # Determine if any includes necessitate a base file compile
    for include, bases of @includeToBaseHash
      for base in bases
        basePath = options.destinationFile(base)
        if fs.existsSync basePath
          includeTime = fs.statSync(include).mtime
          baseTime = fs.statSync(basePath).mtime
          if includeTime > baseTime
            logger.debug "Base [[ #{base} ]] needs compiling because [[ #{include} ]] has been changed recently"
            baseFilesToCompileNow.push(base)
        else
          logger.debug "Base file [[ #{base} ]] hasn't been compiled yet, needs compiling"
          baseFilesToCompileNow.push(base)

    # Determine if any bases need to be compiled based on their own merit
    for base in @baseFiles
      baseCompiledPath = options.destinationFile(base)
      if fs.existsSync baseCompiledPath
        if fs.statSync(base).mtime > fs.statSync(baseCompiledPath).mtime
          logger.debug "Base file [[ #{base} ]] needs to be compiled, it has been changed recently"
          baseFilesToCompileNow.push(base)
      else
        logger.debug "Base file [[ #{base} ]] hasn't been compiled yet, needs compiling"
        baseFilesToCompileNow.push(base)

    baseFilesToCompile = _.uniq(baseFilesToCompileNow)

    options.files = baseFilesToCompile.map (base) =>
      @__baseOptionsObject(base, options)

    if options.files.length > 0
      options.isVendor = fileUtils.isVendorCSS(config, options.files[0].inputFileName)

    options.isCSS = true

    next()

  _processWatchedDirectories: (config, options, next) =>
    @includeToBaseHash = {}
    allFiles = @__getAllFiles(config)

    oldBaseFiles = @baseFiles ?= []
    @baseFiles = @compiler.determineBaseFiles(allFiles)
    allBaseFiles = _.union oldBaseFiles, @baseFiles

    # Change in base files to be compiled, cleanup and message
    if (allBaseFiles.length isnt oldBaseFiles.length or allBaseFiles.length isnt @baseFiles.length) and oldBaseFiles.length > 0
      logger.info "The list of CSS files that Mimosa will compile has changed. Mimosa will now compile the following root files to CSS:"
      logger.info baseFile for baseFile in @baseFiles

    @__importsForFile(baseFile, baseFile, allFiles) for baseFile in @baseFiles

    next()

  _isInclude: (fileName, includeToBaseHash) ->
    if @compiler.isInclude
      @compiler.isInclude(fileName, includeToBaseHash)
    else
      includeToBaseHash[fileName]?

  __getAllFiles: (config) =>
    files = fileUtils.readdirSyncRecursive(config.watch.sourceDir, config.watch.exclude, config.watch.excludeRegex)
      .filter (file) =>
        @extensions.some (ext) ->
          file.slice(-(ext.length+1)) is ".#{ext}"

    # logger.debug "All files for extensions [[ #{@extensions} ]]:\n#{files.join('\n')}"

    files

  # get all imports for a given file, and recurse through
  # those imports until entire tree is built
  __importsForFile: (baseFile, file, allFiles) ->
    imports = fs.readFileSync(file, 'utf8').match(@compiler.importRegex)
    return unless imports?

    logger.debug "Imports for file [[ #{file} ]]: #{imports}"

    for anImport in imports

      @compiler.importRegex.lastIndex = 0
      importPath = @compiler.importRegex.exec(anImport)[1]
      fullImportFilePath = @compiler.getImportFilePath(file, importPath)

      includeFiles = allFiles.filter (f) =>
        f = f.replace(path.extname(f), '') unless @compiler.partialKeepsExtension
        f.slice(-fullImportFilePath.length) is fullImportFilePath

      for includeFile in includeFiles
        hash = @includeToBaseHash[includeFile]
        if hash?
          logger.debug "Adding base file [[ #{baseFile} ]] to list of base files for include [[ #{includeFile} ]]"
          hash.push(baseFile) if hash.indexOf(baseFile) is -1
        else
          logger.debug "Creating base file entry for include file [[ #{includeFile} ]], adding base file [[ #{baseFile} ]]"
          @includeToBaseHash[includeFile] = [baseFile]
        @__importsForFile(baseFile, includeFile, allFiles)