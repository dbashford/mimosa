path =   require 'path'
fs =     require 'fs'
{exec} = require 'child_process'

wrench = require 'wrench'
logger = require 'logmimosa'

mimosaPath = path.join __dirname, '..', '..', '..'
currentDir = process.cwd()

install = (name, opts) ->
  if opts.debug then logger.setDebug()

  if name?
    unless name.indexOf('mimosa-') is 0
      return logger.error "Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server)."
  else

    try
      pack = require path.join currentDir, 'package.json'
    catch err
      return logger.error "Unable to find package.json, or badly formatted: #{err}"

    unless pack.name? and pack.version?
      return logger.error "package.json missing either name or version"

    unless pack.name.indexOf('mimosa-') is 0
      return logger.error "package.json name is [[ #{pack.name} ]]. Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server). "

    name = currentDir

  process.chdir mimosaPath

  unless name.indexOf("@") > 7
    oldVersion = moveThingsToPrepareForInstall name

  installModule name, done(name, oldVersion)

done = (name, oldVersion) ->
  (err) ->
    if oldVersion
      # need to move things back
      if err
        putThingsBack oldVersion, name
      cleanUp name

    process.chdir currentDir
    process.exit 0

moveThingsToPrepareForInstall = (name) ->
  beginPath = path.join mimosaPath, "node_modules", name
  oldVersion = null
  if fs.existsSync beginPath
    endPath = path.join mimosaPath, "node_modules", name + "_____backup"
    wrench.copyDirSyncRecursive beginPath, endPath

    mimosaPackagePath = path.join mimosaPath, 'package.json'
    mimosaPackage = require mimosaPackagePath
    if mimosaPackage.dependencies[name]
      oldVersion = mimosaPackage.dependencies[name]
      delete mimosaPackage.dependencies[name]
      logger.debug "New mimosa dependencies:\n #{JSON.stringify(mimosaPackage, null, 2)}"
      fs.writeFileSync mimosaPackagePath, JSON.stringify(mimosaPackage, null, 2), 'ascii'

  oldVersion

cleanUp = (name) ->
  backupPath = path.join mimosaPath, "node_modules", name + "_____backup"
  try
    wrench.rmdirSyncRecursive backupPath
  catch err
    logger.error "Error removing module backup folder at [[ #{backupPath} ]]"

putThingsBack = (oldVersion, name) ->
  beginPath = path.join mimosaPath, "node_modules", name + "_____backup"
  if fs.existsSync beginPath
    endPath = path.join mimosaPath, "node_modules", name
    wrench.copyDirSyncRecursive beginPath, endPath

    mimosaPackagePath = path.join mimosaPath, 'package.json'
    mimosaPackage = require mimosaPackagePath
    mimosaPackage.dependencies[name] = oldVersion
    logger.debug "New mimosa dependencies:\n #{JSON.stringify(mimosaPackage, null, 2)}"
    fs.writeFileSync mimosaPackagePath, JSON.stringify(mimosaPackage, null, 2), 'ascii'

installModule = (name, done) ->
  installString = "npm install #{name} --save"
  exec installString, (err, sout, serr) =>
    unless err
      console.log sout
      logger.success "Install of '#{name}' successful"

    logger.debug "NPM INSTALL standard out\n#{sout}"
    logger.debug "NPM INSTALL standard err\n#{serr}"

    done(err)

register = (program, callback) ->
  program
    .command('mod:install [name]')
    .option("-D, --debug", "run in debug mode")
    .description("install a Mimosa module into your Mimosa")
    .action(callback)
    .on '--help', =>
      logger.green('  The \'mod:install\' command will install a Mimosa module into Mimosa. It does not install')
      logger.green('  the module into your project, it just makes it available to be used by Mimosa\'s commands.')
      logger.green('  You can discover new modules using the \'mod:all\' command.  Once you know the module you')
      logger.green('  would like to install, put the name of the module after the \'mod:install\' command.')
      logger.blue( '\n    $ mimosa mod:install mimosa-server\n')
      logger.green('  If there is a specific version of a module you want to use, simply append \'@\' followed by')
      logger.green('  the version information.')
      logger.blue( '\n    $ mimosa mod:install mimosa-server@0.1.0\n')
      logger.green('  If you are developing a module and would like to install your local module into your local')
      logger.green('  Mimosa, then execute \'mod:install\' from the root of the module, the same location as the')
      logger.green('  package.json, without providing a name.  Mimosa will copy the module and install it.')
      logger.blue( '\n    $ mimosa mod:install\n')

module.exports = (program) ->
  register program, install