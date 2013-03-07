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

module.exports = class TemplateCompiler

  constructor: (config) ->
    if @clientLibrary?
      @mimosaClientLibraryPath = path.join __dirname, "client", "#{@clientLibrary}.js"
      jsDir = path.join config.watch.compiledDir, config.watch.javascriptDir
      @clientPath = path.join jsDir, 'vendor', "#{@clientLibrary}.js"

  registration: (config, register) ->
    # need to put this before gatherFiles register
    unless config.isVirgin
      # TODO, TEST THIS
      register ['remove'], 'init', @_testForRemoveClientLibrary, @extensions

    register ['buildExtension'],        'init',       @_gatherFiles, [@extensions[0]]
    register ['add','update','remove'], 'init',       @_gatherFiles, @extensions
    register ['buildExtension'],        'compile',    @_compile,     [@extensions[0]]
    register ['add','update','remove'], 'compile',    @_compile,     @extensions

    unless config.isVirgin
      register ['cleanFile'],             'init',         @_removeFiles, @extensions

      register ['buildExtension'],        'afterCompile', @_merge,       [@extensions[0]]
      register ['add','update','remove'], 'afterCompile', @_merge,       @extensions

      register ['add','update'],   'afterCompile', @_readInClientLibrary, @extensions
      register ['buildExtension'], 'afterCompile', @_readInClientLibrary, [@extensions[0]]

  _gatherFiles: (config, options, next) =>
    options.files = []
    for outputFileConfig in config.template.output
      if options.inputFile?
        for folder in outputFileConfig.folders
          if options.inputFile.indexOf(path.join(folder, path.sep)) is 0
            @__gatherFolderFilesForOutputFileConfig(config, options, outputFileConfig.folders)
            break
      else
        @__gatherFolderFilesForOutputFileConfig(config, options, outputFileConfig.folders)

    next(options.files.length > 0)

  __gatherFolderFilesForOutputFileConfig: (config, options, folders) =>
    for folder in folders
      for folderFile in @__gatherFilesForFolder(config, options, folder)
        if _.pluck(options.files, 'inputFileName').indexOf(folderFile.inputFileName) is -1
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
      fileNames.map (file) ->
        inputFileName:file
        inputFileText:null
        outputFileText:null

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

    prefix = @prefix config
    suffix = @suffix config

    for outputFileConfig in config.template.output

      # if post-build, need to check to see if the outputFileConfig is valid for this compile
      if options.inputFile
        found = false
        for folder in outputFileConfig.folders
          if options.inputFile.indexOf(folder) is 0
            found = true
            break
        continue unless found

      mergedText = ""
      mergedFiles = []
      options.files.forEach (file) =>
        for folder in outputFileConfig.folders
          if file.inputFileName?.indexOf(path.join(folder, path.sep)) is 0
            mergedFiles.push file.inputFileName
            unless config.isOptimize
              mergedText += @templatePreamble file.inputFileName
            mergedText += file.outputFileText
            break

      @__testForSameTemplateName(mergedFiles) unless mergedFiles.length <= 1

      continue if mergedText is ""

      options.files.push
        outputFileText: prefix + mergedText + suffix
        outputFileName: options.destinationFile(@constructor.base, outputFileConfig.folders)
        isTemplate:true

    next()

  __generateTemplateName: (fileName) ->
    path.basename fileName, path.extname(fileName)

  _removeFiles: (config, options, next) =>
    total = if config.template.output
      config.template.output.length + 1
    else
      2

    i = 0
    done = ->
      next() if ++i is total

    @removeClientLibrary(@clientPath, done)
    for outputFileConfig in config.template.output
      @removeClientLibrary(options.destinationFile(@constructor.base, outputFileConfig.folders), done)

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

  __testForSameTemplateName: (fileNames) ->
    templateHash = {}
    fileNames.forEach (fileName) ->
      templateName = path.basename(fileName, path.extname(fileName))
      if templateHash[templateName]?
        logger.error "Files [[ #{templateHash[templateName]} ]] and [[ #{fileName} ]] result in templates of the same name " +
                     "being created.  You will want to change the name for one of them or they will collide."
      else
        templateHash[templateName] = fileName

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