csslint = require("csslint").CSSLint

logger =  require '../logger'

module.exports = class CSSLinter

  rules:{}

  constructor: (rules) ->
    for rule in csslint.getRules()
      unless rules[rule.id] is false
        @rules[rule.id] = 1

  lint: (fileName, source) ->
    result = csslint.verify source, @rules
    @writeMessage(fileName, message) for message in result.messages

  writeMessage: (fileName, message) ->
    output =  "CSSLint Warning: #{message.message} In #{fileName},"
    output += " on line #{message.line}, column #{message.col}," if message.line?
    output += " from CSSLint rule ID '#{message.rule.id}'."
    logger.warn output