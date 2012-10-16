path   = require 'path'
fs     = require 'fs'

color  = require('ansi-color').set
_      = require 'lodash'
wrench = require 'wrench'
logger = require 'mimosa-logger'

fileUtils = require '../../util/file'
defaults = require './defaults'
compilerCentral = require '../../modules/compilers'
Cleaner = require './cleaner'

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
  config.isClean =      opts?.clean

  defaults.applyAndValidateDefaults config, configPath, (err, newConfig) =>
    if err
      logger.fatal "Unable to start Mimosa, #{err} configuration(s) problems listed above."
      process.exit 1
    else
      logger.setConfig(newConfig)
      callback(newConfig)

exports.cleanCompiledDirectories = (config, cb) ->
  i = 0
  done = ->
    cb() if ++i is 2

  new Cleaner config, ->
    _cleanMisc config, done
    _cleanUp config, done

_cleanMisc = (config, cb) ->
  jsDir = path.join config.watch.compiledDir, config.watch.javascriptDir
  files = fileUtils.glob "#{jsDir}/**/*-built.js"

  i = 0
  done = ->
    cb() if ++i is files.length + 1

  for file in files
    logger.debug("Deleting '-built' file, [[ #{file} ]]")
    fs.unlink file, (err) ->
      logger.success "Deleted file [[ #{file} ]]"
      done()

  compiledJadeFile = path.join config.watch.compiledDir, 'index.html'
  fs.exists compiledJadeFile, (exists) ->
    if exists
      logger.debug("Deleting compiledJadeFile [[ #{compiledJadeFile} ]]")
      fs.unlink compiledJadeFile, (err) ->
        logger.success "Deleted file [[ #{compiledJadeFile} ]]"
        done()
    else
      done()

_cleanUp = (config, cb) ->
  dir = config.watch.sourceDir
  directories = wrench.readdirSyncRecursive(dir).filter (f) -> fs.statSync(path.join(dir, f)).isDirectory()

  return cb() if directories.length is 0

  i = 0
  done = ->
    cb() if ++i is directories.length

  _.sortBy(directories, 'length').reverse().forEach (dir) ->
    dirPath = path.join(config.watch.compiledDir, dir)
    if fs.existsSync dirPath
      logger.debug "Deleting directory [[ #{dirPath} ]]"
      fs.rmdir dirPath, (err) ->
        if err?.code is not "ENOTEMPTY"
          logger.error "Unable to delete directory, #{dirPath}"
          logger.error err
        else
          logger.success "Deleted empty directory [[ #{dirPath} ]]"
        done()
    else
      done()

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