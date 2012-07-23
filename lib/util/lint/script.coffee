logger =  require '../logger'

module.exports = class AbstractScriptLinter

  logLint: (fileName, language, result, type, loggerMethod) ->
    message = "#{language} Lint #{type}: #{result.message}"
    if result.rule then message += ", lint rule [#{result.rule}]"
    message += ", in file [#{fileName}]"
    if result.lineNumber then message += ", at line number [#{result.lineNumber}]"
    if result.value
      val = result.value
      if result.rule and @options[result.rule]?.value?
        val = @options[result.rule].value
      message += ", lint setting [#{val}]"
    loggerMethod message