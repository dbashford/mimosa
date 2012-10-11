path = require 'path'

_ = require 'lodash'

fileUtils =  require '../../util/file'
logger = require '../../util/logger'

baseDirRegex = /([^[\/\\\\]*]*)$/

class CompilerCentral

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

  lifecycleRegistration: (config, register) ->
    for compiler in @configuredCompilers.compilers
      compiler.lifecycleRegistration(config, register) if compiler.lifecycleRegistration?

    register ['buildDone'], 'init', @_testDifferentTemplateLibraries

  _testDifferentTemplateLibraries: (config, options, next) =>
    compilers = @_templateCompilers()

    templateLibraryWithFiles = 0
    for compiler in compilers
      continue unless compiler.template
      files = wrench.readdirSyncRecursive(config.watch.sourceDir).filter (f) =>
        ext = path.extname(f)
        ext.length > 1 and compiler.extensions.indexOf(ext.substring(1)) >= 0
      templateLibraryWithFiles++ if files.length > 0

    if templateLibraryWithFiles > 1 and _.isString(@config.template.outputFileName)
      logger.error "More than one template library is being used, but multiple template.outputFileName entries not found." +
        " You will want to configure a map of outfileFileName entries in your config, otherwise you will only get" +
        " template output for one of the libraries."

    next()

  _compilersWithoutCopy: ->
    @all.filter (comp) -> comp.base isnt "copy"

  _compilersWithoutNone: ->
    @all.filter (comp) -> comp.base isnt "none"

  _templateCompilers: ->
    @all.filter (comp) -> comp.type is "template"

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

module.exports = new CompilerCentral()