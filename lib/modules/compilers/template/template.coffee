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
    register ['startupExtension'],      'init',       @_gatherFiles,            [@extensions[0]]
    register ['startupExtension'],      'beforeRead', @_templateNeedsCompiling, [@extensions[0]]
    register ['startupExtension'],      'read',       @_readTemplateFiles,      [@extensions[0]]
    register ['startupExtension'],      'compile',    @compile,                 [@extensions[0]]

    register ['add','update','remove'], 'init',       @_gatherFiles,            [@extensions...]
    register ['add','update','remove'], 'beforeRead', @_templateNeedsCompiling, [@extensions...]
    register ['add','update','remove'], 'read',       @_readTemplateFiles,      [@extensions...]
    register ['add','update','remove'], 'compile',    @compile,                 [@extensions...]

    unless config.virgin
      register ['remove'],           'beforeRead',  @_testForRemoveClientLibrary, [@extensions...]
      register ['add','update'],    'beforeWrite', @_writeClientLibrary,         [@extensions...]
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

    ###
    TODO, register multiple files on options.files, then read each, compile each, and
    merge together after
    ###

    options.templateFileNames = fileNames
    next()

  _readTemplateFiles: (config, options, next) ->
    options.templateContentByName = {}
    numFiles = options.templateFileNames.length
    filesDone = 0
    done = ->
      options.templateContentByName
      next() if ++filesDone is options.templateFileNames.length

    options.templateFileNames.forEach (fileName) ->
      fs.readFile fileName, "ascii", (err, data) ->
        templateName = path.basename fileName, path.extname(fileName)
        options.templateContentByName[templateName] = [fileName, data]
        done()

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
    fileNames = options.templateFileNames
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
    // Template name: [#{templateName}]
    //\n
    """

  addTemplateToOutput: (fileName, templateName, source) =>
    """
    #{@templatePreamble(fileName, templateName)}
    templates['#{templateName}'] = #{source};\n
    """