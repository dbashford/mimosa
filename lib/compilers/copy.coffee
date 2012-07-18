path = require 'path'

SingleFileCompiler = require './single-file'
CSSLinter =             require '../util/lint-css'
JSLinter =             require '../util/lint-js'

module.exports = class CopyCompiler extends SingleFileCompiler

  keepBuffer: true

  constructor: (config) ->
    super(config, config.copy)

    @notifyOnSuccess = config.growl.onSuccess.copy

    if config.lint.copied.css
      @cssLinter = new CSSLinter(config.lint.rules.css)

    if config.lint.copied.javascript
      @jsLinter = new JSLinter()
      @jsRules = config.lint.rules.javascript

    @lintVendorJS = config.lint.vendor.javascript
    @lintVendorCSS = config.lint.vendor.css

  compile: (text, fileName, destinationFile, callback) ->
    callback(null, text, destinationFile)

  findCompiledPath: (fileName) ->
    fileName.replace(@srcDir, @compDir)

  afterCompile: (source, destFileName) =>
    return unless source?.length > 0

    if @_isVendor(destFileName)
      if @cssLinter? and @lintVendorCSS and @_isCSS(destFileName)
        @cssLinter.lint(source.toString(), destFileName)
      if @jsLinter? and @lintVendorJS and @_isJS(destFileName)
        @jsLinter.lintJs(source.toString(), destFileName, @jsRules)
    else
      if @cssLinter? and @_isCSS(destFileName)
        @cssLinter.lint(source.toString(), destFileName)
      if @jsLinter? and @_isJS(destFileName)
        @jsLinter.lintJs(source.toString(), destFileName, @jsRules)

  _isCSS: (fileName) ->
    path.extname(fileName) is ".css"

  _isJS: (fileName) ->
    path.extname(fileName) is ".js"

  _isVendor: (fileName) ->
    fileName.split(path.sep).indexOf('vendor') > -1