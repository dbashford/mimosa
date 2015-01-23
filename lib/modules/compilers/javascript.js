"use strict";
var JSCompiler, logger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

logger = require('logmimosa');

module.exports = JSCompiler = (function() {
  function JSCompiler(config, compiler) {
    this.compiler = compiler;
    this._compile = __bind(this._compile, this);
  }

  JSCompiler.prototype.registration = function(config, register) {
    var exts;
    exts = this.compiler.extensions(config);
    register(['add', 'update', 'remove', 'cleanFile', 'buildFile'], 'init', this._determineOutputFile, exts);
    return register(['add', 'update', 'buildFile'], 'compile', this._compile, exts);
  };

  JSCompiler.prototype._determineOutputFile = function(config, options, next) {
    if (options.files && options.files.length) {
      options.destinationFile = function(fileName) {
        var baseCompDir;
        baseCompDir = fileName.replace(config.watch.sourceDir, config.watch.compiledDir);
        return baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".js";
      };
      options.files.forEach(function(file) {
        return file.outputFileName = options.destinationFile(file.inputFileName);
      });
    }
    return next();
  };

  JSCompiler.prototype.__sourceMap = function(file, output, sourceMap) {
    var base64SourceMap, datauri;
    if (output.indexOf("sourceMappingURL=") > -1) {
      return output;
    }
    if (typeof sourceMap === "string") {
      sourceMap = JSON.parse(sourceMap);
    }
    if (!sourceMap.sources) {
      sourceMap.sources = [];
    }
    sourceMap.sources[0] = file.inputFileName;
    sourceMap.sourcesContent = [file.inputFileText];
    sourceMap.file = file.outputFileName;
    base64SourceMap = new Buffer(JSON.stringify(sourceMap)).toString('base64');
    datauri = 'data:application/json;base64,' + base64SourceMap;
    output = "" + output + "\n//# sourceMappingURL=" + datauri + "\n";
    return output;
  };

  JSCompiler.prototype._compile = function(config, options, next) {
    var _ref,
      _this = this;
    if (!((_ref = options.files) != null ? _ref.length : void 0)) {
      return next();
    }
    return options.files.forEach(function(file, i) {
      if (logger.isDebug()) {
        logger.debug("Calling compiler function for compiler [[ " + _this.compiler.name + " ]]");
      }
      file.isVendor = options.isVendor;
      return _this.compiler.compile(config, file, function(err, output, compilerConfig, sourceMap) {
        if (err) {
          logger.error("File [[ " + file.inputFileName + " ]] failed compile. Reason: " + err, {
            exitIfBuild: true
          });
        } else {
          if (sourceMap) {
            output = _this.__sourceMap(file, output, sourceMap);
          }
          file.outputFileText = output;
        }
        if (i === options.files.length - 1) {
          return next();
        }
      });
    });
  };

  return JSCompiler;

})();
