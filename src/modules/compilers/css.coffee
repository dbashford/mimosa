"use strict"

fs =     require 'fs'
path =   require 'path'

_ =      require 'lodash'
logger =    require 'logmimosa'

fileUtils = require '../../util/file'

__buildDestinationFile = (config, fileName) ->
  baseCompDir = fileName.replace(config.watch.sourceDir, config.watch.compiledDir)
  baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".css"

__baseOptionsObject = (config, base) ->
  destFile = __buildDestinationFile(config, base)

  inputFileName:base
  outputFileName:destFile
  inputFileText:null
  outputFileText:null

_init = (config, options, next) ->
  options.destinationFile = (fileName) ->
    __buildDestinationFile config, fileName
  next()

module.exports = class CSSCompiler

  constructor: (config, @compiler) ->
    @extensions = @compiler.extensions(config)

  registration: (config, register) ->
    register ['add','update','remove','cleanFile','buildExtension'], 'init', _init, @extensions

    register ['buildExtension'], 'init',    @_processWatchedDirectories, [@extensions[0]]
    register ['buildExtension'], 'init',    @_findBasesToCompileStartup, [@extensions[0]]
    register ['buildExtension'], 'compile', @_compile,                   [@extensions[0]]

    exts = @extensions
    if @compiler.canFullyImportCSS
      exts.push "css"

    register ['add'],                               'init',         @_processWatchedDirectories, exts
    register ['remove','cleanFile'],                'init',         @_checkState,                exts
    register ['add','update','remove','cleanFile'], 'init',         @_findBasesToCompile,        exts
    register ['add','update','remove'],             'compile',      @_compile,                   exts
    register ['update','remove'],                   'afterCompile', @_processWatchedDirectories, exts

  # for clean
  _checkState: (config, options, next) =>
    if @includeToBaseHash?
      next()
    else
      @_processWatchedDirectories(config, options, -> next())

  _findBasesToCompile: (config, options, next) =>
    # clear out any compiler related files, leave any that are not from this compiler
    options.files = options.files.filter @__notCompilerFile

    if @_isInclude(options.inputFile, @includeToBaseHash)
      # check to see if also is base
      if @baseFiles.indexOf(options.inputFile) > -1
        options.files.push __baseOptionsObject(config, options.inputFile)

      # file is include so need to find bases to compile for it
      bases = @includeToBaseHash[options.inputFile]
      if bases?
        if logger.isDebug()
          logger.debug "Bases files for [[ #{options.inputFile} ]]\n#{bases.join('\n')}"

        for base in bases
          options.files.push __baseOptionsObject(config, base)
      # else
        # valid only for SASS which has naming convension for partials
        # unless options.lifeCycleType is 'remove'
          # logger.warn "Orphaned partial file: [[ #{options.inputFile} ]]"
    else
      # file is passing through, isn't include, is base of its own and needs to be compiled
      # unless it is a remove (since it is deleted)
      if options.lifeCycleType isnt 'remove' and path.extname(options.inputFile) isnt ".css"
        options.files.push __baseOptionsObject(config, options.inputFile)

    # protect against compiling the same file multiple times
    # ... circular references and such
    options.files = _.uniq options.files, (f) -> f.outputFileName

    next()

  _compile: (config, options, next) =>
    hasFiles = options.files?.length > 0
    return next() unless hasFiles

    i = 0
    done = ->
      if ++i is options.files.length
        next()

    options.files.forEach (file) =>
      if (@__notCompilerFile(file))
        done()
      else fs.exists file.inputFileName, (exists) =>
        if exists
          @compiler.compile config, file, (err, result) =>
            if err
              logger.error "File [[ #{file.inputFileName} ]] failed compile. Reason: #{err}", {exitIfBuild:true}
            else
              file.outputFileText = result
            done()
        else
          done()

  __notCompilerFile: (file) =>
    # css files are processed by all compilers
    # result is some compilers can add files to other compilers workflows
    # as css file flows through, need to be certain file belongs
    ext = path.extname(file.inputFileName).replace(/\./,'')
    @extensions.indexOf(ext) is -1 or ext is "css"

  _findBasesToCompileStartup: (config, options, next) =>
    baseFilesToCompileNow = []

    # Determine if any includes necessitate a base file compile
    for include, bases of @includeToBaseHash
      for base in bases
        basePath = __buildDestinationFile(config, base)
        if fs.existsSync basePath
          includeTime = fs.statSync(include).mtime
          baseTime = fs.statSync(basePath).mtime
          if includeTime > baseTime
            if logger.isDebug()
              logger.debug "Base [[ #{base} ]] needs compiling because [[ #{include} ]] has been changed recently"
            baseFilesToCompileNow.push(base)
        else
          if logger.isDebug()
            logger.debug "Base file [[ #{base} ]] hasn't been compiled yet, needs compiling"
          baseFilesToCompileNow.push(base)

    # Determine if any bases need to be compiled based on their own merit
    for base in @baseFiles
      baseCompiledPath = __buildDestinationFile(config, base)
      if fs.existsSync baseCompiledPath
        if fs.statSync(base).mtime > fs.statSync(baseCompiledPath).mtime
          if logger.isDebug()
            logger.debug "Base file [[ #{base} ]] needs to be compiled, it has been changed recently"
          baseFilesToCompileNow.push(base)
      else
        if logger.isDebug()
          logger.debug "Base file [[ #{base} ]] hasn't been compiled yet, needs compiling"
        baseFilesToCompileNow.push(base)

    baseFilesToCompile = _.uniq(baseFilesToCompileNow)

    options.files = baseFilesToCompile.map (base) ->
      __baseOptionsObject(config, base)

    if options.files.length > 0
      options.isVendor = fileUtils.isVendorCSS(config, options.files[0].inputFileName)
      options.files.forEach (f) ->
        f.isVendor = fileUtils.isVendorCSS(config, f.inputFileName)

    options.isCSS = true

    next()

  _processWatchedDirectories: (config, options, next) =>
    @includeToBaseHash = {}
    allFiles = @__getAllFiles(config)

    oldBaseFiles = @baseFiles ?= []
    @baseFiles = @compiler.determineBaseFiles(allFiles).filter (file) ->
      path.extname(file) isnt '.css'
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
    files = fileUtils.readdirSyncRecursive(config.watch.sourceDir, config.watch.exclude, config.watch.excludeRegex, true)
      .filter (file) =>
        @extensions.some (ext) ->
          fileExt = file.slice(-(ext.length+1))
          fileExt is ".#{ext}" or (fileExt is ".css" and @compiler.canFullyImportCSS)

    # logger.debug "All files for extensions [[ #{@extensions} ]]:\n#{files.join('\n')}"

    files

  # get all imports for a given file, and recurse through
  # those imports until entire tree is built
  __importsForFile: (baseFile, file, allFiles) ->
    if fs.existsSync(file)
      importMatches = fs.readFileSync(file, 'utf8').match(@compiler.importRegex)

    return unless importMatches?

    if logger.isDebug()
      logger.debug "Imports for file [[ #{file} ]]: #{importMatches}"

    imports = []
    for anImport in importMatches
      @compiler.importRegex.lastIndex = 0
      anImport = @compiler.importRegex.exec(anImport)[1]
      if @compiler.importSplitRegex
        imports.push.apply(imports, anImport.split(@compiler.importSplitRegex))
      else
        imports.push(anImport)

    # iterate over all the import paths in the file
    for importPath in imports

      fullImportFilePaths = @compiler.getImportFilePath(file, importPath)
      unless Array.isArray(fullImportFilePaths)
        fullImportFilePaths = [fullImportFilePaths]

      # iterate over the all the possible forms of the full path for the import on the file system
      for fullImportFilePath in fullImportFilePaths

        includeFiles = if path.extname(fullImportFilePath) is ".css" and @compiler.canFullyImportCSS
          [fullImportFilePath]
        else
          allFiles.filter (f) =>
            if path.extname( fullImportFilePath ) is ''
              f = f.replace(path.extname(f), '')
            f.slice(-fullImportFilePath.length) is fullImportFilePath

        # now we've found files for includes on the file system, iterate over them
        for includeFile in includeFiles

          hash = @includeToBaseHash[includeFile]

          if hash?
            if logger.isDebug()
              logger.debug "Adding base file [[ #{baseFile} ]] to list of base files for include [[ #{includeFile} ]]"
            hash.push(baseFile) if hash.indexOf(baseFile) is -1
          else
            if fs.existsSync includeFile
              if logger.isDebug()
                logger.debug "Creating base file entry for include file [[ #{includeFile} ]], adding base file [[ #{baseFile} ]]"
              @includeToBaseHash[includeFile] = [baseFile]

          if baseFile is includeFile
            logger.info "Circular import reference found in file [[ #{baseFile} ]]"
          else
            @__importsForFile(baseFile, includeFile, allFiles)