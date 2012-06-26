path = require 'path'
logger =   require './logger'

class MimosaDefaults

  fatalErrors: 0

  applyAndValidateDefaults: (config, callback) =>
    config = @_applyDefaults(config)
    @_validateDefaults(config)
    err = if @fatalErrors is 0 then null else @fatalErrors
    callback(err, config)

  _applyDefaults: (config) ->
    newConfig = {}
    newConfig.watch = config.watch ?= {}
    newConfig.watch.sourceDir = config.watch.sourceDir ?= "assets"
    newConfig.watch.compiledDir = config.watch.compiledDir ?= "public"
    newConfig.watch.ignored = config.watch.ignored ?= [".sass-cache"]

    comp = newConfig.compilers = config.compilers ?= {}
    js = comp.javascript = config.compilers.javascript ?= {}
    js.directory =         config.compilers.javascript.directory         ?= "javascripts"
    js.compileWith =       config.compilers.javascript.compileWith       ?= "coffee"
    js.extensions =        config.compilers.javascript.extensions        ?= ["coffee"]
    js.notifyOnSuccess =   config.compilers.javascript.notifyOnSuccess   ?= true
    js.lint =              config.compilers.javascript.lint              ?= true
    js.metalint =          config.compilers.javascript.metalint          ?= true

    template = comp.template = config.compilers.template                 ?= {}
    template.compileWith =     config.compilers.template.compileWith     ?= "handlebars"
    template.extensions =      config.compilers.template.extensions      ?= ["hbs", "handlebars"]
    template.outputFileName =  config.compilers.template.outputFileName  ?= "javascripts/templates"
    template.defineLocation =  config.compilers.template.defineLocation  ?= "vendor/handlebars"
    template.helperFile =      config.compilers.template.helperFile      ?= "javascripts/handlebars-helpers"
    template.notifyOnSuccess = config.compilers.template.notifyOnSuccess ?= true

    css = comp.css =      config.compilers.css                 ?= {}
    css.compileWith =     config.compilers.css.compileWith     ?= "sass"
    css.extensions =      config.compilers.css.extensions      ?= ["scss", "sass"]
    css.hasCompass =      config.compilers.css.hasCompass      ?= true
    css.notifyOnSuccess = config.compilers.css.notifyOnSuccess ?= true

    copy = newConfig.copy = config.copy                        ?= {}
    copy.extensions =       config.copy.extensions             ?= ["js","css","png","jpg","jpeg","gif"]
    copy.notifyOnSuccess =  config.copy.notifyOnSuccess        ?= false

    server = newConfig.server = config.server                  ?= {}
    server.useDefaultServer =   config.server.useDefaultServer ?= false
    server.path =               config.server.path             ?= 'server.coffee'
    server.port =               config.server.port             ?= 3000
    server.base =               config.server.base             ?= '/app'
    server.useReload =          config.server.useReload        ?= true

    requirejs = newConfig.require = config.require              ?= {}
    requirejs.name =                config.require.name         ?= "main"
    requirejs.out  =                config.require.out          ?= "main-built.js"
    requirejs.paths =               config.require.paths        ?= {}
    requirejs.paths.jquery =        config.require.paths.jquery ?= "vendor/jquery"

    newConfig.coffeelint = @coffeelint(config.coffeelint)

    newConfig

  _validateDefaults: (config) ->
    @_testPathExists(config.watch.sourceDir, "watch.sourceDir")
    @_testPathExists(config.watch.compiledDir, "watch.compiledDir")
    @_testPathExists(config.server.path,          "server.path ") unless config.server.useDefaultServer

    comp = config.compilers
    templatePath = path.join(__dirname, '..', 'compilers/template', "#{comp.template.compileWith}.coffee")
    jsPath = path.join(__dirname, '..', 'compilers/javascript', "#{comp.javascript.compileWith}.coffee")
    cssPath = path.join(__dirname, '..', 'compilers/css', "#{comp.css.compileWith}.coffee")

    @_testPathExists(templatePath, "compilers.template.compileWith") unless comp.template.compileWith is "none"
    @_testPathExists(jsPath,       "compilers.javascript.compileWith") unless comp.javascript.compileWith is "none"
    @_testPathExists(cssPath,      "compilers.css.compileWith") unless comp.css.compileWith is "none"

  _testPathExists: (filePath, name) ->
    rPath = path.resolve filePath
    rPathExists = path.existsSync rPath
    unless rPathExists
      logger.fatal "#{name} (#{rPath}) cannot be found"
      @fatalErrors++

  coffeelint: (overrides) ->
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

module.exports = (new MimosaDefaults()).applyAndValidateDefaults