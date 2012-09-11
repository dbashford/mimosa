copy = require './copy'
path = require 'path'

_ = require 'lodash'

fileUtils =  require '../util/file'
logger = require '../util/logger'

class CompilerCentral

  constructor: ->
    files = fileUtils.glob "#{__dirname}/**/*-compiler.coffee"
    files.push "#{__dirname}/copy.coffee"
    @all = files

  compilersWithoutCopy: ->
    @all.filter (file) -> file.indexOf('copy.coffee') is -1

  compilersWithoutNone: ->
    @all.filter (file) -> file.indexOf('none-') is -1

  buildCompilerExtensionHash: (config) ->
    allOverriddenExtensions = []
    for base, ext of config.compilers.extensionOverrides
      allOverriddenExtensions.push(ext...)

    console.log allOverriddenExtensions

    logger.debug("All overridden extension [[ #{allOverriddenExtensions.join(', ')}]]")

    config.javascriptExtensions = ['js']
    hash = {}
    for file in @compilersWithoutNone()
      base = path.basename(file, ".coffee").replace('-compiler', '')
      Compiler = require(file)
      extensions = if config.compilers.extensionOverrides[base]?
        config.compilers.extensionOverrides[base]
      else
        # check and see if an overridden extension conflicts with an existing one
        _.difference Compiler.defaultExtensions, allOverriddenExtensions

      if extensions.length is 0 and base isnt "copy"
        logger.debug "Compiler [[ #{base} ]] is being excluded because its extensions have been overridden"
        continue
      else
        logger.debug "OkExtensions for compiler [[ #{base} ]] are [[ #{extensions.join(', ')} ]]"

      compiler = new Compiler(config, extensions)
      config.javascriptExtensions.push(compiler.extensions...)
      hash[base] = compiler

    extHash = {}
    allCompilers = []
    for base, compiler of hash
      allCompilers.push compiler
      continue unless compiler.extensions?
      for ext in compiler.extensions
        extHash[ext] = compiler

    {compilerExtensionHash:extHash, compilers:allCompilers}

module.exports = new CompilerCentral()