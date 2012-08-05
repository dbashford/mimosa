AbstractSingleFileCompiler = require '../single-file'
logger = require '../../util/logger'
Linter = require '../../util/lint/js'

requireRegister = require '../../util/require/register'

module.exports = class AbstractJavaScriptCompiler extends AbstractSingleFileCompiler
  outExtension: 'js'

  constructor: (config) ->
    super(config, config.compilers.javascript)

    @notifyOnSuccess = config.growl.onSuccess.javascript

    if config.lint.compiled.javascript
      @linter = new Linter(config.lint.rules.javascript)
      @lintVendorJS = config.lint.vendor.javascript

    if config.require.verify.enabled
      @requireRegister = requireRegister
      @requireRegister.setConfig(config)

  removed: (fileName) ->
    super(fileName)
    @requireRegister?.remove(fileName)
    @optimize(fileName)

  afterCompile: (destFileName, source) =>
    if @linter? and (!@_isVendor(destFileName) or @lintVendorJS)
      @linter.lint(destFileName, source)

    @requireRegister?.process(destFileName, source)
    source

  afterWrite: (fileName) ->
    @optimize(fileName)

  postInitialization: ->
    @requireRegister?.startupDone()

  fileNeedsCompiling: (fileName, destinationFile) ->
    # force compiling on startup to build require depedency tree
    if @requireRegister? and !@isInitializationComplete
      true
    else
      super(fileName, destinationFile)



