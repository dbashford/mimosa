color = require('ansi-color').set
growl = require 'growl'
require 'date-utils'

class Logger
  constructor: ->
    @isDebug = Boolean process.env.DEBUG

  log: (logLevel, message, color, growlTitle = null) ->
    if growlTitle?
      imageUrl = switch logLevel
        when 'success' then "#{__dirname}/images/success.png"
        when 'error' then "#{__dirname}/images/failed.png"
        when 'fatal' then "#{__dirname}/images/failed.png"
        else ''

      growl message, {title: growlTitle, image: imageUrl}

    message = @wrap(message, color)

    if logLevel is 'error' or logLevel is 'warn' or logLevel is 'fatal'
      console.error message
    else
      console.log message

  wrap: (message, textColor) -> color("#{new Date().toFormat('HH24:MI:SS')} - #{message}", textColor)

  error:   (message) =>          @log 'error', message, 'red+bold', 'Error'
  warn:    (message) =>          @log 'warn',  message, 'yellow'
  info:    (message) =>          @log 'info',  message, 'black'
  debug:   (message) =>          @log 'debug', message, 'purple' if @isDebug
  fatal:   (message) =>          @log 'fatal', "FATAL: #{message}", 'red+bold+underline', "Fatal Error"
  success: (message, growlIt) =>
    title = if growlIt? then 'Success' else null
    @log 'success', message, 'green+bold', title

module.exports = new Logger
