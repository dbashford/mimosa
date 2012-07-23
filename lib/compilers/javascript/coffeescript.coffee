AbstractJavascriptCompiler = require './javascript'
logger = require '../../util/logger'
Linter = require '../../util/lint/coffee'

module.exports = class AbstractCoffeeScriptCompiler extends AbstractJavascriptCompiler

  constructor: (config) ->
    super(config)

    if config.lint.compiled.coffee
      @coffeeLinter = new Linter(config.lint.rules.coffee)

  beforeCompile: (fileName, source) ->
    @coffeeLinter.lint(fileName, source) if @coffeeLinter?

