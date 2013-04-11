"use strict"

path =   require "path"

_ = require "lodash"

coffee = require 'coffee-script'
JSCompiler = require "./javascript"

module.exports = class CoffeeCompiler extends JSCompiler

  @prettyName        = "(*) CoffeeScript - http://coffeescript.org/"
  @defaultExtensions = ["coffee"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    @coffeeConfig = config.coffeescript
    super()

  registration: (config, register) ->
    super config, register

    # register remove only if sourcemap as remove is watch workflow
    if @coffeeConfig.sourceMap
      register ['remove'], 'delete', @_cleanUpSourceMaps, @extensions

    # register clean regardless to ensure any existing source maps are removed during build/clean
    register ['cleanFile'], 'delete', @_cleanUpSourceMaps, @extensions

  compile: (file, cb) ->
    try
      conf = _.extend {}, @coffeeConfig, sourceFiles:[path.basename(file.inputFileName) + ".src"]
      output = coffee.compile file.inputFileText, conf
      if output.v3SourceMap
        sourceMap = output.v3SourceMap
        output = output.js
    catch err
      error = "#{err}, line #{err.location.first_line}, column #{err.location.first_column}"
    cb error, output, sourceMap