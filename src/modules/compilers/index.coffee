"use strict"

_ =      require 'lodash'
logger = require 'logmimosa'

JavaScriptCompiler = require( "./javascript" )
CSSCompiler = require( "./css" )
TemplateCompiler = require "./template/template"

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
  for modName, mod of config.installedModules
    if mod.compilerType
      if logger.isDebug
        logger.debug( "Found compiler [[ #{mod.name} ]], adding to array of compilers");
      compilers.push mod

  for compiler in compilers
    exts = compiler.extensions(config)
    config.extensions[compiler.compilerType].push(exts...)

  for type, extensions of config.extensions
    config.extensions[type] = _.uniq(extensions)

exports.registration = (config, register) ->
  for compiler in compilers
    if logger.isDebug
      logger.debug "Creating compiler " + compiler.name

    compilerInstance = switch compiler.compilerType
      when "copy" then new compiler.compiler(config)
      when "javascript" then new JavaScriptCompiler(config, compiler)
      when "template" then new TemplateCompiler(config, compiler)
      when "css" then new CSSCompiler(config, compiler)
    compilerInstance.name = compiler.name
    compilerInstance.registration(config, register)

    if logger.isDebug
      logger.debug "Done with compiler " + compiler.name

  if config.template
    register ['buildExtension'], 'complete', _testDifferentTemplateLibraries, config.extensions.template

exports.defaults = ->
  template:
    wrapType: "amd"
    commonLibPath: null
    nameTransform:"fileName"
    outputFileName: "javascripts/templates"
    handlebars:
      helpers:["app/template/handlebars-helpers"]
      ember:
        enabled:false
        path:"vendor/ember"
  copy:
    extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd","map","md","mp4"]
    exclude:[]

exports.placeholder = ->
  """
  \t

    # template:                         # overall template object can be set to null if no
                                        # templates being used
      # nameTransform: "fileName"       # means by which Mimosa creates the name for each
                                        # template, options: default "fileName" is name of file,
                                        # "filePath" is path of file after watch.sourceDir
                                        # with the extension dropped, a supplied regex can be
                                        # used to remove any unwanted portions of the filePath,
                                        # and a provided function will be called with the
                                        # filePath as input
      # wrapType: "amd"                 # The type of module wrapping for the output templates
                                        # file. Possible values: "amd", "common", "none".
      # commonLibPath: null             # Valid when wrapType is 'common'. The path to the
                                        # client library. Some libraries do not have clients
                                        # therefore this is not strictly required when choosing
                                        # the common wrapType.
      # outputFileName: "javascripts/templates"  # the file all templates are compiled into,
                                                 # is relative to watch.sourceDir.

      # outputFileName:                 # outputFileName Alternate Config 1
        # hogan:"hogans"                # Optionally outputFileName can be provided an object of
        # jade:"jades"                  # file extension to file name in the event you are using
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

      # handlebars:                     # handlebars specific configuration
        # helpers:["app/template/handlebars-helpers"]  # the paths from watch.javascriptDir to
                                        # the files containing handlebars helper/partial
                                        # registrations
        # ember:                        # Ember.js has its own Handlebars compilation needs,
                                        # use this config block to provide Ember specific
                                        # Handlebars configuration.
          # enabled: false              # Whether or not to use the Ember Handlebars compiler
          # path: "vendor/ember"        # location of the Ember library, this is used as
                                        # as a dependency in the compiled templates.

    ###
    # the extensions of files to copy from sourceDir to compiledDir. vendor js/css, images, etc.
    ###
    # copy:
      # extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd","map","md","mp4"]
      # exclude: []       # List of regexes or strings to match files that should not be copied
                          # but that you might still want processed. String paths can be absolute
                          # or relative to the watch.sourceDir. Regexes are applied to the entire
                          # path.
  """

exports.validate = (config, validators) ->
  errors = []

  path = require 'path'
  fs =   require 'fs'

  if validators.ifExistsIsObject(errors, "template config", config.template)
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

    validTCompilers = ["handlebars", "dust", "hogan", "jade", "underscore", "lodash", "ejs", "html", "emblem", "eco","ractive"]

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
              if validTCompilers.indexOf(tComp) is -1
                errors.push "template.output.outputFileName key [[ #{tComp} ]] does not match list of valid compilers: [[ #{validTCompilers.join(',')}]]"
                break
              else
                fileNames.push fName[tComp]
          else
            errors.push "template.outputFileName must be an object or a string."
        else
          errors.push "template.output.outputFileName must exist for each entry in array."

      if fileNames.length isnt _.uniq(fileNames).length
        errors.push "template.output.outputFileName names must be unique."

    if validators.ifExistsIsObject(errors, "template.handlebars", config.template.handlebars)
      validators.ifExistsIsArrayOfStrings(errors, "handlebars.helpers", config.template.handlebars.helpers)

      if validators.ifExistsIsObject(errors, "template.handlebars.ember", config.template.handlebars.ember)
        validators.ifExistsIsBoolean(errors, "template.handlebars.ember.enabled", config.template.handlebars.ember.enabled)
        validators.ifExistsIsString(errors, "template.handlebars.ember.path", config.template.handlebars.ember.path)

  if validators.ifExistsIsObject(errors, "copy config", config.copy)
    validators.isArrayOfStrings(errors, "copy.extensions", config.copy.extensions)
    validators.ifExistsFileExcludeWithRegexAndString(errors, "copy.exclude", config.copy, config.watch.sourceDir)

  errors