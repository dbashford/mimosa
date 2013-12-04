"use strict"

fs = require 'fs'
path = require 'path'
{spawn, exec} = require 'child_process'

_ = require 'lodash'
logger = require 'logmimosa'

AbstractCssCompiler = require './css'

module.exports = class SassCompiler extends AbstractCssCompiler
  libName: 'node-sass'
  importRegex: /@import ['"](.*)['"]/g

  @defaultExtensions = ["scss", "sass"]

  constructor: (config, @extensions) ->
    super()

    unless config.compilers.libs.sass
      @_doRubySASSChecking()

  compile: (file, config, options, done) =>
    if config.compilers.libs.sass
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
      msg = """
          You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or
          provide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.
        """
      return done(msg, '')

    compileOnDelay = =>
      if @hasCompass? and @hasSASS?
        if @hasSASS
          @_compileRuby(file, config, options, done)
        else
          msg = """
              You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or
              provide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.
            """
          return done(msg, '')
      else
        setTimeout compileOnDelay, 100
    do compileOnDelay

  __isInclude: (fileName) ->
    @includeToBaseHash[fileName]? or path.basename(fileName).charAt(0) is '_'

  _compileNode: (file, config, options, done) =>
    logger.debug "Beginning node compile of SASS file [[ #{file.inputFileName} ]]"

    finished = (error, text) =>
      logger.debug "Finished node compile for file [[ #{file.inputFileName} ]], errors? #{error?}"
      done error, text

    @compilerLib.render
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
      done(error, result)

  _determineBaseFiles: (allFiles) =>
    baseFiles = allFiles.filter (file) =>
      (not @__isInclude(file)) and file.indexOf('compass') < 0
    if logger.isDebug
      logger.debug "Base files for SASS are:\n#{baseFiles.join('\n')}"
    baseFiles

  _getImportFilePath: (baseFile, importPath) ->
    path.join path.dirname(baseFile), importPath.replace(/(\w+\.|[\w-]+$)/, '_$1')