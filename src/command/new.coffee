path =   require 'path'
{exec} = require 'child_process'
fs =     require 'fs'

wrench =   require 'wrench'
_ =        require 'lodash'
logger =   require 'logmimosa'

deps =      require('../../package.json').dependencies
moduleManager = require '../modules'

setupData = require "./setup.json"
compilers = setupData.compilers
views = setupData.views
servers = setupData.servers

program = null
projectName = null
outConfig = {}
devDependencies ={}
packageJson = null
skeletonOutPath = process.cwd()
windowsDrive = /^[A-Za-z]:\\/

printHelp = ->
  logger.green('  The new command will take you through a series of questions regarding what')
  logger.green('  JavaScript transpiler, CSS preprocessor, micro-templating library, server')
  logger.green('  and server view technology you would like to use to build your project. Once')
  logger.green('  you have answered the questions, Mimosa will create a directory using the name')
  logger.green('  you provided, and place a project skeleton inside of it.  That project skeleton')
  logger.green('  will by default include a basic application using the technologies you selected.')
  logger.blue( '\n    $ mimosa new [nameOfProject]\n')
  logger.green('  If you wish to copy the project skeleton into your current directory instead of')
  logger.green('  into a new one leave off the name.')
  logger.blue( '\n    $ mimosa new\n')
  logger.green('  If you are happy with the defaults (CoffeeScript, Stylus, Handlebars, Express, Jade),')
  logger.green('  you can bypass the prompts by providing a \'defaults\' flag.')
  logger.blue( '\n    $ mimosa new [name] --defaults')
  logger.blue( '    $ mimosa new [name] -d\n')

moveDirectoryContents = (sourcePath, outPath) ->
  unless fs.existsSync outPath
    wrench.mkdirSyncRecursive outPath, 0o0777

  for item in wrench.readdirSyncRecursive(sourcePath)
    fullSourcePath = path.join sourcePath, item
    fileStats = fs.statSync fullSourcePath
    fullOutPath = path.join outPath, item
    if fileStats.isDirectory()
      logger.debug "Copying directory: [[ #{fullOutPath} ]]"
      wrench.mkdirSyncRecursive fullOutPath, 0o0777
    if fileStats.isFile()
      logger.debug "Copying file: [[ #{fullSourcePath} ]]"
      fileContents = fs.readFileSync fullSourcePath
      fs.writeFileSync fullOutPath, fileContents

create = (chosen) ->
  [chosen.javascript.name, chosen.css.name, chosen.template.name].forEach (compName) ->
    unless compName is "none"
      outConfig.modules.push compName
      devDependencies["mimosa-" + compName] = "*"

  skeletonPath = path.join __dirname, '..', '..', 'skeleton'
  moveDirectoryContents skeletonPath, skeletonOutPath
  setupPackageJSON chosen
  makeChosenCompilerChanges chosen
  modifyBowerJSONName()
  moveViews chosen
  makeServerChanges chosen
  runNPMInstall()

  logger.debug "Renaming .gitignore"
  fs.renameSync (path.join skeletonOutPath, ".ignore"), (path.join skeletonOutPath, ".gitignore")

createWithDefaults = ->
  chosen = {}
  chosen.css =        (compilers.css.filter        (item) -> item.isDefault)[0]
  chosen.javascript = (compilers.javascript.filter (item) -> item.isDefault)[0]
  chosen.template =   (compilers.template.filter   (item) -> item.isDefault)[0]
  chosen.server =     (servers.filter              (item) -> item.isDefault)[0]
  chosen.views =      (views.filter                (item) -> item.isDefault)[0]

  if logger.isDebug()
    logger.debug "Chosen items :\n#{JSON.stringify(chosen, null, 2)}"

  create(chosen)

updateConfigForChosenCompilers = (comps) ->
  # return if all the defaults were chosen
  return if comps.javascript.isDefault and comps.views.isDefault

  # server.coffee and server.js are both assumed by mimosa-server
  if (not comps.javascript.isDefault) and (comps.server.name isnt "None") and (comps.javascript.name isnt "none") and (comps.javascript.name isnt "typescript")
    outConfig.server ?= {}
    outConfig.server.path = "server.#{comps.javascript.defaultExtensions[0]}"

  unless comps.views.isDefault
    outConfig.server ?= {}
    outConfig.server.views ?= {}
    outConfig.server.views.compileWith = comps.views.name
    outConfig.server.views.extension = comps.views.extension

makeChosenCompilerChanges = (chosenCompilers) ->
  logger.debug "Chosen compilers:\n#{JSON.stringify(chosenCompilers, null, 2)}"
  updateConfigForChosenCompilers(chosenCompilers)
  copyCompilerSpecificExampleFiles(chosenCompilers)

