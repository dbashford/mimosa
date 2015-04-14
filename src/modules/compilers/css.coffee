"use strict"

path = require 'path'
_ = require 'lodash'
logger = require 'logmimosa'
utils = require './css-utils'

_init = (config, options, next) ->
  options.destinationFile = (fileName) ->
    utils.buildDestinationFile config, fileName
  next()

module.exports = class CSSCompiler

  constructor: (config, @compiler) ->
    @extensions = @compiler.extensions(config)

  registration: (config, register) ->
    register ['add','update','remove','cleanFile','buildExtension'], 'init', _init, @extensions

    register ['buildExtension'], 'init',    @_processWatchedDirectories, [@extensions[0]]
    register ['buildExtension'], 'init',    @_findBasesToCompileStartup, [@extensions[0]]
    register ['buildExtension'], 'compile', @_compile,                   [@extensions[0]]

    exts = @extensions
    if @compiler.canFullyImportCSS
      exts.push "css"

    register ['add'],                               'init',         @_processWatchedDirectories, exts
    register ['remove','cleanFile'],                'init',         @_checkState,                exts
    register ['add','update','remove','cleanFile'], 'init',         @_findBasesToCompile,        exts
    register ['add','update','remove'],             'compile',      @_compile,                   exts
    register ['update','remove'],                   'afterCompile', @_processWatchedDirectories, exts

  _compile: (config, options, next) =>
    utils.compile(config, options, next, @extensions, @compiler);

  _findBasesToCompileStartup: (config, options, next) =>
    utils.findBasesToCompileStartup( config, options, next, @includeToBaseHash, @baseFiles)

  _findBasesToCompile: (config, options, next) =>
    utils.findBasesToCompile(
      config, options, next,
      @extensions, @includeToBaseHash,
      @compiler, @baseFiles)

  # for clean
  _checkState: (config, options, next) =>
    if @includeToBaseHash?
      next()
    else
      @_processWatchedDirectories(config, options, next)

  _processWatchedDirectories: (config, options, next) =>
    @includeToBaseHash = {}
    allFiles = utils.getAllFiles(config, @extensions, @compiler.canFullyImportCSS)

    oldBaseFiles = @baseFiles ?= []
    @baseFiles = @compiler.determineBaseFiles(allFiles).filter (file) ->
      path.extname(file) isnt '.css'
    allBaseFiles = _.union oldBaseFiles, @baseFiles

    # Change in base files to be compiled, cleanup and message
    if (allBaseFiles.length isnt oldBaseFiles.length or allBaseFiles.length isnt @baseFiles.length) and oldBaseFiles.length > 0
      logger.info "The list of CSS files that Mimosa will compile has changed. Mimosa will now compile the following root files to CSS:"
      logger.info baseFile for baseFile in @baseFiles

    for baseFile in @baseFiles
      utils.importsForFile(baseFile, baseFile, allFiles, @compiler, @includeToBaseHash)

    next()