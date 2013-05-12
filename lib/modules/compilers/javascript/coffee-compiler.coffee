"use strict"

path =   require "path"

_ = require "lodash"

coffee = require 'coffee-script'
JSCompiler = require "./javascript"

module.exports = class CoffeeCompiler extends JSCompiler

  @prettyName        = "(*) CoffeeScript - http://coffeescript.org/"
  @defaultExtensions = ["coffee", "litcoffee"]
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
    conf = _.extend {}, @coffeeConfig, sourceFiles:[path.basename(file.inputFileName) + ".src"]
    conf.literate = coffee.helpers.isLiterate(file.inputFileName)

    if conf.sourceMap
      if conf.sourceMapExclude?.indexOf(file.inputFileName) > -1
        conf.sourceMap = false
      else if conf.sourceMapExcludeRegex? and file.inputFileName.match(conf.sourceMapExcludeRegex)
        conf.sourceMap = false

    try
      output = coffee.compile file.inputFileText, conf
      if output.v3SourceMap
        sourceMap = output.v3SourceMap
        output = output.js
    catch err
      error = "#{err}, line #{err.location.first_line}, column #{err.location.first_column}"
    cb error, output, sourceMap