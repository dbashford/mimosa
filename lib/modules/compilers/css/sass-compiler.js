"use strict";
var AbstractCssCompiler, SassCompiler, exec, fs, logger, path, spawn, _, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

fs = require('fs');

path = require('path');

_ref = require('child_process'), spawn = _ref.spawn, exec = _ref.exec;

_ = require('lodash');

logger = require('logmimosa');

AbstractCssCompiler = require('./css');

module.exports = SassCompiler = (function(_super) {
  __extends(SassCompiler, _super);

  SassCompiler.prototype.libName = 'node-sass';

  SassCompiler.prototype.importRegex = /@import ['"](.*)['"]/g;

  SassCompiler.prettyName = "SASS - http://sass-lang.com/";

  SassCompiler.defaultExtensions = ["scss", "sass"];

  function SassCompiler(config, extensions) {
    this.extensions = extensions;
    this._determineBaseFiles = __bind(this._determineBaseFiles, this);
    this._compileRuby = __bind(this._compileRuby, this);
    this._compileNode = __bind(this._compileNode, this);
    this._preCompileRubySASS = __bind(this._preCompileRubySASS, this);
    this.compile = __bind(this.compile, this);
    SassCompiler.__super__.constructor.call(this);
    if (!config.compilers.libs.sass) {
      this._doRubySASSChecking();
    }
  }

  SassCompiler.prototype.compile = function(file, config, options, done) {
    if (config.compilers.libs.sass) {
      return this._compileNode(file, config, options, done);
    } else {
      return this._preCompileRubySASS(file, config, options, done);
    }
  };

  SassCompiler.prototype._doRubySASSChecking = function() {
    var _this = this;
    logger.debug("Checking if Compass/SASS is available");
    exec('compass --version', function(error, stdout, stderr) {
      return _this.hasCompass = !error;
    });
    this.runSass = 'sass';
    if (process.platform === 'win32') {
      this.runSass = 'sass.bat';
    }
    return exec("" + this.runSass + " --version", function(error, stdout, stderr) {
      return _this.hasSASS = !error;
    });
  };

  SassCompiler.prototype._preCompileRubySASS = function(file, config, options, done) {
    var compileOnDelay, msg,
      _this = this;
    if ((this.hasCompass != null) && (this.hasSASS != null) && this.hasSASS) {
      return this._compileRuby(file, config, options, done);
    }
    if ((this.hasSASS != null) && !this.hasSASS) {
      msg = "You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or\nprovide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.";
      return done(msg, '');
    }
    compileOnDelay = function() {
      if ((_this.hasCompass != null) && (_this.hasSASS != null)) {
        if (_this.hasSASS) {
          return _this._compileRuby(file, config, options, done);
        } else {
          msg = "You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or\nprovide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.";
          return done(msg, '');
        }
      } else {
        return setTimeout(compileOnDelay, 100);
      }
    };
    return compileOnDelay();
  };

  SassCompiler.prototype.__isInclude = function(fileName) {
    return (this.includeToBaseHash[fileName] != null) || path.basename(fileName).charAt(0) === '_';
  };

  SassCompiler.prototype._compileNode = function(file, config, options, done) {
    var finished,
      _this = this;
    logger.debug("Beginning node compile of SASS file [[ " + file.inputFileName + " ]]");
    finished = function(error, text) {
      logger.debug("Finished node compile for file [[ " + file.inputFileName + " ]], errors? " + (error != null));
      return done(error, text);
    };
    return this.compilerLib.render({
      data: file.inputFileText,
      includePaths: [config.watch.sourceDir, path.dirname(file.inputFileName)],
      success: function(css) {
        return finished(null, css);
      },
      error: function(error) {
        return finished(error, '');
      }
    });
  };

  SassCompiler.prototype._compileRuby = function(file, config, options, done) {
    var compilerOptions, error, fileName, result, sass, text,
      _this = this;
    text = file.inputFileText;
    fileName = file.inputFileName;
    logger.debug("Beginning Ruby compile of SASS file [[ " + fileName + " ]]");
    result = '';
    error = null;
    compilerOptions = ['--stdin', '--load-path', config.watch.sourceDir, '--load-path', path.dirname(fileName), '--no-cache'];
    if (this.hasCompass) {
      compilerOptions.push('--compass');
    }
    if (/\.scss$/.test(fileName)) {
      compilerOptions.push('--scss');
    }
    sass = spawn(this.runSass, compilerOptions);
    sass.stdin.end(text);
    sass.stdout.on('data', function(buffer) {
      return result += buffer.toString();
    });
    sass.stderr.on('data', function(buffer) {
      if (error == null) {
        error = '';
      }
      return error += buffer.toString();
    });
    return sass.on('exit', function(code) {
      logger.debug("Finished Ruby SASS compile for file [[ " + fileName + " ]], errors? " + (error != null));
      return done(error, result);
    });
  };

  SassCompiler.prototype._determineBaseFiles = function(allFiles) {
    var baseFiles,
      _this = this;
    baseFiles = allFiles.filter(function(file) {
      return (!_this.__isInclude(file)) && file.indexOf('compass') < 0;
    });
    if (logger.isDebug) {
      logger.debug("Base files for SASS are:\n" + (baseFiles.join('\n')));
    }
    return baseFiles;
  };

  SassCompiler.prototype._getImportFilePath = function(baseFile, importPath) {
    return path.join(path.dirname(baseFile), importPath.replace(/(\w+\.|[\w-]+$)/, '_$1'));
  };

  return SassCompiler;

})(AbstractCssCompiler);