usingOwnServer = (chosen) ->
  logger.debug "Moving server into place"
  moveDirectoryContents(path.join(skeletonOutPath, "servers", chosen.server.name.toLowerCase()), skeletonOutPath)
  wrench.rmdirSyncRecursive path.join(skeletonOutPath, "servers")

modifyBowerJSONName = ->
  if projectName
    bowerPath = path.join skeletonOutPath, "bower.json"
    bowerJson = require(bowerPath)
    bowerJson.name = projectName
    fs.writeFileSync bowerPath, JSON.stringify(bowerJson, null, 2)

copyCompilerSpecificExampleFiles = (comps) ->
  safePaths = _.flatten([comps.javascript.defaultExtensions, comps.css.defaultExtensions, comps.template.defaultExtensions]).map (path) ->
    "\\.#{path}$"

  assetsPath = path.join skeletonOutPath,  'assets'
  allItems = wrench.readdirSyncRecursive(assetsPath)
  files = allItems.filter (i) -> fs.statSync(path.join(assetsPath, i)).isFile()

  for file in files
    filePath = path.join(assetsPath, file)
    isSafe = safePaths.some (path) -> file.match(path)

    # clear out the bad views
    if isSafe
      if filePath.indexOf('example-view-') >= 0
        if comps.template.defaultExtensions.some((ext) -> filePath.indexOf("-#{ext}.") >= 0)
          templateView = filePath
        else
          isSafe = false

      isSafe = false if filePath.indexOf('handlebars-helpers') >= 0 and
        not comps.template.defaultExtensions.some (ext) -> ext is "hbs" or ext is "emblem"

    fs.unlinkSync filePath unless isSafe

  serverPath = path.join skeletonOutPath, 'servers'
  allItems = wrench.readdirSyncRecursive(serverPath)
  files = allItems.filter (i) -> fs.statSync(path.join(serverPath, i)).isFile()

  # Typescript hack since cannot handle typescript on the server
  if comps.javascript.name is "typescript"
    safePaths.push "\\.js$"

  files.filter (file) ->
    not safePaths.some (pathh) -> file.match(pathh)
  .map (file) ->
    path.join(serverPath, file)
  .forEach (filePath) ->
    fs.unlinkSync filePath

  # Handle iced vendor file
  if comps.javascript.name is "iced-coffeescript"
    baseIcedPath = path.join(skeletonOutPath, "assets", "javascripts", "vendor")
    fs.renameSync path.join(baseIcedPath, "iced.js.iced"), path.join(baseIcedPath, "iced.js")

  # alter template view name and insert css framework
  if templateView?
    data = fs.readFileSync templateView, "ascii"
    fs.unlinkSync templateView
    cssFramework = if comps.css.name is "none" then "pure CSS" else comps.css.name
    data = data.replace "CSSHERE", cssFramework
    templateView = templateView.replace /-\w+\.(\w+)$/, ".$1"
    fs.writeFile templateView, data

moveViews = (chosen) ->
  logger.debug "Moving views into place"
  moveDirectoryContents(path.join(skeletonOutPath, "view", chosen.views.name), skeletonOutPath)
  wrench.rmdirSyncRecursive path.join(skeletonOutPath, "view")

usingNoServer = ->
  outConfig.modules.splice(outConfig.modules.indexOf("server"), 1)
  outConfig.modules.splice(outConfig.modules.indexOf("live-reload"), 1)

  logger.debug "Using no server, so removing server resources and config"
  wrench.rmdirSyncRecursive path.join(skeletonOutPath, "servers")

# remove express files/directories and update config to point to default server
usingDefaultServer = ->
  logger.debug "Using default server, so removing server resources"
  wrench.rmdirSyncRecursive path.join(skeletonOutPath, "servers")

  outConfig.server ?= {}
  outConfig.server.defaultServer = enabled: true

makeServerChanges = (chosen) ->
  if chosen.server.name is "None"
    usingNoServer()
  else if chosen.server.name is "Mimosa's Express"
    usingDefaultServer()
  else
    usingOwnServer chosen

setupPackageJSON = (chosen) ->
  logger.debug "Making package.json edits"

  jPath = path.join skeletonOutPath, "package.json"
  packageJson = require(jPath)
  if projectName
    packageJson.name = projectName

  if Object.keys(devDependencies).length > 0
    packageJson.devDependencies = devDependencies

  # if using own server, then need to set node dependencies for views
  # server and language, otherwise have no depedencies
  if chosen.server.library
    [chosen.views, chosen.javascript, chosen.server].forEach (chosenItem) ->
      if chosenItem.version
        packageJson.dependencies[chosenItem.library] = chosenItem.version
  else
    delete packageJson.dependencies

  fs.writeFileSync jPath, JSON.stringify(packageJson, null, 2)

