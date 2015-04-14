fs =     require 'fs'
path =   require 'path'
_ =      require 'lodash'
logger =    require 'logmimosa'
fileUtils = require '../../util/file'

_baseOptionsObject = (config, fileName) ->
  destFile = buildDestinationFile(config, fileName)

  inputFileName:fileName
  outputFileName:destFile
  inputFileText:null
  outputFileText:null

_notCompilerFile = (file, compilerExtensions) ->
  fileExtension = path.extname(file.inputFileName).replace(/\./,'')

  # cannot find extension in list of extensions
  # or extension is css and therefore not a compiler file?
  compilerExtensions.indexOf(fileExtension) is -1 or fileExtension is "css"

_isInclude = (fileName, includeToBaseHash, compiler) ->
  if compiler.isInclude
    compiler.isInclude(fileName, includeToBaseHash)
  else
    includeToBaseHash[fileName]?

buildDestinationFile = (config, fileName) ->
  baseCompDir = fileName.replace(config.watch.sourceDir, config.watch.compiledDir)
  baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".css"

getAllFiles = (config, extensions, canFullyImportCSS) ->
  files = fileUtils.readdirSyncRecursive(config.watch.sourceDir, config.watch.exclude, config.watch.excludeRegex, true)
    .filter (file) ->
      extensions.some (ext) ->
        fileExt = file.slice(-(ext.length+1))
        fileExt is ".#{ext}" or (fileExt is ".css" and canFullyImportCSS)

  files

compile = (config, options, next, extensions, compiler) ->
  hasFiles = options.files?.length > 0
  return next() unless hasFiles

  i = 0
  done = ->
    if ++i is options.files.length
      next()

  options.files.forEach (file) ->
    if (_notCompilerFile(file, extensions))
      done()
    else fs.exists file.inputFileName, (exists) ->
      if exists
        compiler.compile config, file, (err, result) ->
          if err
            logger.error "File [[ #{file.inputFileName} ]] failed compile. Reason: #{err}", {exitIfBuild:true}
          else
            file.outputFileText = result
          done()
      else
        done()


# Determines which base files need compiling based on their
# includes having been written more recently than it
_baseFilesToCompileFromChangedInclude = (config, includeToBaseHash) ->
  toCompile = []

  for include, bases of includeToBaseHash
    for base in bases
      basePath = buildDestinationFile(config, base)
      if fs.existsSync basePath
        includeTime = fs.statSync(include).mtime
        baseTime = fs.statSync(basePath).mtime
        if includeTime > baseTime
          if logger.isDebug()
            logger.debug "Base [[ #{base} ]] needs compiling because [[ #{include} ]] has been changed recently"
          toCompile.push(base)
      else
        if logger.isDebug()
          logger.debug "Base file [[ #{base} ]] hasn't been compiled yet, needs compiling"
        toCompile.push(base)

  return toCompile;

# determines base files to compile because compiled file
# doesn't exist or because source file is newer than compiled file
_changedBaseFilesToCompile = (config, baseFiles) ->
  toCompile = []

  for base in baseFiles
    baseCompiledPath = buildDestinationFile(config, base)
    if fs.existsSync baseCompiledPath
      if fs.statSync(base).mtime > fs.statSync(baseCompiledPath).mtime
        if logger.isDebug()
          logger.debug "Base file [[ #{base} ]] needs to be compiled, it has been changed recently"
        toCompile.push(base)
    else
      if logger.isDebug()
        logger.debug "Base file [[ #{base} ]] hasn't been compiled yet, needs compiling"
      toCompile.push(base)

  return toCompile;

findBasesToCompileStartup = (config, options, next, includeToBaseHash, baseFiles) ->
  # Determine if any includes necessitate a base file compile
  includeForcedBaseFiles = _baseFilesToCompileFromChangedInclude( config, includeToBaseHash)
  updatedBasedFiles = _changedBaseFilesToCompile( config, baseFiles)
  # Determine if any bases need to be compiled based on their own merit
  baseFilesToCompileNow = includeForcedBaseFiles.concat( updatedBasedFiles );
  baseFilesToCompile = _.uniq( baseFilesToCompileNow );

  options.files = baseFilesToCompile.map (base) ->
    _baseOptionsObject(config, base)

  if options.files.length > 0
    options.isVendor = fileUtils.isVendorCSS(config, options.files[0].inputFileName)

    # TODO move this to .map above to avoid repetitive iteration
    options.files.forEach (f) ->
      f.isVendor = fileUtils.isVendorCSS(config, f.inputFileName)

  options.isCSS = true

  next()

