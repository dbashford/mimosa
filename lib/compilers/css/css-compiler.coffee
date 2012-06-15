SingleFileCompiler = require '../single-file-compiler'

module.exports = class AbstractCSSCompiler extends SingleFileCompiler
  outExtension: "css"

  constructor: (config) -> super(config)