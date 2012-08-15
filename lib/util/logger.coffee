color = require('ansi-color').set
growl = require 'growl'
require 'date-utils'

class Logger

  isDebug: false

  log: (logLevel, message, color, growlTitle = null) ->
    if growlTitle?
      imageUrl = switch logLevel
        when 'success' then "#{__dirname}/assets/success.png"
        when 'error' then "#{__dirname}/assets/failed.png"
        when 'fatal' then "#{__dirname}/assets/failed.png"
        else ''

      growl message, {title: growlTitle, image: imageUrl}

    message = @wrap(message, color)

    if logLevel is 'error' or logLevel is 'warn' or logLevel is 'fatal'
      console.error message
    else
      console.log message

  setDebug: (@isDebug = true) ->

  wrap: (message, textColor) -> color("#{new Date().toFormat('HH24:MI:SS')} - #{message}", textColor)

  blue:  (message) => console.log color(message, "blue+bold")
  green: (message) => console.log color(message, "green+bold")
  red:   (message) => console.log color(message, "red+bold")

  error: (message) => @log 'error', message, 'red+bold', 'Error'
  warn:  (message) => @log 'warn',  message, 'yellow'
  info:  (message) => @log 'info',  message, 'black'
  fatal: (message) => @log 'fatal', "FATAL: #{message}", 'red+bold+underline', "Fatal Error"
  debug: (message) =>
    if @isDebug
      @log 'debug', "#{message}", 'blue'
  success: (message, growlIt) =>
    title = if growlIt then 'Success' else null
    @log 'success', message, 'green+bold', title

module.exports = new Logger
