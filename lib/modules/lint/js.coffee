jslint = require('jshint').JSHINT
_ =      require 'lodash'

logger =  require '../../util/logger'

class JSLinter

  lifecycleRegistration: (config, register) ->
    extensions = if config.lint.vendor.javascript
      logger.debug "vendor being linted, so everything needs to pass through linting"
      config.extensions.javascript
    else if config.lint.copied.javascript and config.lint.compiled.javascript
      logger.debug "Linting compiled/copied JavaScript only"
      config.extensions.javascript
    else if config.lint.copied.javascript
      logger.debug "Linting copied JavaScript only"
      ['js']
    else if config.lint.compiled.javascript
      logger.debug "Linting compiled JavaScript only"
      _.filter config.extensions.javascript, (ext) -> ext isnt 'js'
    else
      logger.debug "JavaScript linting is entirely turned off"
      []

    return if extensions.length is 0

    @options = config.lint.rules.javascript

    register ['buildFile','add','update'], 'afterCompile', @_lint, [extensions...]

  _lint: (config, options, next) =>
    return next() unless options.files?.length > 0

    i = 0
    options.files.forEach (file) =>
      if file.outputFileText?.length > 0
        if options.isCopy and not options.isVendor and not config.lint.copied.javascript
          logger.debug "Not linting copied script [[ #{file.inputFileName} ]]"
        else if options.isVendor and not config.lint.vendor.javascript
          logger.debug "Not linting vendor script [[ #{file.inputFileName} ]]"
        else if options.isJavascript and not options.isCopy and not config.lint.compiled.javascript
          logger.debug "Not linting compiled script [[ #{file.inputFileName} ]]"
        else
          lintok = jslint file.outputFileText, @options
          unless lintok
            jslint.errors.forEach (e) =>
              if e?
                @log file.inputFileName, e.reason, e.line
      next() if ++i is options.files.length

  log: (fileName, message, lineNumber) ->
    message = "JavaScript Lint Error: #{message}, in file [[ #{fileName} ]]"
    message += ", at line number [[ #{lineNumber} ]]" if lineNumber
    logger.warn message

module.exports = new JSLinter()