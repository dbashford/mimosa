path = require 'path'
fs =   require 'fs'

wrench = require 'wrench'
_ =      require 'lodash'

requireRegister =  require '../../require/register'
fileUtils =        require '../../../util/file'
logger =           require '../../../util/logger'

module.exports = class AbstractTemplateCompiler

  constructor: (config) ->
    if @clientLibrary?
      @mimosaClientLibraryPath = path.join __dirname, "client", "#{@clientLibrary}.js"
      jsDir = path.join config.watch.compiledDir, config.watch.javascriptDir
      @clientPath = path.join jsDir, 'vendor', "#{@clientLibrary}.js"

  lifecycleRegistration: (config, register) ->
    register ['startupExtension'], 'init',         @_gatherFiles,            [@extensions[0]]
    register ['startupExtension'], 'beforeRead',   @_templateNeedsCompiling, [@extensions[0]]
    register ['startupExtension'], 'compile',      @_compile,                [@extensions[0]]
    register ['startupExtension'], 'afterCompile', @_merge,                  [@extensions[0]]

    register ['add','update','remove'], 'init',         @_gatherFiles,            [@extensions...]
    register ['add','update','remove'], 'beforeRead',   @_templateNeedsCompiling, [@extensions...]
    register ['add','update','remove'], 'compile',      @_compile,                 [@extensions...]
    register ['add','update','remove'], 'afterCompile', @_merge,                 [@extensions...]

    unless config.virgin
      register ['remove'],           'beforeRead',  @_testForRemoveClientLibrary, [@extensions...]
      register ['add','update'],     'beforeWrite', @_writeClientLibrary,         [@extensions...]
      register ['startupExtension'], 'beforeWrite', @_writeClientLibrary,         [@extensions[0]]

  _gatherFiles: (config, options, next) =>
    allFiles = wrench.readdirSyncRecursive(config.watch.sourceDir)
      .map (file) => path.join(config.watch.sourceDir, file)

    fileNames = []
    for file in allFiles
      extension = path.extname(file).substring(1)
      fileNames.push(file) if @extensions.indexOf(extension) >= 0

    return next(false) if fileNames.length is 0

    @_testForSameTemplateName(fileNames) unless fileNames.length <= 1

    options.files = fileNames.map (file) ->
      inputFileName:file
      inputFileText:null
      outputFileText:null

    next()

  _compile: (config, options, next) =>
    if not options.files?
      next {text:"Mimosa Error: attempt to compile JavaScript but template files"}
    else
      i = 0
      newFiles = []
      options.files.forEach (file) =>
        logger.debug "Compiling HTML template [[ #{file.inputFileName} ]]"
        @compile file, @__generateTemplateName(file.inputFileName), (err, result) =>
          if err
            logger.error err
          else
            result = "templates['#{templateName}'] = #{result};\n" unless @handlesNamespacing
            file.outputFileText = result
            newFiles.push file

          if ++i is options.files.length
            if newFiles.length is 0
              next(false)
            else
              options.files = newFiles
              next()

  _merge: (config, options, next) =>
    mergedText = @filePrefix()
    options.files.forEach (file) =>
      mergedText += @templatePreamble file.inputFileName
      mergedText += file.outputFileText

    mergedText += @fileSuffix()

    options.files.push
      outputFileText: mergedText
      outputFileName: options.destinationFile()

    next()

  __generateTemplateName: (fileName) ->
    path.basename fileName, path.extname(fileName)

  _testForRemoveClientLibrary: (config, options, next) =>
    if options.templateFileNames?.length is 0
      logger.debug "No template files left, removing [[ #{@clientPath} ]]"
      @removeClientLibrary(next)
    else
      next()

  removeClientLibrary: (callback) ->
    if @clientPath?
      fs.exists @clientPath, (exists) ->
        if exists
          logger.debug "Removing client library [[ #{@clientPath} ]]"
          fs.unlinkSync @clientPath, (err) -> callback()
        else
          callback()
    else
      callback()

  _testForSameTemplateName: (fileNames) ->
    templateHash = {}
    for fileName in fileNames
      templateName = path.basename(fileName, path.extname(fileName))
      if templateHash[templateName]?
        logger.error "Files [[ #{templateHash[templateName]} ]] and [[ #{fileName} ]] result in templates of the same name " +
                     "being created.  You will want to change the name for one of them or they will collide."
      else
        templateHash[templateName] = fileName

  _templateNeedsCompiling: (config, options, next) =>
    fileNames = _.pluck(options.files, 'inputFileName')
    numFiles = fileNames.length

    i = 0
    processFile = =>
      if i < numFiles
        fileUtils.isFirstFileNewer fileNames[i++], options.destinationFile(), cb
      else
        next(false)

    cb = (isNewer) =>
      if isNewer then next() else processFile()

    processFile()

  _writeClientLibrary: (config, options, next) =>
    if !@clientPath? or fs.existsSync @clientPath
      logger.debug "Not going to write template client library"
      return next()

    logger.debug "Writing template client library [[ #{@mimosaClientLibraryPath} ]]"
    fs.readFile @mimosaClientLibraryPath, "ascii", (err, data) =>
      return next({text:"Cannot read client library: #{@mimosaClientLibraryPath}"}) if err?

      fileUtils.writeFile @clientPath, data, (err) =>
        return next({text:"Cannot write client library: #{err}"}) if err?
        next()

  libraryPath: ->
    libPath = "vendor/#{@clientLibrary}"
    requireRegister.aliasForPath(libPath) ? libPath

  templatePreamble: (fileName, templateName) ->
    """
    \n//
    // Source file: [#{fileName}]
    // Template name: [#{@__generateTemplateName(fileName)}]
    //\n
    """