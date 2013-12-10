"use strict";
var compile, compilerLib, determineBaseFiles, exec, fs, getImportFilePath, hasCompass, hasSASS, importRegex, init, isInclude, logger, path, runSass, setCompilerLib, spawn, _, __compileNode, __compileRuby, __doRubySASSChecking, __preCompileRubySASS, _ref;

fs = require('fs');

path = require('path');

_ref = require('child_process'), spawn = _ref.spawn, exec = _ref.exec;

_ = require('lodash');

logger = require('logmimosa');

importRegex = /@import ['"](.*)['"]/g;

runSass = 'sass';

hasSASS = void 0;

hasCompass = void 0;

compilerLib = null;

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

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
  if (hasCompass !== void 0 && hasSASS !== void 0 && hasSASS) {
    return __compileRuby(file, config, options, done);
  }
  if (hasSASS !== void 0 && !hasSASS) {
    msg = "You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or\nprovide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.";
    return done(msg, '');
  }
  compileOnDelay = function() {
    if (hasCompass !== void 0 && hasSASS !== void 0) {
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
  return compilerLib.render({
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

init = function(config) {
  if (!config.compilers.libs.sass) {
    return __doRubySASSChecking();
  }
};

compile = function(file, config, options, done) {
  if (config.compilers.libs.sass) {
    return __compileNode(file, config, options, done);
  } else {
    return __preCompileRubySASS(file, config, options, done);
  }
};

isInclude = function(fileName, includeToBaseHash) {
  return (includeToBaseHash[fileName] != null) || path.basename(fileName).charAt(0) === '_';
};

getImportFilePath = function(baseFile, importPath) {
  return path.join(path.dirname(baseFile), importPath.replace(/(\w+\.|[\w-]+$)/, '_$1'));
};

determineBaseFiles = function(allFiles) {
  var baseFiles;
  baseFiles = allFiles.filter(function(file) {
    return (!isInclude(file, {})) && file.indexOf('compass') < 0;
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
  importRegex: importRegex,
  init: init,
  compile: compile,
  isInclude: isInclude,
  getImportFilePath: getImportFilePath,
  determineBaseFiles: determineBaseFiles,
  setCompilerLib: setCompilerLib
};
