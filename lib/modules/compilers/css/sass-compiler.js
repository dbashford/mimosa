"use strict";
var exec, fs, hasCompass, hasSASS, logger, path, runSass, spawn, _, __compileNode, __compileRuby, __doRubySASSChecking, __preCompileRubySASS, _compile, _compilerLib, _determineBaseFiles, _getImportFilePath, _importRegex, _init, _isInclude, _ref;

fs = require('fs');

path = require('path');

_ref = require('child_process'), spawn = _ref.spawn, exec = _ref.exec;

_ = require('lodash');

logger = require('logmimosa');

_importRegex = /@import ['"](.*)['"]/g;

runSass = 'sass';

hasSASS = void 0;

hasCompass = void 0;

_compilerLib = null;

__doRubySASSChecking = function() {
  logger.debug("Checking if Compass/SASS is available");
  exec('compass --version', function(error, stdout, stderr) {
    return hasCompass = !error;
  });
  if (process.platform === 'win32') {
    runSass = 'sass.bat';
  }
  return exec("" + runSass + " --version", function(error, stdout, stderr) {
    return hasSASS = !error;
  });
};

__compileRuby = function(file, config, options, done) {
  var compilerOptions, error, fileName, result, sass, text;
  text = file.inputFileText;
  fileName = file.inputFileName;
  logger.debug("Beginning Ruby compile of SASS file [[ " + fileName + " ]]");
  result = '';
  error = null;
  compilerOptions = ['--stdin', '--load-path', config.watch.sourceDir, '--load-path', path.dirname(fileName), '--no-cache'];
  if (hasCompass) {
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
    logger.debug("Finished Ruby SASS compile for file [[ " + fileName + " ]], errors? " + (error != null));
    return done(error, result);
  });
};

__preCompileRubySASS = function(file, config, options, done) {
  var compileOnDelay, msg;
  if (hasCompass && hasSASS) {
    return __compileRuby(file, config, options, done);
  }
  if (hasSASS) {
    msg = "You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or\nprovide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.";
    return done(msg, '');
  }
  compileOnDelay = function() {
    if ((hasCompass != null) && (hasSASS != null)) {
      if (hasSASS) {
        return __compileRuby(file, config, options, done);
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

__compileNode = function(file, config, options, done) {
  var finished;
  logger.debug("Beginning node compile of SASS file [[ " + file.inputFileName + " ]]");
  finished = function(error, text) {
    logger.debug("Finished node compile for file [[ " + file.inputFileName + " ]], errors? " + (error != null));
    return done(error, text);
  };
  return _compilerLib.render({
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

_init = function(config) {
  if (!config.compilers.libs.sass) {
    return __doRubySASSChecking();
  }
};

_compile = function(file, config, options, done) {
  if (config.compilers.libs.sass) {
    return __compileNode(file, config, options, done);
  } else {
    return __preCompileRubySASS(file, config, options, done);
  }
};

_isInclude = function(fileName, includeToBaseHash) {
  return (includeToBaseHash[fileName] != null) || path.basename(fileName).charAt(0) === '_';
};

_getImportFilePath = function(baseFile, importPath) {
  return path.join(path.dirname(baseFile), importPath.replace(/(\w+\.|[\w-]+$)/, '_$1'));
};

_determineBaseFiles = function(allFiles) {
  var baseFiles;
  baseFiles = allFiles.filter(function(file) {
    return (!_isInclude(file)) && file.indexOf('compass') < 0;
  });
  if (logger.isDebug) {
    logger.debug("Base files for SASS are:\n" + (baseFiles.join('\n')));
  }
  return baseFiles;
};

module.exports = {
  base: "sass",
  type: "css",
  defaultExtensions: ["scss", "sass"],
  libName: 'node-sass',
  importRegex: _importRegex,
  init: _init,
  compile: _compile,
  isInclude: _isInclude,
  getImportFilePath: _getImportFilePath,
  determineBaseFiles: _determineBaseFiles,
  compilerLib: _compilerLib
};
