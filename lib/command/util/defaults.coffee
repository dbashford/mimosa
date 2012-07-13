path = require 'path'
fs =   require 'fs'

logger =   require '../../util/logger'

class MimosaDefaults

  fatalErrors: 0
  @defaultJavascript: -> "coffee"
  @defaultCss: ->        "sass"
  @defaultTemplate: ->   "handlebars"

  applyAndValidateDefaults: (config, configPath, isServer, callback) =>
    @root = path.dirname(configPath)
    config = @_applyDefaults(config)
    @_validateSettings(config, isServer)
    err = if @fatalErrors is 0 then null else @fatalErrors
    callback(err, config)

  _applyDefaults: (config) ->
    newConfig = {}
    newConfig.watch =             config.watch ?= {}
    newConfig.watch.sourceDir =   path.join(@root, config.watch.sourceDir   ? "assets")
    newConfig.watch.compiledDir = path.join(@root, config.watch.compiledDir ? "public")
    newConfig.watch.ignored =     config.watch.ignored ?= [".sass-cache"]

    comp = newConfig.compilers = config.compilers ?= {}
    js = comp.javascript = config.compilers.javascript ?= {}
    js.directory =         config.compilers.javascript.directory         ?= "javascripts"
    js.compileWith =       config.compilers.javascript.compileWith       ?= MimosaDefaults.defaultJavascript()
    js.extensions =        config.compilers.javascript.extensions        ?= ["coffee"]
    js.notifyOnSuccess =   config.compilers.javascript.notifyOnSuccess   ?= true
    js.lint =              config.compilers.javascript.lint              ?= true
    js.metalint =          config.compilers.javascript.metalint          ?= true

    template = comp.template = config.compilers.template                 ?= {}
    template.compileWith =     config.compilers.template.compileWith     ?= MimosaDefaults.defaultTemplate()
    template.extensions =      config.compilers.template.extensions      ?= ["hbs", "handlebars"]
    template.outputFileName =  config.compilers.template.outputFileName  ?= "javascripts/templates"
    template.notifyOnSuccess = config.compilers.template.notifyOnSuccess ?= true
    template.helperFile = []
    helperFiles = config.compilers.template.helperFiles ?= ["javascripts/app/template/handlebars-helpers"]
    for helperFile in helperFiles
      template.helperFile.push path.join(@root, helperFile)


    css = comp.css =      config.compilers.css                 ?= {}
    css.compileWith =     config.compilers.css.compileWith     ?= MimosaDefaults.defaultCss()
    css.extensions =      config.compilers.css.extensions      ?= ["scss", "sass"]
    css.notifyOnSuccess = config.compilers.css.notifyOnSuccess ?= true
    css.lint =            config.compilers.css.lint            ?= {enabled:true, rules:{}}

    copy = newConfig.copy = config.copy                        ?= {}
    copy.extensions =       config.copy.extensions             ?= ["js","css","png","jpg","jpeg","gif","html"]
    copy.notifyOnSuccess =  config.copy.notifyOnSuccess        ?= false

    server = newConfig.server = config.server                  ?= {}
    server.useDefaultServer =   config.server.useDefaultServer ?= false
    server.port =               config.server.port             ?= 3000
    server.base =               config.server.base             ?= '/app'
    server.useReload =          config.server.useReload        ?= true
    server.path =               config.server.path             ?= 'server.coffee'

    server.path = path.join(@root, server.path)


    requirejs = newConfig.require = config.require                      ?= {}
    requirejs.optimizationEnabled = config.require.optimizationEnabled  ?= true
    requirejs.name =                config.require.name                 ?= "main"
    requirejs.out  =                config.require.out                  ?= "main-built.js"
    requirejs.paths =               config.require.paths                ?= {}
    requirejs.paths.jquery =        config.require.paths.jquery         ?= "vendor/jquery"

    newConfig.coffeelint = @_coffeelint(config.coffeelint)

    newConfig

  _validateSettings: (config, isServer) ->
    @_testPathExists(config.watch.sourceDir,   "watch.sourceDir")
    @_testPathExists(config.watch.compiledDir, "watch.compiledDir")
    @_testPathExists(config.server.path,       "server.path ") if isServer and not config.server.useDefaultServer

    comp = config.compilers
    templatePath = path.join(__dirname, '..', '..', 'compilers/template',  "#{comp.template.compileWith}-compiler.coffee")
    jsPath = path.join(      __dirname, '..', '..', 'compilers/javascript', "#{comp.javascript.compileWith}-compiler.coffee")
    cssPath = path.join(     __dirname, '..', '..', 'compilers/css',        "#{comp.css.compileWith}-compiler.coffee")

    @_testPathExists(templatePath, "compilers.template.compileWith")   unless comp.template.compileWith is "none"
    @_testPathExists(cssPath,      "compilers.css.compileWith")        unless comp.css.compileWith is "none"
    unless comp.javascript.compileWith is "none"
      @_testPathExists(jsPath, "compilers.javascript.compileWith")
      @_testPathExists(path.join(config.watch.sourceDir, comp.javascript.directory),
        "compilers.javascript.directory") unless comp.javascript.compileWith is "none"


  _testPathExists: (filePath, name) ->
    unless fs.existsSync filePath
      logger.fatal "#{name} (#{filePath}) cannot be found"
      @fatalErrors++

  _coffeelint: (overrides) ->
    coffeelint =
      no_tabs:
        level: "error"
      no_trailing_whitespace:
        level: "error"
      max_line_length:
        value: 80,
        level: "error"
      camel_case_classes:
        level: "error"
      indentation:
        value: 2
        level: "error"
      no_implicit_braces:
        level: "ignore"
      no_trailing_semicolons:
        level: "error"
      no_plusplus:
        level: "ignore"
      no_throwing_strings:
        level: "error"
      cyclomatic_complexity:
        value: 11
        level: "ignore"
      line_endings:
        value: "unix"
        level: "ignore"
      no_implicit_parens:
        level: "ignore"

    Object.merge(coffeelint, overrides) if overrides

module.exports = {
  applyAndValidateDefaults: (new MimosaDefaults()).applyAndValidateDefaults
  defaultJavascript: MimosaDefaults.defaultJavascript()
  defaultCss:        MimosaDefaults.defaultCss()
  defaultTemplate:   MimosaDefaults.defaultTemplate()
}