csslint = require("csslint").CSSLint

logger =  require '../../util/logger'

class CSSLinter

  rules:{}

  lifecycleRegistration: (config, register) ->
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
      []

    return if extensions.length is 0

    for rule in csslint.getRules()
      unless config.lint.rules.css[rule.id] is false
        @rules[rule.id] = 1

    register ['startup','add','update'], 'afterCompile', [extensions...], @_lint

  _lint: (config, options, next) =>
    return next() unless options.output? and options.output.length > 0
    name = options.inputName
    if !config.lint.vendor.css and options.isVendor
      logger.debug "Not linting vendor script [[ #{name} ]]"

    result = csslint.verify options.output, @rules
    @_writeMessage(name, message) for message in result.messages
    next()

  _writeMessage: (fileName, message) ->
    output =  "CSSLint Warning: #{message.message} In #{fileName},"
    output += " on line #{message.line}, column #{message.col}," if message.line?
    output += " from CSSLint rule ID '#{message.rule.id}'."
    logger.warn output

module.exports = new CSSLinter()