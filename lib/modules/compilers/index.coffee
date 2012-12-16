"use strict"

path = require 'path'

_ = require 'lodash'
logger = require 'logmimosa'

fileUtils =  require '../../util/file'

baseDirRegex = /([^[\/\\\\]*]*)$/

class MimosaCompilerModule

  all: []

  constructor: ->
    fileNames = fileUtils.glob "#{__dirname}/**/*-compiler.coffee"
    fileNames.push "#{__dirname}/copy.coffee"
    for file in fileNames
      Compiler = require(file)
      Compiler.base = path.basename(file, ".coffee").replace('-compiler', '')
      if Compiler.base isnt "copy"
        Compiler.type = baseDirRegex.exec(path.dirname(file))[0]
      else
        Compiler.type = "copy"
      @all.push(Compiler)

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
      extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml"]
    typescript:
      module:"amd"

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
                                          # to watch.javascriptDir. Optionally outputFileName can
                                          # be provided a hash of file extension to file name in
                                          # the event you are using multiple templating libraries.
                                          # The file extension must match one of the default
                                          # compiler extensions or one of the extensions configured
                                          # for a compiler in the compilers.extensionOverrides
                                          # section above. Ex: {hogan:"js/hogans", jade:"js/jades"}
        # helperFiles:["app/template/handlebars-helpers"]  # relevant to handlebars only, the paths
                                          # from watch.javascriptDir to the files containing
                                          # handlebars helper/partial registrations

      ###
      # the extensions of files to copy from sourceDir to compiledDir. vendor js/css, images, etc.
      ###
      # copy:
        # extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml"]
    """

  validate: (config) ->
    errors = []
    if config.compilers?
      if typeof config.compilers is "object" and not Array.isArray(config.compilers)
        if config.compilers.extensionOverrides?
          if typeof config.compilers.extensionOverrides is "object" and not Array.isArray(config.compilers.extensionOverrides)
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
          else
            errors.push "compilers.extensionOverrides must be an object."
      else
        errors.push "compilers config must be an object."

    if config.template?
      if typeof config.template is "object" and not Array.isArray(config.template)
        if config.template.outputFileName?
          fName = config.template.outputFileName
          unless ((typeof fName is "object") or (typeof fName is "string")) and not Array.isArray(fName)
            errors.push "template.outputFileName must be an object or a string."
        if config.template.helperFiles?
          if Array.isArray(config.template.helperFiles)
            for hFile in config.template.helperFiles
              unless typeof hFile is 'string'
                errors.push "template.helperFiles config must be an array of strings."
                break
          else
            errors.push "template.helperFiles config must be an array."
      else
        errors.push "template config must be an object."

    if config.copy?
      if typeof config.copy is "object" and not Array.isArray(config.copy)
        if Array.isArray(config.copy.extensions)
          for hFile in config.copy.extensions
            unless typeof hFile is 'string'
              errors.push "copy.extensions must be an array of strings."
              break
        else
          errors.push "copy.extensions must be an array."
      else
        errors.push "copy config must be an object."

    errors

module.exports = new MimosaCompilerModule()