AbstractJavascriptCompiler = require './javascript'
logger = require '../../util/logger'
Linter = require '../../util/lint-js'

module.exports = class AbstractCoffeeScriptCompiler extends AbstractJavascriptCompiler

  constructor: (config) ->
    super(config)

    if config.lint.compiled.coffee
      @linter = new Linter(config.lint.rules.coffee)
      @coffeeRules = config.lint.rules.coffee

  beforeCompile: (source, fileName) ->
    @linter.lintCoffee(source, fileName, @coffeeRules) if @linter?

