copy = require './copy'
path = require 'path'

_ = require 'lodash'

fileUtils =  require '../util/file'
logger = require '../util/logger'

class CompilerCentral

  constructor: ->
    @all = fileUtils.glob "#{__dirname}/**/*-compiler.coffee"
    @all.push "#{__dirname}/copy.coffee"

  compilersWithoutCopy: ->
    @all.filter (file) -> file.indexOf('copy.coffee') is -1

  compilersWithoutNone: ->
    @all.filter (file) -> file.indexOf('none-') is -1

  buildCompilerExtensionHash: (config) ->
    allOverriddenExtensions = []
    for base, ext of config.compilers.extensionOverrides
      allOverriddenExtensions.push(ext...)

    logger.debug("All overridden extension [[ #{allOverriddenExtensions.join(', ')}]]")

    config.javascriptExtensions = ['js']
    allCompilers = []
    for file in @compilersWithoutNone()
      base = path.basename(file, ".coffee").replace('-compiler', '')
      Compiler = require(file)
      extensions = if config.compilers.extensionOverrides[base]?
        config.compilers.extensionOverrides[base]
      else
        # check and see if an overridden extension conflicts with an existing one
        _.difference Compiler.defaultExtensions, allOverriddenExtensions

      continue if extensions.length is 0 and base isnt "copy"

      compiler = new Compiler(config, extensions)
      if compiler.javascript
        config.javascriptExtensions.push(compiler.extensions...)
      allCompilers.push compiler

    extHash = {}
    for compiler in allCompilers
      continue unless compiler.extensions?
      for ext in compiler.extensions
        extHash[ext] = compiler

    {compilerExtensionHash:extHash, compilers:allCompilers}

module.exports = new CompilerCentral()