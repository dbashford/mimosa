"use strict"

fs = require 'fs'
path = require 'path'
{spawn, exec} = require 'child_process'

_ = require 'lodash'
logger = require 'logmimosa'

_importRegex = /@import ['"](.*)['"]/g
runSass = 'sass'
hasSASS = undefined
hasCompass = undefined
_compilerLib = null

__doRubySASSChecking = ->
  logger.debug "Checking if Compass/SASS is available"
  exec 'compass --version', (error, stdout, stderr) ->
    hasCompass = not error

  if process.platform is 'win32'
    runSass = 'sass.bat'

  exec "#{runSass} --version", (error, stdout, stderr) ->
    hasSASS = not error

__compileRuby = (file, config, options, done) ->
  text = file.inputFileText
  fileName = file.inputFileName
  logger.debug "Beginning Ruby compile of SASS file [[ #{fileName} ]]"
  result = ''
  error = null
  compilerOptions = ['--stdin', '--load-path', config.watch.sourceDir, '--load-path', path.dirname(fileName), '--no-cache']
  compilerOptions.push '--compass' if hasCompass
  compilerOptions.push '--scss' if /\.scss$/.test fileName
  sass = spawn runSass, compilerOptions
  sass.stdin.end text
  sass.stdout.on 'data', (buffer) -> result += buffer.toString()
  sass.stderr.on 'data', (buffer) ->
    error ?= ''
    error += buffer.toString()
  sass.on 'exit', (code) ->
    logger.debug "Finished Ruby SASS compile for file [[ #{fileName} ]], errors? #{error?}"
    done(error, result)

__preCompileRubySASS = (file, config, options, done) ->
  if hasCompass and hasSASS
    return __compileRuby(file, config, options, done)

  if hasSASS
    msg = """
        You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or
        provide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.
      """
    return done(msg, '')

  compileOnDelay = ->
    if hasCompass? and hasSASS?
      if hasSASS
        __compileRuby(file, config, options, done)
      else
        msg = """
            You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or
            provide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.
          """
        return done(msg, '')
    else
      setTimeout compileOnDelay, 100
  do compileOnDelay

__compileNode = (file, config, options, done) ->
  logger.debug "Beginning node compile of SASS file [[ #{file.inputFileName} ]]"

  finished = (error, text) ->
    logger.debug "Finished node compile for file [[ #{file.inputFileName} ]], errors? #{error?}"
    done error, text

  _compilerLib.render
    data: file.inputFileText
    includePaths: [ config.watch.sourceDir, path.dirname(file.inputFileName) ]
    success: (css) ->
      finished null, css
    error: (error) ->
      finished error, ''

_init = (config) ->
  unless config.compilers.libs.sass
    __doRubySASSChecking()

_compile = (file, config, options, done) ->
  if config.compilers.libs.sass
    __compileNode(file, config, options, done)
  else
    __preCompileRubySASS(file, config, options, done)

_isInclude = (fileName, includeToBaseHash) ->
  includeToBaseHash[fileName]? or path.basename(fileName).charAt(0) is '_'

_getImportFilePath = (baseFile, importPath) ->
  path.join path.dirname(baseFile), importPath.replace(/(\w+\.|[\w-]+$)/, '_$1')

_determineBaseFiles = (allFiles) ->
  baseFiles = allFiles.filter (file) ->
    (not _isInclude(file)) and file.indexOf('compass') < 0
  if logger.isDebug
    logger.debug "Base files for SASS are:\n#{baseFiles.join('\n')}"
  baseFiles

module.exports =
  base: "sass"
  type: "css"
  defaultExtensions: ["scss", "sass"]
  libName: 'node-sass'
  importRegex: _importRegex
  init: _init
  compile: _compile
  isInclude: _isInclude
  getImportFilePath: _getImportFilePath
  determineBaseFiles: _determineBaseFiles
  compilerLib: _compilerLib
