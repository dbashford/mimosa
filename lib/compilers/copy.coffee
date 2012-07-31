path = require 'path'

SingleFileCompiler = require './single-file'
CSSLinter =             require '../util/lint/css'
JSLinter =             require '../util/lint/js'
RequireVerify = require '../util/require/verify'

module.exports = class CopyCompiler extends SingleFileCompiler

  keepBuffer: true

  constructor: (config) ->
    super(config, config.copy)

    @notifyOnSuccess = config.growl.onSuccess.copy

    if config.lint.copied.css
      @cssLinter = new CSSLinter(config.lint.rules.css)

    if config.lint.copied.javascript
      @jsLinter = new JSLinter(config.lint.rules.javascript)

    @lintVendorJS = config.lint.vendor.javascript
    @lintVendorCSS = config.lint.vendor.css

    if config.require.verify.enabled
      @requireVerifier = new RequireVerify(config)

  removed: (fileName) ->
    super(fileName)
    if @_isJS(fileName) and !@_isVendor(fileName) and @requireVerifier?
      @requireVerifier.remove(fileName)

  compile: (fileName, text, destinationFile, callback) ->
    callback(null, text, destinationFile)

  findCompiledPath: (fileName) ->
    fileName.replace(@srcDir, @compDir)

  afterCompile: (destFileName, source) =>
    return unless source?.length > 0

    @_lint destFileName, source

    if @_isJS(destFileName) and !@_isVendor(destFileName)
      @requireVerifier?.process(destFileName, source.toString())

    source

  _lint: (destFileName, source) ->
    if @_isVendor(destFileName)
      if @cssLinter? and @lintVendorCSS and @_isCSS(destFileName)
        @cssLinter.lint(destFileName, source.toString())
      if @jsLinter? and @lintVendorJS and @_isJS(destFileName)
        @jsLinter.lint(destFileName, source.toString())
    else
      if @cssLinter? and @_isCSS(destFileName)
        @cssLinter.lint(destFileName, source.toString())
      if @jsLinter? and @_isJS(destFileName)
        @jsLinter.lint(destFileName, source.toString())

  _isCSS: (fileName) ->
    path.extname(fileName) is ".css"

  _isJS: (fileName) ->
    path.extname(fileName) is ".js"

  _isVendor: (fileName) ->
    fileName.split(path.sep).indexOf('vendor') > -1

  postInitialization: ->
    @requireVerifier?.startupDone()