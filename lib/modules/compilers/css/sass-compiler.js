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
  var runSass;

  __extends(SassCompiler, _super);

  SassCompiler.prototype.importRegex = /@import ['"](.*)['"]/g;

  SassCompiler.prettyName = "SASS - http://sass-lang.com/";

  SassCompiler.defaultExtensions = ["scss", "sass"];

  SassCompiler.checkIfExists = function(callback) {
    logger.debug("Checking if SASS is available");
    return exec("" + runSass + " --version", function(error, stdout, stderr) {
      logger.debug("SASS available error: " + error);
      logger.debug("SASS available stderr: " + stderr);
      logger.debug("SASS available stdout: " + stdout);
      return callback(error ? false : true);
    });
  };

  runSass = 'sass';

  if (process.platform === 'win32') {
    runSass = 'sass.bat';
    logger.debug("win32 detected, changing sass command to " + runSass);
  }

  function SassCompiler(config, extensions) {
    var _this = this;

    this.extensions = extensions;
    this._determineBaseFiles = __bind(this._determineBaseFiles, this);
    this.__compile = __bind(this.__compile, this);
    this.compile = __bind(this.compile, this);
    SassCompiler.__super__.constructor.call(this);
    SassCompiler.checkIfExists(function(exists) {
      return _this.hasSASS = exists;
    });
    logger.debug("Checking if Compass is available");
    exec('compass --version', function(error, stdout, stderr) {
      _this.hasCompass = !error;
      return logger.debug("Compass available? " + _this.hasCompass);
    });
  }

  SassCompiler.prototype.compile = function(file, config, options, done) {
    var compileOnDelay,
      _this = this;

    if (this.hasCompass && (this.hasSASS != null) && this.hasSASS) {
      if ((this.hasCompass != null) && (this.hasSASS != null)) {
        return this.__compile(file, config, options, done);
      }
    }
    if ((this.hasSASS != null) && !this.hasSASS) {
      return this._noSASS();
    }
    compileOnDelay = function() {
      if ((_this.hasCompass != null) && (_this.hasSASS != null)) {
        if (!_this.hasSASS) {
          return _this._noSASS();
        }
        return _this.__compile(file, config, options, done);
      } else {
        return setTimeout(compileOnDelay, 100);
      }
    };
    return compileOnDelay();
  };

  SassCompiler.prototype.__isInclude = function(fileName) {
    return (this.includeToBaseHash[fileName] != null) || path.basename(fileName).charAt(0) === '_';
  };

  SassCompiler.prototype.__compile = function(file, config, options, done) {
    var compilerOptions, error, fileName, result, sass, text,
      _this = this;

    text = file.inputFileText;
    fileName = file.inputFileName;
    logger.debug("Beginning compile of SASS file [[ " + fileName + " ]]");
    result = '';
    error = null;
    compilerOptions = ['--stdin', '--load-path', config.watch.sourceDir, '--load-path', path.dirname(fileName), '--no-cache'];
    if (this.hasCompass) {
      compilerOptions.push('--compass');
    }
    if (/\.scss$/.test(fileName)) {
      compilerOptions.push('--scss');
    }
    sass = spawn(runSass, compilerOptions);
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
      logger.debug("Finished SASS compile for file [[ " + fileName + " ]], errors? " + (error != null));
      _this.initBaseFilesToCompile--;
      return done(error, result);
    });
  };

  SassCompiler.prototype._determineBaseFiles = function() {
    var baseFiles,
      _this = this;

    baseFiles = this.allFiles.filter(function(file) {
      return (!_this.__isInclude(file)) && file.indexOf('compass') < 0;
    });
    logger.debug("Base files for SASS are:\n" + (baseFiles.join('\n')));
    return baseFiles;
  };

  SassCompiler.prototype._getImportFilePath = function(baseFile, importPath) {
    return path.join(path.dirname(baseFile), importPath.replace(/(\w+\.|[\w-]+$)/, '_$1'));
  };

  SassCompiler.prototype._noSASS = function() {
    return logger.error("You have SASS code and Mimosa is attempting to compile it, but you don't seem to have SASS installed. " + "SASS is a Ruby gem, information can be found here: http://sass-lang.com/tutorial.html. " + "SASS can be installed by executing this command: gem install sass.  After installing SASS " + "you will need to restart Mimosa.");
  };

  return SassCompiler;

})(AbstractCssCompiler);