runNPMInstall = ->
  if (packageJson.dependencies and Object.keys(packageJson.dependencies).length > 0) or packageJson.devDependencies
    msg = "Installing"
    if packageJson.dependencies and Object.keys(packageJson.dependencies).length > 0
      msg += " application"
      if packageJson.devDependencies
        msg += " and"
    if packageJson.devDependencies
      msg += " Mimosa development"
    msg += " node modules. This may take a few seconds."

    logger.info msg

    currentDir = process.cwd()
    process.chdir skeletonOutPath
    exec "npm install", (err, sout, serr) ->
      if err
        logger.error err
      else
        console.log sout

      logger.debug "Node module install sout: #{sout}"
      logger.debug "Node module install serr: #{serr}"

      process.chdir currentDir

      writeConfigs()
  else
    writeConfigs()

writeConfigs = ->
  configPath = path.join skeletonOutPath, "mimosa-config.js"
  outConfigText = "exports.config = " + JSON.stringify( outConfig, null, 2 )
  fs.writeFile configPath, outConfigText, (err) ->
    currentDir = process.cwd()
    process.chdir skeletonOutPath
    exec "mimosa config --suppress", (err, sout, serr) ->
      if err
        logger.error err
      else
        console.log sout

      process.chdir currentDir

      logger.success "New project creation complete!  Execute 'mimosa watch' from inside your project to monitor the file system. Then start coding!"
      process.stdin.destroy()

prompting = ->
  if logger.isDebug()
    logger.debug "Compilers :\n#{JSON.stringify(compilers, null, 2)}"

  logger.green "\n  Mimosa will guide you through technology selection and project creation. For"
  logger.green "  all of the selections, if your favorite is not an option, you can add a"
  logger.green "  GitHub issue and we'll look into adding it."

  logger.green "\n  If you are unsure which options to pick, the ones with asterisks are Mimosa"
  logger.green "  favorites. Feel free to hit the web to research your selections, Mimosa will"
  logger.green "  be here when you get back."

  logger.green "\n  To start, please choose your JavaScript transpiler: \n"

  program.choose _.pluck(compilers.javascript, 'prettyName'), (i) ->
    logger.blue "\n  You chose #{compilers.javascript[i].prettyName}."
    chosen = {javascript: compilers.javascript[i]}
    logger.green "\n  Choose your CSS preprocessor:\n"
    program.choose _.pluck(compilers.css, 'prettyName'), (i) ->
      logger.blue "\n  You chose #{compilers.css[i].prettyName}."
      chosen.css = compilers.css[i]
      logger.green "\n  Choose your micro-templating language:\n"
      program.choose _.pluck(compilers.template, 'prettyName'),(i) ->
        logger.blue "\n  You chose #{compilers.template[i].prettyName}."
        chosen.template = compilers.template[i]
        logger.green "\n  Choose your server technology: \n"
        program.choose _.pluck(servers, 'prettyName'),(i) ->
          logger.blue "\n  You chose #{servers[i].prettyName}."
          chosen.server = servers[i]
          logger.green "\n  And finally choose your server view templating library:\n"
          program.choose _.pluck(views, 'prettyName'),(i) ->
            logger.blue "\n  You chose #{views[i].prettyName}."
            chosen.views = views[i]
            logger.green "\n  Creating and setting up your project... \n"
            create(chosen)


isSystemPath = (str) ->
  windowsDrive.test(str) or str.indexOf("/") is 0

newProject = (name, opts) ->
  if opts.mdebug
    opts.debug = true
    logger.setDebug()
    process.env.DEBUG = true

  outConfig.modules = moduleManager.builtIns.map (builtIn) -> builtIn.substring(7)

  logger.debug "Project name: #{name}"

  if name
    outPath = if isSystemPath(name)
      projectName = path.basename(projectName)
      name
    else
      projectName = name
      path.join process.cwd(), projectName

    if fs.existsSync outPath
      logger.error "Directory/file exists at [[ #{outPath} ]], cannot continue."
      process.exit 0
    skeletonOutPath = outPath

  if opts.defaults
    createWithDefaults()
  else
    prompting()

register = (prog) ->
  program = prog
  program
    .command('new [name]')
    .description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup")
    .option("-d, --defaults",  "bypass prompts and go with Mimosa defaults (CoffeeScript, Stylus, Handlebars)")
    .option("-D, --mdebug", "run in debug mode")
    .action(newProject)
    .on '--help', printHelp

module.exports = register