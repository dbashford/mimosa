path   = require 'path'
fs     = require 'fs'

color  = require('ansi-color').set
_      = require 'lodash'
wrench = require 'wrench'
logger = require 'logmimosa'

fileUtils = require './file'
configurer = require './configurer'
Cleaner = require './cleaner'
compilerCentral = require '../modules/compilers'

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
  configPath = _findConfigPath('mimosa-config.coffee', path.resolve('mimosa-config.coffee'))
  unless configPath?
    logger.debug "Didn't find mimosa-config.coffee, going to try mimosa-config.js"
    configPath = _findConfigPath('mimosa-config.js', path.resolve('mimosa-config.js'))

  try
    {config} = require configPath if configPath?
  catch err
    return logger.fatal "Improperly formatted configuration file: #{err}"
    config = null

  if config?
    configPath = path.dirname configPath
  else
    logger.warn "No configuration file found (mimosa-config.coffee/mimosa-config.js), running from current directory using Mimosa's defaults."
    logger.warn "Run 'mimosa config' to copy the default Mimosa configuration to the current directory."
    config = {}
    configPath = process.cwd()

  logger.debug "Config path is #{configPath}"
  logger.debug "Your mimosa config:\n#{JSON.stringify(config, null, 2)}"

  config.isVirgin =     opts?.virgin
  config.isServer =     opts?.server
  config.isOptimize =   opts?.optimize
  config.isMinify =     opts?.minify
  config.isForceClean = opts?.force
  config.isClean =      opts?.clean
  config.isBuild =      opts?.build
  config.isWatch =      opts?.watch
  config.isPackage =    opts?.package
  config.isInstall =    opts?.install

  configurer.applyAndValidateDefaults config, configPath, (err, newConfig, modules) =>
    if err
      logger.error "Unable to start Mimosa for the following reason(s):\n * #{err.join('\n * ')} "
      process.exit 1
    else
      logger.debug "Full mimosa config:\n#{JSON.stringify(newConfig, null, 2)}"
      logger.setConfig(newConfig)
      callback(newConfig, modules)

exports.cleanCompiledDirectories = (config, cb) ->
  i = 0
  done = ->
    cb() if ++i is 2

  new Cleaner config, ->
    _cleanMisc config, done
    _cleanUp config, done

exports.deepFreeze = (o) ->
  Object.freeze(o)
  Object.getOwnPropertyNames(o).forEach (prop) =>
    if o.hasOwnProperty(prop) and o[prop] isnt null and
    (typeof o[prop] is "object" || typeof o[prop] is "function") and
    not Object.isFrozen(o[prop])
      exports.deepFreeze o[prop]

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

_findConfigPath = (fileName, configPath) ->
  if fs.existsSync configPath
    logger.debug "Found mimosa-config: [[ #{configPath} ]]"
    configPath
  else
    configPath = path.join(path.dirname(configPath), '..', fileName)
    logger.debug "Trying #{configPath}"
    dirname = path.dirname configPath
    if dirname.indexOf(path.sep) is dirname.lastIndexOf(path.sep)
      logger.debug "Unable to find mimosa-config"
      return null
    _findConfigPath(fileName, configPath)