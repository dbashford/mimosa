AbstractSingleFileCompiler = require '../single-file'
logger = require '../../util/logger'
Linter = require '../../util/lint/js'

RequireVerify = require '../../util/require/verify'

module.exports = class AbstractJavaScriptCompiler extends AbstractSingleFileCompiler
  outExtension: 'js'

  constructor: (config) ->
    super(config, config.compilers.javascript)

    @notifyOnSuccess = config.growl.onSuccess.javascript

    if config.lint.compiled.javascript
      @linter = new Linter(config.lint.rules.javascript)

    if config.require.verify.enabled
      @requireVerifier = new RequireVerify(config)

  removed: (fileName) ->
    super(fileName)
    @requireVerifier?.remove(fileName)

  afterCompile: (destFileName, source) =>
    @linter?.lint(destFileName, source)
    @requireVerifier?.process(destFileName, source)
    source

  afterWrite: (fileName) ->
    @optimize()

  postInitialization: ->
    @requireVerifier?.startupDone()



