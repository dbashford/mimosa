path =   require 'path'
fs =     require 'fs'
{exec} = require 'child_process'

util =   require 'util'
logger = require '../util/logger'

update = ->
  clientPackageJsonPath = _findPackageJsonPath()
  unless clientPackageJsonPath?
    logger.fatal "Cannot run update command, failed to find package.json, are you inside your project directory,"
    return logger.fatal "and did you create that project using the `new` command?"

  mimosaPackageJsonPath = path.join __dirname, '..', 'skeleton', 'package.json'

  clientPackageText = fs.readFileSync clientPackageJsonPath, 'ascii'
  mimosaPackageText = fs.readFileSync mimosaPackageJsonPath, 'ascii'

  clientPackageJson = JSON.parse(clientPackageText)
  mimosaPackageJson = JSON.parse(mimosaPackageText)

  currentDir = process.cwd()
  process.chdir path.dirname(clientPackageJsonPath)

  done = ->
    process.chdir currentDir
    logger.success "Finished.  You are all up to date!"

  _uninstallDependencies mimosaPackageJson.dependencies, clientPackageJson.dependencies, ->
    _installDependencies(mimosaPackageJson.dependencies, done)

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
        logger.success "Uninstalling successful"
        callback(deps)
  else
    callback(deps)

_installDependencies = (deps, done) ->
  names = for name, version of deps
    logger.info "Installing node package: #{name}:#{version}"
    name

  exec "npm install #{names.join(' ')} --save", (err, sout, serr) =>
    if err then logger.info(err) else logger.success "Installs successful"
    done()

_findPackageJsonPath = (packagePath = path.resolve('package.json')) ->
  if fs.existsSync packagePath
    packagePath
  else
    packagePath = path.join(path.dirname(packagePath), '..', 'package.json')
    return null if packagePath.length is 'package.json'.length + 1
    _findPackageJsonPath(packagePath)

register = (program, callback) ->
  program
    .command('update')
    .description("update all the node libraries that Mimosa packaged into your application")
    .action(callback)
    .on '--help', =>
      logger.green('  The update command keeps you from having to deal with updating your node_modules directory')
      logger.green('  when Mimosa updates its functionality.  For instance, if Express updates to a new version,')
      logger.green('  this command will update your package.json and install new node packages so you can take')
      logger.green('  advantage of the new Express functionality without having to deal with it yourself.')
      logger.blue( '\n    $ mimosa update\n')

module.exports = (program) ->
  register(program, update)