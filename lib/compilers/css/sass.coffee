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
    exec 'sass --version', (error, stdout, stderr) =>
      if error
        logger.error "SASS is configured as the CSS compiler, but you don't seem to have SASS installed"
        logger.error "SASS is a Ruby gem, information can be found here: http://sass-lang.com/tutorial.html"
        logger.error "SASS can be installed by executing this command: gem install sass"

  created: (fileName) =>
    if @startupFinished
      if @_isPartial(fileName) then @_compileBasesForPartial(fileName) else super(fileName)
    else
      @done()

  updated: (fileName) =>
    if @_isPartial(fileName) then @_compileBasesForPartial(fileName) else super(fileName)

  removed: (fileName) =>
    if @_isPartial(fileName) then @_compileBasesForPartial(fileName) else super(fileName)

  doneStartup: =>
    @startupFinished = true
    @compileAndWrite(base, false) for base in @baseSassFiles

  compile: (sassText, fileName, destinationFile, callback) ->
    result = ''
    error = null
    options = ['--stdin', '--load-path', @srcDir, '--load-path', path.dirname(fileName), '--scss']
    options.push('--compass') if @config.hasCompass
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
      @done()

  processWatchedDirectories: =>
    @partialToBaseHash = {}
    @sassFiles = wrench.readdirSyncRecursive(@srcDir)
      .map( (file) => path.join(@srcDir, file))
      .filter (file) => @config.extensions.some (ext) -> file.endsWith(ext)
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