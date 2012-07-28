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

  logger.info "Re-writing package.json"

  clientPackageText = fs.readFileSync clientPackageJsonPath, 'ascii'
  mimosaPackageText = fs.readFileSync mimosaPackageJsonPath, 'ascii'

  clientPackageJson = JSON.parse(clientPackageText)
  mimosaPackageJson = JSON.parse(mimosaPackageText)

  for name, version of mimosaPackageJson.dependencies
    clientPackageJson.dependencies[name] = version

  clientOut = JSON.stringify(clientPackageJson, null, 2)

  fs.writeFileSync clientPackageJsonPath, clientOut, 'ascii'

  logger.info "Installing node modules"
  currentDir = process.cwd()
  process.chdir path.dirname(clientPackageJsonPath)
  exec "npm install", (err, sout, serr) ->
    process.chdir currentDir
    logger.success "Your project is up to date!"

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