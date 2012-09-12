AbstractSingleFileCompiler = require '../single-file'
logger = require '../../util/logger'
Linter = require '../../util/lint/js'

requireRegister = require '../../util/require/register'
minifier = require '../../util/minify'

module.exports = class AbstractJavaScriptCompiler extends AbstractSingleFileCompiler
  outExtension: 'js'
  javascript:true

  constructor: (config) ->
    super(config)

    @notifyOnSuccess = config.growl.onSuccess.javascript

    if config.lint.compiled.javascript
      @linter = new Linter(config.lint.rules.javascript)
      @lintVendorJS = config.lint.vendor.javascript

    if config.require.verify.enabled or config.optimize
      @requireRegister = requireRegister
      @requireRegister.setConfig(config)

    if @fullConfig.min
      @minifier = minifier.setExclude(@fullConfig.minify.exclude)

  removed: (fileName) ->
    super(fileName)
    @requireRegister?.remove(fileName)
    @optimize(fileName)

  afterCompile: (destFileName, source) =>
    if @linter? and (!@_isVendor(destFileName) or @lintVendorJS)
      logger.debug "Linting [[ #{destFileName} ]]}"
      @linter.lint(destFileName, source)

    if @minifier?
      source =@minifier.minify(destFileName, source)

    @requireRegister?.process(destFileName, source)

    source

  afterWrite: (fileName) ->
    @optimize(fileName)

  postInitialization: ->
    @requireRegister?.startupDone()

  fileNeedsCompiling: (fileName, destinationFile) ->
    # force compiling on startup to build require dependency tree
    if @requireRegister? and !@isInitializationComplete
      logger.debug "Forcing startup compiling for [[ #{fileName} ]] to build require dependency tree"
      true
    else
      super(fileName, destinationFile)