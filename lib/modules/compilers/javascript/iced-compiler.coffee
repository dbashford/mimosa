"use strict"

iced = require 'iced-coffee-script'

JSCompiler = require "./javascript"

module.exports = class IcedCompiler extends JSCompiler

  @prettyName        = "Iced CoffeeScript - http://maxtaco.github.com/coffee-script/"
  @defaultExtensions = ["iced"]

  constructor: (config, @extensions) ->
    super()

  compile: (file, cb) ->
    try
      output = iced.compile file.inputFileText, {runtime:'inline'}
    catch err
      error = err
    cb(error, output)