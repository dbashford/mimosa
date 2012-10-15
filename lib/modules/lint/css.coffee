csslint = require("csslint").CSSLint
_ =       require "lodash"

logger =  require '../../util/logger'

class CSSLinter

  rules:{}

  lifecycleRegistration: (config, register) ->
    extensions = if config.lint.vendor.css
      logger.debug "vendor being linted, so everything needs to pass through linting"
      config.extensions.css
    else if config.lint.copied.css and config.lint.compiled.css
      logger.debug "Linting compiled and copied CSS"
      config.extensions.css
    else if config.lint.copied.css
      logger.debug "Linting copied CSS only"
      ['css']
    else if config.lint.compiled.css
      logger.debug "Linting compiled CSS only"
      _.filter config.extensions.css, (ext) -> ext isnt 'css'
    else
      logger.debug "CSS linting is entirely turned off"
      []

    return if extensions.length is 0

    for rule in csslint.getRules()
      unless config.lint.rules.css[rule.id] is false
        @rules[rule.id] = 1

    # buildExtension for compiled assets, buildFile for copied/vendor
    register ['add','update','buildExtension','buildFile'], 'afterCompile', @_lint, [extensions...]

  _lint: (config, options, next) =>
    return next() unless options.files?.length > 0

    i = 0
    options.files.forEach (file) =>
      if file.outputFileText?.length > 0
        # if is copy, and not a vendor copy, and copy is turned off
        if options.isCopy and not options.isVendor and not config.lint.copied.css
          logger.debug "Not linting copied script [[ #{file.inputFileName} ]]"
        # if is vendor and vendor is not turned off
        else if options.isVendor and not config.lint.vendor.css
          logger.debug "Not linting vendor script [[ #{file.inputFileName} ]]"
        # if is css, but not copied css and compiled css is not turned off
        else if options.isCSS and not options.isCopy and not config.lint.compiled.css
          logger.debug "Not linting compiled script [[ #{file.inputFileName} ]]"
        else
          result = csslint.verify file.outputFileText, @rules
          @_writeMessage(file.inputFileName, message) for message in result.messages
      next() if ++i is options.files.length

  _writeMessage: (fileName, message) ->
    output =  "CSSLint Warning: #{message.message} In #{fileName},"
    output += " on line #{message.line}, column #{message.col}," if message.line?
    output += " from CSSLint rule ID '#{message.rule.id}'."
    logger.warn output

module.exports = new CSSLinter()