fs = require 'fs'
path = require 'path'
{spawn, exec} = require 'child_process'

_ = require 'lodash'

AbstractCssCompiler = require './css'
logger = require '../../util/logger'

module.exports = class SassCompiler extends AbstractCssCompiler

  importRegex: /@import ['"](.*)['"]/g

  @prettyName        = -> "SASS - http://sass-lang.com/"
  @defaultExtensions = -> ["scss", "sass"]
  @checkIfExists     = (callback) ->
    exec 'sass --version', (error, stdout, stderr) ->
      callback(if error then false else true)

  constructor: (config) ->
    super(config)
    SassCompiler.checkIfExists (exists) ->
      unless exists
        logger.error "SASS is configured as the CSS compiler, but you don't seem to have SASS installed"
        logger.error "SASS is a Ruby gem, information can be found here: http://sass-lang.com/tutorial.html"
        logger.error "SASS can be installed by executing this command: gem install sass"

    exec 'compass --version', (error, stdout, stderr) =>
      @hasCompass = not error

  compile: (text, fileName, destinationFile, callback) =>
    return @_compile(text, fileName, destinationFile, callback) if @hasCompass?

    compileOnDelay = =>
      if @hasCompass?
        @_compile(text, fileName, destinationFile, callback)
      else
        setTimeout compileOnDelay, 100
    do compileOnDelay

  _compile: (text, fileName, destinationFile, callback) =>
    result = ''
    error = null
    options = ['--stdin', '--load-path', @srcDir, '--load-path', path.dirname(fileName), '--no-cache']
    options.push '--compass' if @hasCompass
    options.push '--scss' if /\.scss$/.test fileName
    sass = spawn 'sass', options
    sass.stdin.end text
    sass.stdout.on 'data', (buffer) -> result += buffer.toString()
    sass.stderr.on 'data', (buffer) ->
      error ?= ''
      error += buffer.toString()
    sass.on 'exit', (code) =>
      callback(error, result, destinationFile)

      unless @startupFinished
        @_startupFinished() if --@initBaseFilesToCompile is 0

  _isInclude: (fileName) ->
    path.basename(fileName).substring(0,1) is '_'

  _determineBaseFiles: =>
    _.filter @allFiles, (file) =>
      (not @_isInclude(file)) and file.indexOf('compass') < 0

  _getImportFilePath: (baseFile, importPath) ->
    str = importPath.replace(/(\w+\.|[\w-]+$)/, '_$1')
    console.log importPath, str
    str