path = require 'path'

SingleFileCompiler = require './single-file'
CSSLinter =          require '../../util/lint/css'
JSLinter =           require '../../util/lint/js'
requireRegister =    require '../../util/require/register'
logger = require '../../util/logger'
minifier = require '../../util/minify'

module.exports = class CopyCompiler extends SingleFileCompiler

  keepBuffer: true

  constructor: (config) ->
    @extensions = config.copy.extensions
    super(config)

    @notifyOnSuccess = config.growl.onSuccess.copy

    if config.lint.copied.css
      @cssLinter = new CSSLinter(config.lint.rules.css)

    if config.lint.copied.javascript
      @jsLinter = new JSLinter(config.lint.rules.javascript)

    @lintVendorJS = config.lint.vendor.javascript
    @lintVendorCSS = config.lint.vendor.css

    if config.require.verify.enabled or config.optimize
      @requireRegister = requireRegister
      @requireRegister.setConfig(config)

    if config.min
      @minifier = minifier.setExclude(config.minify.exclude)

  removed: (fileName) ->
    super(fileName)
    if @_isJS(fileName)
      logger.debug "Kicking off optimize/register for deleted plain JS file [[ #{fileName} ]]"
      if @requireRegister? then @requireRegister.remove(fileName)
      @optimize(fileName)

  compile: (fileName, text, destinationFile, callback) ->
    callback(null, text, destinationFile)

  findCompiledPath: (fileName) ->
    fileName.replace(@srcDir, @compDir)

  afterCompile: (destFileName, source) =>
    return unless source?.length > 0

    @_lint destFileName, source

    if @_isJSNotVendor(destFileName)
      @requireRegister?.process(destFileName, source.toString())

    if @minifier? and @_isJS(destFileName)
      source = @minifier.minify(destFileName, source.toString())

    source

  _lint: (destFileName, source) ->
    logger.debug "Checking to see if mimosa should lint file [[ #{destFileName} ]]"

    if @_isVendor(destFileName)
      if @cssLinter? and @lintVendorCSS and @_isCSS(destFileName)
        @cssLinter.lint(destFileName, source.toString())
      else if @jsLinter? and @lintVendorJS and @_isJS(destFileName)
        @jsLinter.lint(destFileName, source.toString())
      else
        logger.debug "Will not be linting vendor file [[ #{destFileName} ]]"
    else
      if @cssLinter? and @_isCSS(destFileName)
        @cssLinter.lint(destFileName, source.toString())
      else if @jsLinter? and @_isJS(destFileName)
        @jsLinter.lint(destFileName, source.toString())
      else
        logger.debug "Will not be linting non-vendor file [[ #{destFileName} ]]"

  fileNeedsCompiling: (fileName, destinationFile) ->
    # force compiling on startup to build require dependency tree
    if @requireRegister? and !@isInitializationComplete and @_isJSNotVendor(fileName)
      logger.debug "File [[ #{fileName} ]] needs compiling"
      true
    else
      super(fileName, destinationFile)

  afterWrite: (fileName) ->
    @optimize(fileName) if @_isJS(fileName)

  postInitialization: ->
    @requireRegister?.startupDone()