"use strict"

path = require 'path'
fs =   require 'fs'

_ =      require 'lodash'
logger =           require 'logmimosa'

fileUtils =        require '../../../util/file'

try
  requireRegister =  require 'mimosa-require'
catch err
  logger.debug "mimosa-require not installed, so cannot use inside template compiler"

module.exports = class AbstractTemplateCompiler

  constructor: (config) ->
    if @clientLibrary?
      @mimosaClientLibraryPath = path.join __dirname, "client", "#{@clientLibrary}.js"
      jsDir = path.join config.watch.compiledDir, config.watch.javascriptDir
      @clientPath = path.join jsDir, 'vendor', "#{@clientLibrary}.js"

  registration: (config, register) ->

    register ['buildExtension'],        'init',       @_gatherFiles,            [@extensions[0]]
    register ['add','update','remove'], 'init',       @_gatherFiles,            [@extensions...]
    register ['buildExtension'],        'beforeRead', @_templateNeedsCompiling, [@extensions[0]]
    register ['add','update'],          'beforeRead', @_templateNeedsCompiling, [@extensions...]
    register ['buildExtension'],        'compile',    @_compile,                [@extensions[0]]
    register ['add','update','remove'], 'compile',    @_compile,                [@extensions...]

    unless config.isVirgin
      register ['cleanFile'],             'init',         @_removeFiles, [@extensions...]
      register ['buildExtension'],        'afterCompile', @_merge,       [@extensions[0]]
      register ['add','update','remove'], 'afterCompile', @_merge,       [@extensions...]

      # TODO, TEST THIS
      register ['remove'],                'init',         @_testForRemoveClientLibrary, [@extensions...]

      register ['add','update'],   'afterCompile', @_readInClientLibrary,        [@extensions...]
      register ['buildExtension'], 'afterCompile', @_readInClientLibrary,        [@extensions[0]]

  _gatherFiles: (config, options, next) =>
    options.files = []
    for outputFileConfig in config.template.outputFiles
      if options.inputFile?
        if options.inputFile.indexOf(path.join(outputFileConfig.folder, path.sep)) is 0
          @__gatherFolderFilesForOutputFileConfig(config, options, outputFileConfig.folder)
      else
        @__gatherFolderFilesForOutputFileConfig(config, options, outputFileConfig.folder)

    next()

  __gatherFolderFilesForOutputFileConfig: (config, options, folder) =>
    for folderFile in @__gatherFilesForFolder(config, options, folder)
      found = false
      for f in options.files
        if f.inputFileName is folderFile.inputFileName
          f.outputFolders = f.outputFolders.concat folderFile.outputFolders
      unless found
        options.files.push folderFile

  __gatherFilesForFolder: (config, options, folder) =>
    allFiles = fileUtils.readdirSyncRecursive(folder, config.watch.exclude, config.watch.excludeRegex)

    fileNames = []
    for file in allFiles
      extension = path.extname(file).substring(1)
      if _.any(@extensions, (e) -> e is extension)
        fileNames.push(file)

    if fileNames.length is 0
      []
    else
      @_testForSameTemplateName(fileNames) unless fileNames.length is 1
      fileNames.map (file) ->
        inputFileName:file
        inputFileText:null
        outputFileText:null
        outputFolders:[folder]

  _compile: (config, options, next) =>
    return next() if options.files?.length is 0

    i = 0
    newFiles = []
    options.files.forEach (file) =>
      logger.debug "Compiling HTML template [[ #{file.inputFileName} ]]"
      templateName = @__generateTemplateName(file.inputFileName)
      @compile file, templateName, (err, result) =>
        if err
          logger.error "Template [[ #{file.inputFileName} ]] failed to compile. Reason: #{err}"
        else
          result = "templates['#{templateName}'] = #{result}\n" unless @handlesNamespacing
          file.outputFileText = result
          newFiles.push file

        if ++i is options.files.length
          # end of the road for virgin, log it
          if config.isVirgin and options.files.length is newFiles.length
            logger.success "All templates compiled successfully.", options

          options.files = newFiles
          next()

  _merge: (config, options, next) =>
    return next() unless options.files?.length > 0

    amdPrefix = @amdPrefix(config)
    amdSuffix = @amdSuffix()

    for outputFileConfig in config.template.outputFiles
      mergedText = ""
      options.files.forEach (file) =>
        if file.inputFileName?.indexOf(path.join(outputFileConfig.folder, path.sep)) is 0
          unless config.isOptimize
            mergedText += @templatePreamble file.inputFileName
          mergedText += file.outputFileText

      continue if mergedText is ""

      options.files.push
        outputFileText: amdPrefix + mergedText + amdSuffix
        outputFileName: options.destinationFile(@constructor.base, outputFileConfig.folder)
        isTemplate:true

    next()

  __generateTemplateName: (fileName) ->
    path.basename fileName, path.extname(fileName)

  _removeFiles: (config, options, next) =>
    total = if config.template.outputFiles
      config.template.outputFiles.length + 1
    else
      2

    i = 0
    done = ->
      next() if ++i is total

    @removeClientLibrary(@clientPath, done)
    for outputFileConfig in config.template.outputFiles
      @removeClientLibrary(options.destinationFile(@constructor.base, outputFileConfig.folder), done)

  _testForRemoveClientLibrary: (config, options, next) =>
    if options.files?.length is 0
      logger.info "No template files left, removing template based assets"
      @_removeFiles(config, options, next)
    else
      next()

  removeClientLibrary: (clientPath, cb) ->
    if clientPath?
      fs.exists clientPath, (exists) =>
        if exists
          logger.debug "Removing client library [[ #{clientPath} ]]"
          fs.unlink clientPath, (err) ->
            logger.success "Deleted file [[ #{clientPath} ]]" unless err
            cb()
        else
          cb()
    else
      cb()

  _testForSameTemplateName: (fileNames) ->
    templateHash = {}
    fileNames.forEach (fileName) ->
      templateName = path.basename(fileName, path.extname(fileName))
      if templateHash[templateName]?
        logger.error "Files [[ #{templateHash[templateName]} ]] and [[ #{fileName} ]] result in templates of the same name " +
                     "being created.  You will want to change the name for one of them or they will collide."
      else
        templateHash[templateName] = fileName

  __templateNeedsCompilingForOutput: (files, output, next) ->
    fileNames = _.pluck(files, 'inputFileName')
    numFiles = fileNames.length

    i = 0
    processFile = =>
      if i < numFiles
        fileUtils.isFirstFileNewer fileNames[i++], output, cb
      else
        next(false)

    cb = (isNewer) =>
      if isNewer
        next(true)
      else
        processFile()

    processFile()

  _templateNeedsCompiling: (config, options, next) =>
    return next(false) if options.files?.length is 0

    keepFilesLog = {}
    done = (folder, keep) ->
      keepFilesLog[folder] = keep
      if Object.keys(keepFilesLog).length is config.template.outputFiles.length
        for folder, keep of keepFilesLog
          unless keep
            for f in options.files
              if f.outputFolders
                f.outputFolders = _.without(f.outputFolders, folder)

        newFiles = []
        for f in options.files
          if f.outputFolders?.length > 0
            newFiles.push f
        options.files = newFiles
        next()

    config.template.outputFiles.forEach (outputFilesConfig) =>
      destFile = options.destinationFile(@constructor.base, outputFilesConfig.folder)
      files = options.files.filter (f) -> f.outputFolders?.indexOf(outputFilesConfig.folder) isnt -1
      @__templateNeedsCompilingForOutput files, destFile, (keepFiles) ->
        done(outputFilesConfig.folder, keepFiles)

  _readInClientLibrary: (config, options, next) =>
    if !@clientPath? or fs.existsSync @clientPath
      logger.debug "Not going to write template client library"
      return next()

    logger.debug "Adding template client library [[ #{@mimosaClientLibraryPath} ]] to list of files to write"

    fs.readFile @mimosaClientLibraryPath, "utf8", (err, data) =>
      if err
        logger.error("Cannot read client library [[ #{@mimosaClientLibraryPath} ]]")
        return next()

      options.files.push
        outputFileName: @clientPath
        outputFileText: data

      next()

  libraryPath: ->
    libPath = "vendor/#{@clientLibrary}"
    requireRegister?.aliasForPath(libPath) ? libPath

  templatePreamble: (fileName) ->
    """
    \n//
    // Source file: [#{fileName}]
    // Template name: [#{@__generateTemplateName(fileName)}]
    //\n
    """