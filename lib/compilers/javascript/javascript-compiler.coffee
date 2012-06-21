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
        when 'error' then @logLint(language, result, 'Error',   logger.warn)
        when 'warn'  then @logLint(language, result, 'Warning', logger.info)

  postCompile: (source, destFileName) ->
    @lintIt(source, destFileName) if @config.lint

  lintIt: (source, destFileName) ->
    lintok = jslint(source)

    unless lintok
      jslint.errors.forEach (e) =>
        return unless e?
        result =
          message: e.reason
          line: e.line
        @logLint("JavaScript", result, "Error", logger.warn)

  logLint: (language, result, type, loggerMethod) ->
    message = "#{language} Lint #{type}: #{result.message}"
    if result.rule then message += ", lint rule [#{result.rule}]"
    if result.value then message += ", setting [#{result.value}]"
    if result.lineNumber then message += ", at line number [#{result.lineNumber}]"
    loggerMethod message


