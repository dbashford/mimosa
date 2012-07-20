csslint = require("csslint").CSSLint

logger =  require '../logger'

module.exports = class CSSLinter

  rules:{}

  constructor: (rules) ->
    for rule in csslint.getRules()
      unless rules[rule.id] is false
        @rules[rule.id] = 1

  lint: (source, destFileName) ->
    result = csslint.verify source, @rules
    @writeMessage(message, destFileName) for message in result.messages

  writeMessage: (message, destFileName) ->
    output =  "CSSLint Warning: #{message.message} In #{destFileName},"
    output += " on line #{message.line}, column #{message.col}," if message.line?
    output += " from CSSLint rule ID '#{message.rule.id}'."
    logger.warn output