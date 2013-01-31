"use strict"

path = require 'path'

_ = require 'lodash'
logger = require 'logmimosa'
wrench = require('wrench')

baseDirRegex = /([^[\/\\\\]*]*)$/

class MimosaCompilerModule

  all: []

  constructor: ->
    @all = wrench.readdirSyncRecursive(__dirname)
      .filter (f) ->
        /-compiler.coffee$/.test(f) or /copy.coffee$/.test(f)
      .map (f) ->
        file = path.join __dirname, f
        comp = require(file)
        comp.base = path.basename(file, ".coffee").replace('-compiler', '')
        if comp.base isnt "copy"
          comp.type = baseDirRegex.exec(path.dirname(file))[0]
        else
          comp.type = "copy"
        comp

  registration: (config, register) ->
    for compiler in @configuredCompilers.compilers
      compiler.registration(config, register) if compiler.registration?

    register ['buildExtension'], 'complete', @_testDifferentTemplateLibraries, [config.extensions.template...]

  _testDifferentTemplateLibraries: (config, options, next) =>
    return next() unless options.files?.length > 0
    return next() unless _.isString(config.template.outputFileName)

    unless @templateLibrariesBeingUsed
      @templateLibrariesBeingUsed = 0

    if ++@templateLibrariesBeingUsed is 2
      logger.error "More than one template library is being used, but multiple template.outputFileName entries not found." +
        " You will want to configure a map of template.outputFileName entries in your config, otherwise you will only get" +
        " template output for one of the libraries."

    next()

  _compilersWithoutCopy: ->
    @all.filter (comp) -> comp.base isnt "copy"

  _compilersWithoutNone: ->
    @all.filter (comp) -> comp.base isnt "none"

  compilersByType: ->
    compilersByType = {css:[], javascript:[], template:[]}
    for comp in @_compilersWithoutCopy()
      compilersByType[comp.type].push(comp)
    compilersByType

  setupCompilers: (config) ->
    allOverriddenExtensions = []
    for base, ext of config.compilers.extensionOverrides
      allOverriddenExtensions.push(ext...)

    logger.debug("All overridden extension [[ #{allOverriddenExtensions.join(', ')}]]")

    allCompilers = []
    extHash = {}
    for Compiler in @_compilersWithoutNone()
      extensions = if Compiler.base is "copy"
        config.copy.extensions
      else
        if config.compilers.extensionOverrides[Compiler.base] is null
          logger.debug "Not registering compiler [[ #{Compiler.base} ]], has been set to null in config."
          false
        else if config.compilers.extensionOverrides[Compiler.base]?
          config.compilers.extensionOverrides[Compiler.base]
        else
          # check and see if an overridden extension conflicts with an existing one
          _.difference Compiler.defaultExtensions, allOverriddenExtensions

      # compiler left without extensions, don't register

      #continue if extensions.length is 0
      if extensions
        compiler = new Compiler(config, extensions)
        allCompilers.push compiler
        extHash[ext] = compiler for ext in compiler.extensions
        config.extensions[Compiler.type].push(extensions...)

    for type, extensions of config.extensions
      config.extensions[type] = _.uniq(extensions)

    logger.debug("Compiler/Extension hash \n #{extHash}")

    @configuredCompilers = {compilerExtensionHash:extHash, compilers:allCompilers}

    @

  getCompilers: ->
    @configuredCompilers

  defaults: ->
    compilers:
      extensionOverrides: {}
    template:
      outputFileName: "templates"
      helperFiles:["app/template/handlebars-helpers"]
    copy:
      extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd"]
    typescript:
      module:null

  placeholder: ->
    """
    \t

      # compilers:
        # extensionOverrides:       # A list of extension overrides, format is:
                                    # [compilerName]:[arrayOfExtensions], see
                                    # http://mimosajs.com/compilers.html for list of compiler names
          # coffee: ["coff"]        # This is an example override, this is not a default, must be
                                    # array of strings

      # template:
        # outputFileName: "templates"     # the file all templates are compiled into, is relative
                                          # to watch.javascriptDir.

        # outputFileName:                 # outputFileName Alternate Config 1
          # hogan:"javascripts/hogans"    # Optionally outputFileName can be provided an object of
          # jade:"javascripts/jades"      # file extension to file name in the event you are using
                                          # multiple templating libraries. The file extension must
                                          # match one of the default compiler extensions or one of
                                          # the extensions configured for a compiler in the
                                          # compilers.extensionOverrides section above.

        # outputFiles: [{                 # outputFileName Alternate Config 2
        #   folder:""                     # Use outputFiles instead of outputFileName if you want
        #   outputFileName: ""            # to break up your templates into multiple files, for
        # }]                              # instance, if you have a two page app and want the
                                          # templates for each page to be built separately.
                                          # For each entry, provide a folder.  folder is relative
                                          # to watch.javascriptDir and must exist.  outputFileName
                                          # works identically to outputFileName above, including
                                          # the alternate config, however, no default file name is
                                          # assumed. An output name must be provided for each
                                          # outputFiles entry, and the names must be unique.

        # helperFiles:["app/template/handlebars-helpers"]  # relevant to handlebars only, the paths
                                          # from watch.javascriptDir to the files containing
                                          # handlebars helper/partial registrations

      ###
      # the extensions of files to copy from sourceDir to compiledDir. vendor js/css, images, etc.
      ###
      # copy:
        # extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd"]
    """

  validate: (config, validators) ->
    errors = []

    if validators.ifExistsIsObject(errors, "compilers config", config.compilers)
      if validators.ifExistsIsObject(errors, "compilers.extensionOverrides", config.compilers.extensionOverrides)
        for configComp in Object.keys(config.compilers.extensionOverrides)
          found = false
          for comp in @all
            if configComp is comp.base
              found = true
              break
          unless found
            errors.push "compilers.extensionOverrides, [[ #{configComp} ]] is invalid compiler."

          if Array.isArray(config.compilers.extensionOverrides[configComp])
            for ext in config.compilers.extensionOverrides[configComp]
              unless typeof ext is "string"
                errors.push "compilers.extensionOverrides.#{configComp} must be an array of strings."
          else
            unless config.compilers.extensionOverrides[configComp] is null
              errors.push "compilers.extensionOverrides must be an array."

    if validators.ifExistsIsObject(errors, "template config", config.template)
      if config.template.outputFiles and config.template.outputFileName
        delete config.template.outputFileName

      validTCompilers = ["handlebars", "dust", "hogan", "jade", "underscore", "lodash", "ejs", "html"]

      if config.template.outputFileName?
        config.template.outputFiles = [{
          folder:""
          outputFileName:config.template.outputFileName
        }]

      if validators.ifExistsIsArrayOfObjects(errors, "template.outputFiles", config.template.outputFiles)
        fileNames = []

        for outputFilesConfig in config.template.outputFiles
          if validators.stringMustExist errors, "template.templateFiles.folder", outputFilesConfig.folder
            outputFilesConfig.folder = path.join config.watch.sourceDir, config.watch.javascriptDir, outputFilesConfig.folder

          if outputFilesConfig.outputFileName?
            fName = outputFilesConfig.outputFileName
            if typeof fName is "string"
              fileNames.push fName
            else if typeof fName is "object" and not Array.isArray(fName)
              for tComp in Object.keys(fName)
                if validTCompilers.indexOf(tComp) is -1
                  errors.push "template.outputFiles.outputFileName key [[ #{tComp} ]] does not match list of valid compilers: [[ #{validTCompilers.join(',')}]]"
                  break
                else
                  fileNames.push fName[tComp]
            else
              errors.push "template.outputFileName must be an object or a string."
          else
            errors.push "template.outputFiles.outputFileName must exist for each entry in array."

        if fileNames.length isnt _.uniq(fileNames).length
          errors.push "template.outputFiles.outputFileName names must be unique."

      validators.ifExistsIsArrayOfStrings(errors, "template.helperFiles", config.template.helperFiles)


    if validators.ifExistsIsObject(errors, "copy config", config.copy)
      validators.isArrayOfStrings(errors, "copy.extensions", config.copy.extensions)

    errors

module.exports = new MimosaCompilerModule()