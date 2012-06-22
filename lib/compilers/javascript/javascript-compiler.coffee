AbstractSingleFileCompiler = require '../single-file-compiler'
coffeelint = require 'coffeelint'
jslint = require('jshint').JSHINT
logger = require '../../util/logger'

module.exports = class AbstractJavaScriptCompiler extends AbstractSingleFileCompiler
  outExtension: 'js'

  constructor: (config) -> super(config, config.compilers.javascript)

  metaLintIt: (source, config, fileName, language) ->
    lintResults = coffeelint.lint(source, config)
    for result in lintResults
      switch result.level
        when 'error' then @logLint(language, result, 'Error',   logger.warn, fileName)
        when 'warn'  then @logLint(language, result, 'Warning', logger.info, fileName)

  postCompile: (source, destFileName) ->
    @lintIt(source, destFileName) if @config.lint

  lintIt: (source, destFileName) ->
    lintok = jslint(source)

    unless lintok
      jslint.errors.forEach (e) =>
        return unless e?
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

  postWrite: (fileName) -> @optimize()


