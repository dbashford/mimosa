AbstractSingleFileCompiler = require '../single-file'
jslint = require('jshint').JSHINT
logger = require '../../util/logger'

module.exports = class AbstractJavaScriptCompiler extends AbstractSingleFileCompiler
  outExtension: 'js'

  constructor: (config) -> super(config, config.compilers.javascript)

  afterCompile: (source, destFileName) ->
    @lintIt(source, destFileName) if @config.lint

  lintIt: (source, destFileName) ->
    lintok = jslint(source)

    unless lintok
      for e in jslint.errors
        continue unless e?
        result =
          message: e.reason
          lineNumber: e.line
        @logLint("JavaScript", result, "Error", logger.warn, destFileName)

  logLint: (language, result, type, loggerMethod, fileName) ->
    message = "#{language} Lint #{type}: #{result.message}"
    if result.rule then message += ", lint rule [#{result.rule}]"
    message += ", in file [#{fileName}]"
    if result.lineNumber then message += ", at line number [#{result.lineNumber}]"
    if result.value then message += ", lint setting [#{result.value}]"
    loggerMethod message

  afterWrite: (fileName) -> @optimize()


