AbstractSingleFileCompiler = require '../single-file-compiler'

module.exports = class AbstractJavaScriptCompiler extends AbstractSingleFileCompiler
  outExtension: 'js'

  constructor: (config) -> super(config, config.compilers.javascript)
