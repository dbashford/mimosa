csslint = require("csslint").CSSLint

SingleFileCompiler = require '../single-file'
logger =             require '../../util/logger'

module.exports = class AbstractCSSCompiler extends SingleFileCompiler

  outExtension: 'css'

  constructor: (config) ->
    super(config, config.compilers.css)

    return if @config.lint.enabled is false

    @rules = {}
    for rule in csslint.getRules()
      @rules[rule.id] = 1 unless config.compilers.css.lint.rules[rule.id] is false

  afterCompile: (source, destFileName) =>
    return if @config.lint.enabled is false
    result = csslint.verify source, @rules
    @writeMessage(message, destFileName) for message in result.messages

  writeMessage: (message, destFileName) ->
    output = "CSSLint Warning: #{message.message} In #{destFileName},"
    output += " on line #{message.line}, column #{message.col}," if message.line?
    output += " from CSSLint rule ID '#{message.rule.id}'."
    logger.warn output
