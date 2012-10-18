path = require 'path'

_ = require 'lodash'
logger = require 'mimosa-logger'

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
        " You will want to configure a map of template.outfileFileName entries in your config, otherwise you will only get" +
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
        if config.compilers.extensionOverrides[Compiler.base]?
          config.compilers.extensionOverrides[Compiler.base]
        else
          # check and see if an overridden extension conflicts with an existing one
          _.difference Compiler.defaultExtensions, allOverriddenExtensions

      # compiler left without extensions, don't register

      #continue if extensions.length is 0

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

  placeholder: ->
    """
    \t
      # compilers:
        # extensionOverrides:             # A list of extension overrides, format is compilerName:[arrayOfExtensions]
                                          # see http://mimosajs.com/compilers.html for a list of compiler names
          # coffee: ["coff"]              # This is an example override, this is not a default, it must take the form of an array

      # template:
        # outputFileName: "templates"                      # the file all templates are compiled into, is relative to watch.javascriptDir
                                                           # Optionally outputFileName can be provided a hash of file extension
                                                           # to file name in the event you are using multiple templating
                                                           # libraries. The file extension must match one of the default compiler extensions
                                                           # or one of the extensions configure for a compiler in the
                                                           # compilers.extensionOverrides section above. Ex: {hogan:"js/hogans", jade:"js/jades"}
        # helperFiles:["app/template/handlebars-helpers"]  # relevant to handlebars only, the paths from watch.javascriptDir to
                                                           # the files containing handlebars helper/partial registrations,
                                                           # does not need to exist

      ###
      # the extensions of files to simply copy from sourceDir to compiledDir.  vendor js/css, images, etc.
      ###
      # copy:
        # extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml"]
    """

  validate: ->


module.exports = new MimosaCompilerModule()