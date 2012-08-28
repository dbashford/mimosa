path =   require 'path'
{exec} = require 'child_process'
fs =     require 'fs'

wrench = require 'wrench'
_ =      require 'lodash'

fileUtils = require '../util/file'
logger =   require '../util/logger'
util =     require './util'
defaults = require './util/defaults'

class NewCommand

  servers: [
      {name:"express", prettyName:"(*) Express - http://expressjs.com/"}
      {name:"none", prettyName:"None - Mimosa will serve your application for you"}
    ]

  constructor: (@program) ->

  register: =>
    @program
      .command('new [name]')
      .description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup")
      .option("-n, --noserver", "do not include express in the application setup")
      .option("-d, --defaults",  "bypass prompts and go with Mimosa defaults (CoffeeScript, SASS, Handlebars)")
      .option("-D, --debug", "run in debug mode")
      .action(@new)
      .on '--help', @printHelp

  new: (name, opts) =>
    if opts.debug then logger.setDebug()

    logger.debug "Project name: #{name}"

    # give them something to read while we check to see if SASS is installed
    unless opts.defaults
      logger.green "\n  Mimosa will guide you through project creation. You will be prompted to pick the JavaScript"
      logger.green "  meta-language, CSS meta-language, and micro-templating library you would like to use. For more"
      logger.green "  about those choices, see http://mimosajs.com/compilers.html.  You will also be prompted to pick"
      logger.green "  the server you would like to use. If you pick no server, Mimosa will serve your assets for you.\n"
      logger.green "  For all of the technologies, if your favorite is not an option, you can add a GitHub issue"
      logger.green "  and we'll look into adding it. (https://github.com/dbashford/mimosa/issues)\n"

    util.projectPossibilities (compilers) =>
      if opts.defaults
        @_createWithDefaults(compilers, name)
      else
        @_prompting(compilers, name)

  _prompting: (compilers, name) =>
    logger.debug "Compilers :\n#{JSON.stringify(compilers, null, 2)}"

    chosen = {}

    logger.green "  If you are unsure which options to pick, the ones with asterisks are Mimosa favorites. Feel free"
    logger.green "  to hit the web to research your selections, Mimosa will be here when you get back."

    logger.green "\n  To start, please choose your JavaScript meta-language: \n"
    @program.choose _.pluck(compilers.javascript, 'prettyName'), (i) =>
      logger.blue "\n  You chose #{compilers.javascript[i].prettyName}."
      chosen.javascript = compilers.javascript[i]
      logger.green "\n  Now choose your CSS meta-language:\n"
      @program.choose _.pluck(compilers.css, 'prettyName'), (i) =>
        logger.blue "\n  You chose #{compilers.css[i].prettyName}."
        chosen.css = compilers.css[i]
        logger.green "\n  And choose your micro-templating language:\n"
        @program.choose _.pluck(compilers.template, 'prettyName'),(i) =>
          logger.blue "\n  You chose #{compilers.template[i].prettyName}."
          chosen.template = compilers.template[i]
          logger.green "\n  And finally choose your server technology:\n"
          @program.choose _.pluck(@servers, 'prettyName'),(i) =>
            logger.blue "\n  You chose #{@servers[i].prettyName}."
            chosen.server = @servers[i]
            logger.green "\n  Creating and setting up your project... \n"
            @_create(name, chosen)

  _createWithDefaults: (compilers, name) =>
    chosenCompilers = {}
    chosenCompilers.css =        (compilers.css.filter        (item) -> item.isDefault)[0]
    chosenCompilers.javascript = (compilers.javascript.filter (item) -> item.isDefault)[0]
    chosenCompilers.template =   (compilers.template.filter   (item) -> item.isDefault)[0]
    @_create(name, chosenCompilers)

  _create: (name, chosen) =>
    skeletonPath = path.join __dirname, '..', 'skeleton'

    # if name provided, simply copy directory into directory by that name
    # if name not provided, copy all skeleton contents into current directory
    @currPath = if name?.length > 0
      @_copySkeletonToProvidedDirectory(skeletonPath, name)
    else
      @_copySkeletonToCurrentDirectory(skeletonPath)

    @_makeChosenCompilerChanges(chosen)

    @_postCopyCleanUp()

    if chosen.server.name is "none"
      @_usingDefaultServer()
    else
      @_usingOwnServer(name, chosen.server.name)

  _copySkeletonToProvidedDirectory: (skeletonPath, name) ->
    currPath = path.join path.resolve(''), name
    logger.info "Copying skeleton project into #{currPath}"
    wrench.copyDirSyncRecursive skeletonPath, currPath
    currPath

  _copySkeletonToCurrentDirectory: (skeletonPath) ->
    logger.info "A project name was not provided, copying skeleton into the current directory"
    currPath = path.join path.resolve(''), path.sep
    skeletonContents = wrench.readdirSyncRecursive(skeletonPath)
    for item in skeletonContents
      fullSourcePath = path.join skeletonPath, item
      fileStats = fs.statSync fullSourcePath
      fullOutPath = path.join(currPath, item)
      if fileStats.isDirectory()
        logger.debug "Copying directory: [[ #{fullOutPath} ]]"
        wrench.mkdirSyncRecursive fullOutPath, 0o0777
      if fileStats.isFile()
        logger.debug "Copying file: [[ #{fullOutPath} ]]"
        fileContents = fs.readFileSync fullSourcePath
        fs.writeFileSync fullOutPath, fileContents
    currPath

  _makeChosenCompilerChanges: (chosenCompilers) ->
    logger.debug "Chosen compilers:\n#{JSON.stringify(chosenCompilers, null, 2)}"

    @_updateConfigForChosenCompilers(chosenCompilers)
    @_copyCompilerSpecificExampleFiles(chosenCompilers)

  _updateConfigForChosenCompilers: (comps) ->

    # return if all the defaults were chosen
    return if comps.javascript.isDefault and comps.css.isDefault and comps.template.isDefault

    configPath = path.join @currPath, "mimosa-config.coffee"
    config = fs.readFileSync configPath, "ascii"
    config = config.replace "# compilers:", "compilers:"

    unless comps.javascript.isDefault
      config = config.replace "# javascript:", "javascript:"
      config = config.replace '# compileWith: "coffee"', 'compileWith: ' + JSON.stringify(comps.javascript.fileName)
      unless comps.javascript.fileName is "none"
        config = config.replace '# extensions: ["coffee"]', 'extensions:' + JSON.stringify(comps.javascript.defaultExtensions)

    unless comps.css.isDefault
      config = config.replace "# css:", "css:"
      config = config.replace '# compileWith: "sass"', 'compileWith: ' + JSON.stringify(comps.css.fileName)
      unless comps.css.fileName is "none"
        config = config.replace '# extensions: ["scss", "sass"]', 'extensions:' + JSON.stringify(comps.css.defaultExtensions)

    unless comps.template.isDefault
      config = config.replace "# template:", "template:"
      config = config.replace '# compileWith: "handlebars"', 'compileWith: ' + JSON.stringify(comps.template.fileName)
      unless comps.template.fileName is "none"
        config = config.replace '# extensions: ["hbs", "handlebars"]', 'extensions:' + JSON.stringify(comps.template.defaultExtensions)

    fs.writeFileSync configPath, config

    logger.success "Config changed to use selected compilers and to watch default extensions for those compilers."
    logger.success "You may want to check that the extensions Mimosa will watch match those you intend to use."

  _copyCompilerSpecificExampleFiles: (comps) ->
    safePaths = _.flatten([comps.javascript.defaultExtensions, comps.css.defaultExtensions, comps.template.defaultExtensions]).map (path) ->
      "\\.#{path}$"
    safePaths.push "javascripts[/\\\\]vendor"

    assetsPath = path.join @currPath,  'assets'
    allItems = wrench.readdirSyncRecursive(assetsPath)
    files = allItems.filter (i) -> fs.statSync(path.join(assetsPath, i)).isFile()

    for file in files
      filePath = path.join(assetsPath, file)
      isSafe = safePaths.some (path) -> file.match(path)

      # clear out the bad views
      if isSafe
        if filePath.indexOf('example-view-') >= 0
          unless _.some(comps.template.defaultExtensions, (ext) -> filePath.indexOf("-#{ext}.") >= 0)
            isSafe = false
          else
            templateView = filePath

        isSafe = false if filePath.indexOf('handlebars-helpers') >= 0 and
          not _.some(comps.template.defaultExtensions, (ext) -> ext is "hbs")

      fs.unlink filePath unless isSafe

    # alter template view name and insert css framework
    if templateView?
      data = fs.readFileSync templateView, "ascii"
      fs.unlink templateView
      cssFramework = if comps.css.fileName is "none" then "pure CSS" else comps.css.fileName
      data = data.replace "CSSHERE", cssFramework
      templateView = templateView.replace /-\w+\./, "."
      fs.writeFile templateView, data

  _postCopyCleanUp: =>
    data = fs.readFileSync (path.join @currPath, '.npmignore'), 'ascii'
    logger.debug "Writing .gitignore"
    fs.writeFileSync path.join(@currPath, '.gitignore'), data, 'ascii'

    files = fileUtils.glob "#{@currPath}/**/.gitkeep", {dot:true}
    logger.debug "Removing #{files.length} .gitkeeps"
    fs.unlinkSync(file) for file in files

    # for some reason I can't quite figure out
    # won't copy over a public directory, so hack it out here
    newPublicPath = path.join @currPath, 'public'
    oldPublicPath = path.join @currPath, 'publicc'
    fs.renameSync oldPublicPath, newPublicPath

  # remove express files/directories and update config to point to default server
  _usingDefaultServer: ->
    logger.debug "Using default server, so removing server resources"
    fs.unlinkSync path.join(@currPath, "package.json")
    wrench.rmdirSyncRecursive path.join(@currPath, "views")
    wrench.rmdirSyncRecursive path.join(@currPath, "routes")
    wrench.rmdirSyncRecursive path.join(@currPath, "servers")

    logger.debug "Altering configuration to not use server"
    configPath = path.join @currPath, "mimosa-config.coffee"
    fs.readFile configPath, "ascii", (err, data) =>
      data = data.replace "# server:", "server:"
      data = data.replace "# useDefaultServer: false", "useDefaultServer: true"
      fs.writeFile configPath, data, @_done

  _usingOwnServer: (name, serverName) ->
    # minor, kinda silly, but change name in package json to match project name
    if name?.length > 0
      logger.debug "Making package.json edits"
      packageJSONPath = path.join @currPath, "package.json"
      data = fs.readFileSync packageJSONPath, "ascii"
      data = data.replace "APPNAME", name
      fs.writeFileSync packageJSONPath, data

    logger.debug "Moving server into place"
    servers = wrench.readdirSyncRecursive path.join(@currPath, "servers")
    for server in servers
      if path.basename(server).indexOf(serverName) is 0
        serverContents = fs.readFileSync path.join(@currPath, "servers", server), "ascii"
        newPath = path.join @currPath, "server#{path.extname(server)}"
        console.log "new path for server #{newPath}"
        fs.writeFileSync newPath, serverContents
        break

    wrench.rmdirSyncRecursive path.join(@currPath, "servers")

    logger.info "Installing node modules"
    currentDir = process.cwd()
    process.chdir @currPath
    exec "npm install", (err, sout, serr) =>
      logger.debug "Node module install err: #{err}"
      logger.debug "Node module install sout: #{sout}"
      logger.debug "Node module install serr: #{serr}"
      process.chdir currentDir
      @_done()

  _done: ->
    logger.success "New project creation complete!"
    logger.success "Execute 'mimosa watch --server' from inside your project to monitor the file system. then start coding!"
    process.stdin.destroy()

  printHelp: ->
    logger.green('  The new command will take you through a series of questions regarding what meta-lanauges/compilers you would')
    logger.green('  like in your project.  Once you have answered the questions, Mimosa will create a directory using the name')
    logger.green('  provided, and place a project skeleton inside of it.  That project skeleton will by default include a basic')
    logger.green('  Express app, with sample routes and views.  It will also include some sample assets for the meta-lanauges/')
    logger.green('  compilers you selected.')
    logger.blue( '\n    $ mimosa new [nameOfProject]\n')
    logger.green('  If you wish to copy the project skeleton into your current directory instead of into a new one leave off the')
    logger.green('  then leave off name.')
    logger.blue( '\n    $ mimosa new\n')
    logger.green('  Pass a \'noserver\' flag to not include the basic Express app.  With this set up, if you choose to have')
    logger.green('  Mimosa serve up your assets, it will do so with an embedded Mimosa Express app, and not with one inside')
    logger.green('  your project')
    logger.blue( '\n    $ mimosa new [name] --noserver')
    logger.blue( '    $ mimosa new --noserver')
    logger.blue( '    $ mimosa new [name] -n')
    logger.blue( '    $ mimosa new -n\n')
    logger.green('  If you are happy with the defaults (CoffeeScript, SASS, Handlebars), you can bypass the prompts by providing')
    logger.green('  a \'defaults\' flag.')
    logger.blue( '\n    $ mimosa new [name] --defaults')
    logger.blue( '    $ mimosa new [name] -d\n')

module.exports = (program) ->
  command = new NewCommand(program)
  command.register()