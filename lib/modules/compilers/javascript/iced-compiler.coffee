"use strict"

iced = require 'iced-coffee-script'
_ = require 'lodash'

JSCompiler = require "./javascript"

module.exports = class IcedCompiler extends JSCompiler

  @prettyName        = "Iced CoffeeScript - http://maxtaco.github.com/coffee-script/"
  @defaultExtensions = ["iced"]

  constructor: (config, @extensions) ->
    @icedConfig = config.iced
    super()

  compile: (file, cb) ->
    try
      conf = _.extend {}, {runtime:'inline'}, @icedConfig
      output = iced.compile file.inputFileText, conf
    catch err
      error = err
    cb(error, output)