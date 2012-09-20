AbstractCompiler = require '../compiler'
logger = require '../../../util/logger'

module.exports = class AbstractJavaScriptCompiler extends AbstractCompiler
  outExtension: 'js'
  javascript:true

  constructor: (config) ->
    super(config)
    @notifyOnSuccess = config.growl.onSuccess.javascript

  postInitialization: ->
    @requireRegister?.startupDone()