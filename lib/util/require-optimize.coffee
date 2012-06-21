requirejs = require 'requirejs'
logger =    require './logger'

config =
  baseUrl: '../appDir/scripts'
  name: 'main'
  out: '../build/main-built.js'

optimize = (destDir) ->

  console.log destDir


  if process.env.NODE_ENV is 'production'
    logger.info "Starting requirejs optimization"


exports.optimize = optimize
