AbstractJavascriptCompiler = require './javascript'
logger = require '../../util/logger'

module.exports = class AbstractCoffeeScriptCompiler extends AbstractJavascriptCompiler

  constructor: (config) ->
    super(config)

