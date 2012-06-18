AbstractCssCompiler = require './css-compiler'
fs = require 'fs'
wrench = require 'wrench'
path = require 'path'
{spawn, exec} = require 'child_process'
logger = require '../../util/logger'

module.exports = class SassCompiler extends AbstractCssCompiler

  importRegex: /@import ['"](.*)['"]/g
  partialToBaseHash:{}
  startupFinished:false

  constructor: (config) ->
    super(config)
    @extensions = config?.extensions or ['scss', 'sass']
    @hasCompass = config?.hasCompass or true

  created: (fileName) =>
    if @startupFinished
      if @_isPartial(fileName) then @_compileBasesForPartial(fileName) else super(fileName)

  updated: (fileName) =>
    if @_isPartial(fileName) then @_compileBasesForPartial(fileName) else super(fileName)

  removed: (fileName) =>
    if @_isPartial(fileName) then @_compileBasesForPartial(fileName) else super(fileName)

  doneStartup: =>
    @startupFinished = true
    @compileAndWrite(base) for base in @baseSassFiles

  compile: (sassText, fileName, destinationFile, callback) ->
    result = ''
    error = null
    options = ['--stdin', '--load-path', @origDir, '--load-path', path.dirname(fileName), '--scss']
    options.push('--compass') if @hasCompass
    sass = spawn 'sass', options
    sass.stdin.end sassText
    sass.stdout.on 'data', (buffer) -> result += buffer.toString()
    sass.stderr.on 'data', (buffer) ->
      error ?= ''
      error += buffer.toString()
    sass.on 'exit', (code) -> callback(error, result, destinationFile)

  _isPartial: (fileName) -> path.basename(fileName).startsWith('_')

  _compileBasesForPartial: (fileName) ->
    bases = @partialToBaseHash[fileName]
    if bases?
      for base in bases
        @compileAndWrite(base)
        @processWatchedDirectories()
    else
      logger.warn "Orphaned partial #{fileName}"

  processWatchedDirectories: ->
    @partialToBaseHash = {}
    @sassFiles = wrench.readdirSyncRecursive(@origDir)
      .map( (file) => path.join(@origDir, file))
      .filter (file) => @extensions.some (ext) -> file.endsWith(ext)
    @baseSassFiles = @sassFiles.filter (file) =>
      not @_isPartial(file) and not file.has('compass')

    @_importsForFile(baseFile, baseFile) for baseFile in @baseSassFiles

  # get all imports for a given file, and recurse through
  # those imports until entire tree is built
  _importsForFile: (baseFile, file) ->
    imports = fs.readFileSync(file, 'ascii').match(@importRegex)
    return unless imports?

    for anImport in imports
      @importRegex.lastIndex = 0
      importPath = @importRegex.exec(anImport)[1]
      pathMadePartial = importPath.replace(/(\w+\.|\w+$)/, '_$1')
      partialFiles = @sassFiles.filter (file) -> file.has(pathMadePartial)
      for partialFile in partialFiles
        hash = @partialToBaseHash[partialFile]
        if !hash?
          @partialToBaseHash[partialFile] = [baseFile]
        else
          hash.push(baseFile) if hash.indexOf(baseFile) is -1
        @_importsForFile(baseFile, partialFile)