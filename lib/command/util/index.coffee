path   = require 'path'
fs     = require 'fs'

color  = require('ansi-color').set
_      = require 'lodash'
wrench = require 'wrench'

logger = require '../../util/logger'
fileUtils = require '../../util/file'
defaults = require './defaults'
compilerCentral = require '../../modules/compilers'

exports.projectPossibilities = (callback) ->
  compilers = compilerCentral.compilersByType()

  # just need to check SASS
  for comp in compilers.css
    # this won't work as is if a second compiler needs to shell out
    if comp.checkIfExists?
      comp.checkIfExists (exists) =>
        unless exists
          logger.debug "Compiler for file [[ #{comp.fileName} ]], is not installed/available"
          comp.prettyName = comp.prettyName + color(" (This is not installed and would need to be before use)", "yellow+bold")
        callback(compilers)
      break

exports.processConfig = (opts, callback) ->
  configPath = _findConfigPath()
  {config} = require configPath if configPath?
  unless config?
    logger.warn "No configuration file found (mimosa-config.coffee), running from current directory using Mimosa's defaults."
    logger.warn "Run 'mimosa config' to copy the default Mimosa configuration to the current directory."
    config = {}
    configPath = path.dirname path.resolve('right-here.foo')

  logger.debug "Your mimosa config:\n#{JSON.stringify(config, null, 2)}"

  config.virgin =       opts?.virgin
  config.isServer =     opts?.server
  config.optimize =     opts?.optimize
  config.min =          opts?.minify
  config.isForceClean = opts?.force

  defaults.applyAndValidateDefaults config, configPath, (err, newConfig) =>
    if err
      logger.fatal "Unable to start Mimosa, #{err} configuration(s) problems listed above."
      process.exit 1
    else
      logger.setConfig(newConfig)
      callback(newConfig)

exports.cleanCompiledDirectories = (config) ->
  items = wrench.readdirSyncRecursive(config.watch.sourceDir)
  files = items.filter (f) -> fs.statSync(path.join(config.watch.sourceDir, f)).isFile()
  directories = items.filter (f) -> fs.statSync(path.join(config.watch.sourceDir, f)).isDirectory()
  directories = _.sortBy(directories, 'length').reverse()

  {compilerExtensionHash, compilers} = compilerCentral.getCompilers(config)

  _cleanMisc(config, compilers)
  _cleanFiles(config, files, compilerExtensionHash)
  _cleanDirectories(config, directories)

  logger.success "[[ #{config.watch.compiledDir} ]] has been cleaned."

_findConfigPath = (configPath = path.resolve('mimosa-config.coffee')) ->
  if fs.existsSync configPath
    logger.debug "Found mimosa-config: [[ #{configPath} ]]"
    configPath
  else
    configPath = path.join(path.dirname(configPath), '..', 'mimosa-config.coffee')
    logger.debug "Trying #{configPath}"
    if configPath.length is 'mimosa-config.coffee'.length + 1
      logger.debug "Unable to find mimosa-config"
      return null
    _findConfigPath(configPath)

_cleanMisc = (config, compilers) ->
  jsDir = path.join config.watch.compiledDir, config.watch.javascriptDir
  files = fileUtils.glob "#{jsDir}/**/*-built.js"
  for file in files
    logger.debug("Deleting '-built' file, [[ #{file} ]]")
    fs.unlinkSync file

  compiledJadeFile = path.join config.watch.compiledDir, 'index.html'
  if fs.existsSync compiledJadeFile
    logger.debug("Deleting compiledJadeFile [[ #{compiledJadeFile} ]]")
    fs.unlinkSync compiledJadeFile

  logger.debug("Cleaning up templates")
  outputFileName = config.template.outputFileName
  if _.isString(outputFileName)
    filePath = path.join config.watch.compiledJavascriptDir, outputFileName + ".js"
    fs.unlinkSync filePath if fs.existsSync filePath
  else
    for ext, fileName of outputFileName
      filePath = path.join config.watch.compiledJavascriptDir, fileName + ".js"
      fs.unlinkSync filePath if fs.existsSync filePath

  compiler.removeClientLibrary() for compiler in compilers when compiler.removeClientLibrary?

_cleanFiles = (config, files, compilerExtensionHash) ->
  for file in files
    compiledPath = path.join config.watch.compiledDir, file

    extension = path.extname(file)
    if extension?.length > 0
      extension = extension.substring(1)
      compiler = compilerExtensionHash[extension]
      # TODO
      #if compiler? and compiler.getOutExtension()
      #  compiledPath = compiledPath.replace(/\.\w+$/, ".#{compiler.getOutExtension()}")

    if fs.existsSync compiledPath
      logger.debug "Deleting file [[ #{compiledPath} ]]"
      fs.unlinkSync compiledPath

_cleanDirectories = (config, directories) ->
  for dir in directories
    dirPath = path.join(config.watch.compiledDir, dir)
    if fs.existsSync dirPath
      logger.debug "Deleting directory [[ #{dirPath} ]]"
      fs.rmdir dirPath, (err) ->
        if err?.code is not "ENOTEMPTY"
          logger.error "Unable to delete directory, #{dirPath}"
          logger.error err