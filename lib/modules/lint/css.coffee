csslint = require("csslint").CSSLint

logger =  require '../logger'

module.exports = class CSSLinter

  rules:{}

  lifecycleRegistration: (config) ->
    extensions = if config.lint.copied.css and config.lint.compiled.css
      logger.debug "Linting compiled/copied CSS only"
      config.extensions.css
    else if config.lint.copied.css
      logger.debug "Linting copied CSS only"
      ['css']
    else if config.lint.compiled.css
      logger.debug "Linting compiled CSS only"
      _.filter config.extensions.css, (ext) -> ext isnt 'css'
    else
      logger.debug "CSS linting is entirely turned off"
      return []

    for rule in csslint.getRules()
      unless config.lint.rules.css[rule.id] is false
        @rules[rule.id] = 1

    [{types:['add','update','startup']
      step:'afterCompile'
      callback: @_lint
      extensions:[extensions]}]

  lint: (config, options, next) ->
    name = options.inputName
    if !config.lint.vendor.css and fileUtils._isVendor(options.destinationFile)
      logger.debug "Not linting vendor script [[ #{name} ]]"

    result = csslint.verify options.fileContent, @rules
    @writeMessage(name, message) for message in result.messages
    next()

  writeMessage: (fileName, message) ->
    output =  "CSSLint Warning: #{message.message} In #{fileName},"
    output += " on line #{message.line}, column #{message.col}," if message.line?
    output += " from CSSLint rule ID '#{message.rule.id}'."
    logger.warn output