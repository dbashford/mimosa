"use strict"

fs = require 'fs'
path = require 'path'
{spawn, exec} = require 'child_process'

_ = require 'lodash'
logger = require 'logmimosa'

AbstractCssCompiler = require './css'

module.exports = class SassCompiler extends AbstractCssCompiler

  importRegex: /@import ['"](.*)['"]/g

  @prettyName        = "SASS - http://sass-lang.com/"
  @defaultExtensions = ["scss", "sass"]

  @checkIfExists     = (callback) ->
    logger.debug "Checking if SASS is available"
    exec "#{runSass} --version", (error, stdout, stderr) ->
      logger.debug "SASS available error: #{error}"
      logger.debug "SASS available stderr: #{stderr}"
      logger.debug "SASS available stdout: #{stdout}"
      callback(if error then false else true)

  runSass = 'sass'
  if process.platform is 'win32'
    runSass = 'sass.bat'
    logger.debug "win32 detected, changing sass command to #{runSass}"

  constructor: (config, @extensions) ->
    super()

    SassCompiler.checkIfExists (exists) => @hasSASS = exists

    logger.debug "Checking if Compass is available"
    exec 'compass --version', (error, stdout, stderr) =>
      @hasCompass = not error
      logger.debug "Compass available? #{@hasCompass}"

  compile: (file, config, options, done) =>
    if @hasCompass and @hasSASS? and @hasSASS
      return @__compile(file, config, options, done) if @hasCompass? and @hasSASS?

    return @_noSASS() if @hasSASS? and !@hasSASS

    compileOnDelay = =>
      if @hasCompass? and @hasSASS?
        return @_noSASS() unless @hasSASS
        @__compile(file, config, options, done)
      else
        setTimeout compileOnDelay, 100
    do compileOnDelay

  __compile: (file, config, options, done) =>
    text = file.inputFileText
    fileName = file.inputFileName
    logger.debug "Beginning compile of SASS file [[ #{fileName} ]]"
    result = ''
    error = null
    compilerOptions = ['--stdin', '--load-path', config.watch.sourceDir, '--load-path', path.dirname(fileName), '--no-cache']
    compilerOptions.push '--compass' if @hasCompass
    compilerOptions.push '--scss' if /\.scss$/.test fileName
    sass = spawn runSass, compilerOptions
    sass.stdin.end text
    sass.stdout.on 'data', (buffer) -> result += buffer.toString()
    sass.stderr.on 'data', (buffer) ->
      error ?= ''
      error += buffer.toString()
    sass.on 'exit', (code) =>
      logger.debug "Finished SASS compile for file [[ #{fileName} ]], errors? #{error?}"
      @initBaseFilesToCompile--
      done(error, result)

  _isInclude: (fileName) ->
    path.basename(fileName).charAt(0) is '_'

  _determineBaseFiles: =>
    baseFiles = @allFiles.filter (file) =>
      (not @_isInclude(file)) and file.indexOf('compass') < 0
    logger.debug "Base files for SASS are:\n#{baseFiles.join('\n')}"
    baseFiles

  _getImportFilePath: (baseFile, importPath) ->
    path.join path.dirname(baseFile), importPath.replace(/(\w+\.|[\w-]+$)/, '_$1')

  _noSASS: ->
    logger.error "You have SASS code and Mimosa is attempting to compile it, but you don't seem to have SASS installed. " +
                 "SASS is a Ruby gem, information can be found here: http://sass-lang.com/tutorial.html. " +
                 "SASS can be installed by executing this command: gem install sass.  After installing SASS " +
                 "you will need to restart Mimosa."