# generate import paths from inside file
_findImportsInFile = (file, compiler) ->
  if fs.existsSync(file)
    importMatches = fs.readFileSync(file, 'utf8').match(compiler.importRegex)
  return [] unless importMatches?
  if logger.isDebug()
    logger.debug "Imports for file [[ #{file} ]]: #{importMatches}"

  imports = []
  for anImport in importMatches
    compiler.importRegex.lastIndex = 0
    anImport = compiler.importRegex.exec(anImport)[1]
    if compiler.importSplitRegex
      imports.push.apply(imports, anImport.split(compiler.importSplitRegex))
    else
      imports.push(anImport)

  return imports;

#
_findExistingImportFullPath = (fullImportFilePath, compiler, allFiles) ->
  if path.extname(fullImportFilePath) is ".css" and compiler.canFullyImportCSS
    [fullImportFilePath]
  else
    allFiles.filter (f) ->
      if path.extname( fullImportFilePath ) is ''
        f = f.replace(path.extname(f), '')
      f.slice(-fullImportFilePath.length) is fullImportFilePath

# get all imports for a given file, and recurse through
# those imports until entire tree is built
importsForFile = (baseFile, file, allFiles, compiler, includeToBaseHash) ->

  # find imports in file
  imports = _findImportsInFile(file, compiler);

  # iterate over all the import paths in the file
  for importPath in imports

    # get the file path from the compiler
    fullImportFilePaths = compiler.getImportFilePath(file, importPath)
    unless Array.isArray(fullImportFilePaths)
      fullImportFilePaths = [fullImportFilePaths]

    # iterate over the all the possible forms of the full path
    # for the import on the file system
    for fullImportFilePath in fullImportFilePaths

      # generate the full path to existing ile
      includeFiles = _findExistingImportFullPath(fullImportFilePath, compiler, allFiles);

      # iterate over includes
      for includeFile in includeFiles

        hash = includeToBaseHash[includeFile]

        if hash?
          if logger.isDebug()
            logger.debug "Adding base file [[ #{baseFile} ]] to list of base files for include [[ #{includeFile} ]]"
          hash.push(baseFile) if hash.indexOf(baseFile) is -1
        else
          if fs.existsSync includeFile
            if logger.isDebug()
              logger.debug "Creating base file entry for include file [[ #{includeFile} ]], adding base file [[ #{baseFile} ]]"
            includeToBaseHash[includeFile] = [baseFile]

        # do not recurse if is circular reference
        if baseFile is includeFile
          logger.info "Circular import reference found in file [[ #{baseFile} ]]"
        else
          importsForFile(baseFile, includeFile, allFiles, compiler, includeToBaseHash)

findBasesToCompile = (config, options, next, extensions, includeToBaseHash, compiler, baseFiles) ->
  # clear out any compiler related files, leave any that are not from this compiler
  options.files = options.files.filter (file) ->
    _notCompilerFile( file, extensions)

  if _isInclude(options.inputFile, includeToBaseHash, compiler)
    # check to see if also is base
    if baseFiles.indexOf(options.inputFile) > -1
      options.files.push _baseOptionsObject(config, options.inputFile)

    # file is include so need to find bases to compile for it
    bases = includeToBaseHash[options.inputFile]
    if bases?
      if logger.isDebug()
        logger.debug "Bases files for [[ #{options.inputFile} ]]\n#{bases.join('\n')}"
      for base in bases
        options.files.push _baseOptionsObject(config, base)
  else
    # file is passing through, isn't include, is base of its own and needs to be compiled
    # unless it is a remove (since it is deleted)
    if options.lifeCycleType isnt 'remove' and path.extname(options.inputFile) isnt ".css"
      options.files.push _baseOptionsObject(config, options.inputFile)

  # protect against compiling the same file multiple times
  # ... circular references and such
  options.files = _.uniq options.files, (f) -> f.outputFileName

  next()

module.exports = {
  buildDestinationFile: buildDestinationFile,
  getAllFiles: getAllFiles,
  compile: compile,
  findBasesToCompileStartup: findBasesToCompileStartup,
  importsForFile: importsForFile,
  findBasesToCompile: findBasesToCompile,
  _baseOptionsObject: _baseOptionsObject,
  _notCompilerFile: _notCompilerFile,
  _isInclude: _isInclude,
  _changedBaseFilesToCompile: _changedBaseFilesToCompile,
  _baseFilesToCompileFromChangedInclude: _baseFilesToCompileFromChangedInclude,
  _findImportsInFile: _findImportsInFile,
  _findExistingImportFullPath: _findExistingImportFullPath
}