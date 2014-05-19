"use strict"

path = require 'path'
fs =   require 'fs'

_ =      require 'lodash'
logger = require 'logmimosa'

JavaScriptCompiler = require( "./javascript" )
CSSCompiler = require( "./css" )
TemplateCompiler = require( "./template" )
MiscCompiler = require( "./misc" )

compilers = []

templateLibrariesBeingUsed = 0

_testDifferentTemplateLibraries = (config, options, next) ->
  hasFiles = options.files?.length > 0
  return next() unless hasFiles
  return next() unless typeof config.template.outputFileName is "string"

  if ++templateLibrariesBeingUsed is 2
    logger.error "More than one template library is being used, but multiple template.outputFileName entries not found." +
      " You will want to configure a map of template.outputFileName entries in your config, otherwise you will only get" +
      " template output for one of the libraries."

  next()

exports.setupCompilers = (config) ->

  if compilers.length
    compilers = []

  for modName, mod of config.installedModules
    if mod.compilerType
      if logger.isDebug()
        logger.debug( "Found compiler [[ #{mod.name} ]], adding to array of compilers");
      compilers.push mod

  for compiler in compilers
    exts = compiler.extensions(config)
    config.extensions[compiler.compilerType].push(exts...)

  for type, extensions of config.extensions
    config.extensions[type] = _.uniq(extensions)

  # sort copy and misc to the end of compilers list
  # as they are not to override other compilers,
  # for instance if two compilers both register
  # for same extension
  if config.resortCompilers
    backloadCompilers = ["copy", "misc"]
    copyMisc = _.remove compilers, (comp) ->
      backloadCompilers.indexOf( comp.compilerType ) > -1
    compilers = compilers.concat copyMisc

exports.registration = (config, register) ->
  for compiler in compilers
    if logger.isDebug()
      logger.debug "Creating compiler " + compiler.name

    CompilerClass = switch compiler.compilerType
      when "copy" then MiscCompiler
      when "misc" then MiscCompiler
      when "javascript" then JavaScriptCompiler
      when "template" then TemplateCompiler
      when "css" then CSSCompiler
    compilerInstance = new CompilerClass( config, compiler )
    compilerInstance.name = compiler.name
    compilerInstance.registration(config, register)
    if compiler.registration
      compiler.registration( config, register )

    if logger.isDebug()
      logger.debug "Done with compiler " + compiler.name

  if config.template
    register ['buildExtension'], 'complete', _testDifferentTemplateLibraries, config.extensions.template

exports.defaults = ->
  template:
    writeLibrary: true
    wrapType: "amd"
    commonLibPath: null
    nameTransform:"fileName"
    outputFileName: "javascripts/templates"

exports.placeholder = ->
  """
  \t

    template:                         # overall template object can be set to null if no
                                      # templates being used
      writeLibrary: true              # Whether or not to write a client library for
                                      # any template compilers
      nameTransform: "fileName"       # means by which Mimosa creates the name for each
                                      # template, options: default "fileName" is name of file,
                                      # "filePath" is path of file after watch.sourceDir
                                      # with the extension dropped, a supplied regex can be
                                      # used to remove any unwanted portions of the filePath,
                                      # and a provided function will be called with the
                                      # filePath as input
      wrapType: "amd"                 # The type of module wrapping for the output templates
                                      # file. Possible values: "amd", "common", "none".
      commonLibPath: null             # Valid when wrapType is 'common'. The path to the
                                      # client library. Some libraries do not have clients
                                      # therefore this is not strictly required when choosing
                                      # the common wrapType.
      outputFileName: "javascripts/templates"  # the file all templates are compiled into,
                                               # is relative to watch.sourceDir.

      # outputFileName:                 # outputFileName Alternate Config 1
        # hogan:"hogans"                # Optionally outputFileName can be provided an object of
        # jade:"jades"                  # compiler name to file name in the event you are using
                                        # multiple templating libraries.

      # output: [{                      # output Alternate Config 2
      #   folders:[""]                  # Use output instead of outputFileName if you want
      #   outputFileName: ""            # to break up your templates into multiple files, for
      # }]                              # instance, if you have a two page app and want the
                                        # templates for each page to be built separately.
                                        # For each entry, provide an array of folders that
                                        # contain the templates to combine.  folders entries are
                                        # relative to watch.sourceDir and must exist.
                                        # outputFileName works identically to outputFileName
                                        # above, including the alternate config, however, no
                                        # default file name is assumed. An output name must be
                                        # provided for each output entry, and the names
                                        # must be unique.

  """

exports.validate = (config, validators) ->
  errors = []

  if validators.ifExistsIsObject(errors, "template config", config.template)
    validators.ifExistsIsBoolean( errors, "template.writeLibrary", config.template.writeLibrary )

    if config.template.output and config.template.outputFileName
      delete config.template.outputFileName

    if validators.ifExistsIsBoolean(errors, "template.amdWrap", config.template.amdWrap)
      logger.warn "template.amdWrap has been deprecated and support will be removed with a future release. Use template.wrapType."
      if config.template.amdWrap
        config.template.wrapType = "amd"
      else
        config.template.wrapType = "none"

    if validators.ifExistsIsString(errors, "template.wrapType", config.template.wrapType)
      if ["common", "amd", "none"].indexOf(config.template.wrapType) is -1
        errors.push "template.wrapType must be one of: 'common', 'amd', 'none'"

    if config.template.nameTransform?
      if typeof config.template.nameTransform is "string"
        if ["fileName","filePath"].indexOf(config.template.nameTransform) is -1
          errors.push "config.template.nameTransform valid string values are filePath or fileName"
      else if typeof config.template.nameTransform is "function" or config.template.nameTransform instanceof RegExp
        # do nothing
      else
        errors.push "config.template.nameTransform property must be a string, regex or function"

    if config.template.outputFileName?
      config.template.output = [{
        folders:[""]
        outputFileName:config.template.outputFileName
      }]

    if validators.ifExistsIsArrayOfObjects(errors, "template.output", config.template.output)
      fileNames = []
      for outputConfig in config.template.output
        if validators.isArrayOfStringsMustExist errors, "template.templateFiles.folders", outputConfig.folders

          if outputConfig.folders.length is 0
            errors.push "template.templateFiles.folders must have at least one entry"
          else
            newFolders = []
            for folder in outputConfig.folders
              folder = path.join config.watch.sourceDir, folder
              unless fs.existsSync folder
                errors.push "template.templateFiles.folders must exist, folder resolved to [[ #{folder} ]]"
              newFolders.push folder
            outputConfig.folders = newFolders

        if outputConfig.outputFileName?
          fName = outputConfig.outputFileName
          if typeof fName is "string"
            fileNames.push fName
          else if typeof fName is "object" and not Array.isArray(fName)
            for tComp in Object.keys(fName)
              fileNames.push fName[tComp]
          else
            errors.push "template.outputFileName must be an object or a string."
        else
          errors.push "template.output.outputFileName must exist for each entry in array."

      if fileNames.length isnt _.uniq(fileNames).length
        errors.push "template.output.outputFileName names must be unique."

  errors
