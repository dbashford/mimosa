path =   require 'path'
fs =     require 'fs'
{exec} = require 'child_process'

logger = require 'logmimosa'

util =   require 'util'

update = (opts) ->
  if opts.debug then logger.setDebug()

  clientPackageJsonPath = _findPackageJsonPath()
  unless clientPackageJsonPath?
    return logger.info "Did not find package.json.  Nothing to update."

  logger.debug "client package.json path: [[ #{clientPackageJsonPath} ]]"
  clientPackageJson = require clientPackageJsonPath

  mimosaPackageJsonPath = path.join __dirname, '..', 'skeleton', 'package.json'
  logger.debug "mimosa package.json path: [[ #{mimosaPackageJsonPath} ]]"
  mimosaPackageJson = require mimosaPackageJsonPath

  currentDir = process.cwd()
  process.chdir path.dirname(clientPackageJsonPath)

  done = ->
    process.chdir currentDir
    logger.success "Finished.  You are all up to date!"
    process.exit 0

  jspacks = ['iced-coffee-script', 'LiveScript', 'typescript']

  for pack in jspacks
    if !clientPackageJson.dependencies[pack]? and mimosaPackageJson.dependencies[pack]?
      logger.debug "Removing #{pack} from list of dependencies to install."
      delete mimosaPackageJson.dependencies[pack]

  _uninstallDependencies mimosaPackageJson.dependencies, clientPackageJson.dependencies, ->
    _installDependencies(mimosaPackageJson.dependencies, clientPackageJson.dependencies, done)

_uninstallDependencies = (deps, clientDeps, callback) ->
  present = []
  for name, version of deps
    if clientDeps[name]
      logger.info "Un-installing node package. #{name}:#{clientDeps[name]}"
      present.push name

  if present.length > 0
    exec "npm uninstall #{present.join(' ')} --save", (err, sout, serr) =>
      if err
        logger.info(err) if err
      else
        logger.success "Uninstall successful"
        callback(deps)
  else
    callback(deps)

_installDependencies = (deps, origClientDeps, done) ->
  names = for name, version of deps
    continue unless origClientDeps[name]?
    logger.info "Installing node package: #{name}:#{version}"
    if version.indexOf("github.com") > -1
      version
    else
      "#{name}@#{version}"

  installString = "npm install #{names.join(' ')} --save"
  logger.debug "Installing, npm command is '#{installString}'"
  exec installString, (err, sout, serr) =>
    if err then logger.info(err) else logger.success "Install successful"
    logger.debug "NPM INSTALL standard out\n#{sout}"
    logger.debug "NPM INSTALL standard err\n#{serr}"
    done()

_findPackageJsonPath = (packagePath = path.resolve('package.json')) ->
  if fs.existsSync packagePath
    packagePath
  else
    packagePath = path.join(path.dirname(packagePath), '..', 'package.json')
    logger.debug "Didn not find package.json, trying [[ #{packagePath} ]]"
    dirname = path.dirname packagePath
    if dirname.indexOf(path.sep) is dirname.lastIndexOf(path.sep)
      return null
    else
      _findPackageJsonPath(packagePath)

register = (program, callback) ->
  program
    .command('update')
    .option("-D, --debug", "run in debug mode")
    .description("update all the node libraries that Mimosa packaged into your application")
    .action(callback)
    .on '--help', =>
      logger.green('  The update command keeps you from having to deal with updating your project\'s node_modules ')
      logger.green('  directory when Mimosa updates its libraries.  For instance, if Express updates to a new,')
      logger.green('  version this command will update your package.json and install new node packages so you')
      logger.green('  can take advantage of the new Express functionality without having to deal with installing')
      logger.green('  it yourself.')
      logger.blue( '\n    $ mimosa update\n')

module.exports = (program) ->
  register(program, update)