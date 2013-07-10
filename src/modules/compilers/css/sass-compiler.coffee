"use strict"

fs = require 'fs'
path = require 'path'
{spawn, exec} = require 'child_process'

_ = require 'lodash'
logger = require 'logmimosa'
nodesass = require 'node-sass'

AbstractCssCompiler = require './css'

module.exports = class SassCompiler extends AbstractCssCompiler

  importRegex: /@import ['"](.*)['"]/g

  @prettyName        = "SASS - http://sass-lang.com/"
  @defaultExtensions = ["scss", "sass"]

  constructor: (config, @extensions) ->
    super()

    unless config.sass.node
      @_doRubySASSChecking()

  compile: (file, config, options, done) =>
    if config.sass.node
      @_compileNode(file, config, options, done)
    else
      @_preCompileRubySASS(file, config, options, done)

  _doRubySASSChecking: ->
    logger.debug "Checking if Compass/SASS is available"
    exec 'compass --version', (error, stdout, stderr) =>
      @hasCompass = not error

    @runSass = 'sass'
    if process.platform is 'win32'
      @runSass = 'sass.bat'

    exec "#{@runSass} --version", (error, stdout, stderr) =>
      @hasSASS = not error

  _preCompileRubySASS: (file, config, options, done) =>
    if @hasCompass? and @hasSASS? and @hasSASS
      return @_compileRuby(file, config, options, done)

    if @hasSASS? and !@hasSASS
      return @_movingToNodeCompile(file, config, options, done)

    compileOnDelay = =>
      if @hasCompass? and @hasSASS?
        if @hasSASS
          @_compileRuby(file, config, options, done)
        else
          return @_movingToNodeCompile(file, config, options, done)
      else
        setTimeout compileOnDelay, 100
    do compileOnDelay

  _movingToNodeCompile: (file, config, options, done) ->
    config.sass.node = true
    logger.error "You have Ruby SASS compilation configured but do not have Ruby SASS installed. Mimosa comes " +
             "bundled with a node SASS compiler and will use that to compile your SASS. If you wish to " +
             "use node to compile your SASS and you do not want to continue getting this warning, set " +
             "sass.node to true in your mimosa-config. If you wish to use Ruby SASS, you must install it. " +
             "SASS is a Ruby gem, information can be found here: http://sass-lang.com/tutorial.html. " +
             "SASS can be installed by executing this command: gem install sass. After installing SASS " +
             "you will need to restart Mimosa."
    @_compileNode(file, config, options, done)

  __isInclude: (fileName) ->
    @includeToBaseHash[fileName]? or path.basename(fileName).charAt(0) is '_'

  _compileNode: (file, config, options, done) =>
    logger.debug "Beginning node compile of SASS file [[ #{file.inputFileName} ]]"

    finished = (error, text) =>
      logger.debug "Finished node compile for file [[ #{file.inputFileName} ]], errors? #{error?}"
      @initBaseFilesToCompile--
      done(error, text)

    nodesass.render
      data: file.inputFileText
      includePaths: [ config.watch.sourceDir, path.dirname(file.inputFileName) ]
      success: (css) =>
        finished null, css
      error: (error) =>
        finished error, ''

  _compileRuby: (file, config, options, done) =>
    text = file.inputFileText
    fileName = file.inputFileName
    logger.debug "Beginning Ruby compile of SASS file [[ #{fileName} ]]"
    result = ''
    error = null
    compilerOptions = ['--stdin', '--load-path', config.watch.sourceDir, '--load-path', path.dirname(fileName), '--no-cache']
    compilerOptions.push '--compass' if @hasCompass
    compilerOptions.push '--scss' if /\.scss$/.test fileName
    sass = spawn @runSass, compilerOptions
    sass.stdin.end text
    sass.stdout.on 'data', (buffer) -> result += buffer.toString()
    sass.stderr.on 'data', (buffer) ->
      error ?= ''
      error += buffer.toString()
    sass.on 'exit', (code) =>
      logger.debug "Finished Ruby SASS compile for file [[ #{fileName} ]], errors? #{error?}"
      @initBaseFilesToCompile--
      done(error, result)

  _determineBaseFiles: =>
    baseFiles = @allFiles.filter (file) =>
      (not @__isInclude(file)) and file.indexOf('compass') < 0
    logger.debug "Base files for SASS are:\n#{baseFiles.join('\n')}"
    baseFiles

  _getImportFilePath: (baseFile, importPath) ->
    path.join path.dirname(baseFile), importPath.replace(/(\w+\.|[\w-]+$)/, '_$1')