class MimosaDefaults

  applyDefaults: (config) ->
    newConfig = {}
    newConfig.watch = config.watch ?= {}
    newConfig.watch.originationDir = config.watch.originationDir ?= "assets"
    newConfig.watch.destinationDir = config.watch.destinationDir ?= "public"
    newConfig.watch.ignored = config.watch.ignored ?= [".sass-cache"]

    comp = newConfig.compilers = config.compilers ?= {}
    js = comp.javascript = config.compilers.javascript ?= {}
    js.compileWith =     config.compilers.javascript.compileWith ?= "coffee"
    js.extensions =      config.compilers.javascript.extensions ?= ["coffee"]
    js.notifyOnSuccess = config.compilers.javascript.notifyOnSuccess ?= true

    template = comp.template = config.compilers.template ?= {}
    template.compileWith = config.compilers.template.compileWith ?= "handlebars"
    template.extensions = config.compilers.template.extensions ?= ["hbs", "handlebars"]
    template.outputFileName = config.compilers.template.outputFileName ?= "javascripts/templates"
    template.defineLocation = config.compilers.template.defineLocation ?= "vendor/handlebars"
    template.helperFile = config.compilers.template.helperFile ?= "javascripts/handlebars-helper"
    template.notifyOnSuccess = config.compilers.template.notifyOnSuccess ?= true

    css = comp.css = config.compilers.css ?= {}
    css.compileWith = config.compilers.css.compileWith ?= "sass"
    css.extensions = config.compilers.css.extensions ?= ["scss", "sass"]
    css.hasCompass = config.compilers.css.hasCompass ?= true
    css.notifyOnSuccess = config.compilers.css.notifyOnSuccess ?= true

    copy = newConfig.copy = config.copy ?= {}
    copy.extensions = config.copy.extensions ?= ["js","css","png","jpg","jpeg","gif"]
    copy.notifyOnSuccess = config.copy.notifyOnSuccess ?= false

    server = newConfig.server = config.server ?= {}
    server.path = config.server.path ?= 'server.coffee'
    server.port = config.server.port ?= 4321
    server.base = config.server.base ?= '/app'

    newConfig

module.exports = (new MimosaDefaults()).applyDefaults