"use strict";
/*
Meaty bits yanked from: https://github.com/eknkc/typescript-require/
With a tip of the hat to: https://github.com/joshheyse/typescript-brunch/
*/

var TypeScript, compilationSettings, defaultLibPath, fs, init, io, logger, mimosaConfig, path, __setupTypeScript, _compile;

fs = require("fs");

path = require("path");

logger = require("logmimosa");

io = null;

TypeScript = null;

compilationSettings = null;

defaultLibPath = null;

mimosaConfig = {};

__setupTypeScript = function() {
  var _ref;
  io = require("./resources/io");
  TypeScript = require("./resources/typescript");
  defaultLibPath = path.join(__dirname, "resources", "lib.d.ts");
  compilationSettings = new TypeScript.CompilationSettings();
  compilationSettings.codeGenTarget = TypeScript.CodeGenTarget.ES5;
  compilationSettings.errorRecovery = true;
  if (((_ref = mimosaConfig.typescript) != null ? _ref.module : void 0) != null) {
    if (mimosaConfig.typescript.module === "commonjs") {
      return TypeScript.moduleGenTarget = TypeScript.ModuleGenTarget.Synchronous;
    } else if (mimosaConfig.typescript.module === "amd") {
      return TypeScript.moduleGenTarget = TypeScript.ModuleGenTarget.Asynchronous;
    }
  }
};

init = function(conf) {
  return mimosaConfig = conf;
};

_compile = function(file, cb) {
  var code, compiler, depScriptWriter, emitterIOHost, err, error, errorMessage, mapInputToOutput, outText, preEnv, resolutionDispatcher, resolvedEnv, resolvedPaths, resolver, stderr, targetJsFile, targetScriptAssembler, _i, _j, _len, _len1, _ref, _ref1;
  if (!TypeScript) {
    __setupTypeScript();
  }
  targetJsFile = file.outputFileName.replace(mimosaConfig.watch.compiledDir, mimosaConfig.watch.sourceDir);
  targetJsFile = io.resolvePath(targetJsFile);
  targetJsFile = TypeScript.switchToForwardSlashes(targetJsFile);
  outText = "";
  targetScriptAssembler = {
    Write: function(str) {
      return outText += str;
    },
    WriteLine: function(str) {
      return outText += str + '\r\n';
    },
    Close: function() {}
  };
  depScriptWriter = {
    Write: function(str) {},
    WriteLine: function(str) {},
    Close: function() {}
  };
  errorMessage = "";
  stderr = {
    Write: function(str) {
      return errorMessage += str;
    },
    WriteLine: function(str) {
      return errorMessage += str + '\r\n';
    },
    Close: function() {}
  };
  emitterIOHost = {
    createFile: function(fileName, useUTF8) {
      if (fileName === targetJsFile) {
        return targetScriptAssembler;
      } else {
        return depScriptWriter;
      }
    },
    directoryExists: io.directoryExists,
    fileExists: io.fileExists,
    resolvePath: io.resolvePath
  };
  preEnv = new TypeScript.CompilationEnvironment(compilationSettings, io);
  resolver = new TypeScript.CodeResolver(preEnv);
  resolvedEnv = new TypeScript.CompilationEnvironment(compilationSettings, io);
  compiler = new TypeScript.TypeScriptCompiler(stderr, new TypeScript.NullLogger(), compilationSettings);
  compiler.setErrorOutput(stderr);
  if (compilationSettings.errorRecovery) {
    compiler.parser.setErrorRecovery(stderr);
  }
  code = new TypeScript.SourceUnit(defaultLibPath, null);
  preEnv.code.push(code);
  code = new TypeScript.SourceUnit(file.inputFileName, null);
  preEnv.code.push(code);
  resolvedPaths = {};
  resolutionDispatcher = {
    postResolutionError: function(errorFile, line, col, errorMessage) {
      var _ref;
      return stderr.WriteLine(("" + errorFile + " (" + line + ", " + col + ") ") + ((_ref = errorMessage === "") != null ? _ref : {
        "": ": " + errorMessage
      }));
    },
    postResolution: function(path, code) {
      if (!resolvedPaths[path]) {
        resolvedEnv.code.push(code);
        return resolvedPaths[path] = true;
      }
    }
  };
  _ref = preEnv.code;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    code = _ref[_i];
    path = TypeScript.switchToForwardSlashes(io.resolvePath(code.path));
    resolver.resolveCode(path, "", false, resolutionDispatcher);
  }
  _ref1 = resolvedEnv.code;
  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
    code = _ref1[_j];
    if (code.content !== null) {
      compiler.addUnit(code.content, code.path, false, code.referencedFiles);
    }
  }
  try {
    compiler.typeCheck();
    mapInputToOutput = function(unitIndex, outFile) {
      return preEnv.inputOutputMap[unitIndex] = outFile;
    };
    compiler.emit(emitterIOHost, mapInputToOutput);
  } catch (_error) {
    err = _error;
    compiler.errorReporter.hasErrors = true;
  }
  error = errorMessage.length > 0 ? new Error(errorMessage) : null;
  if (/.d.ts$/.test(file.inputFileName) && outText === "") {
    outText = void 0;
    if (!error) {
      logger.success("Compiled [[ " + file.inputFileName + " ]]");
    }
  }
  return cb(error, outText);
};

module.exports = {
  base: "typescript",
  type: "javascript",
  defaultExtensions: ["ts"],
  init: init,
  compile: _compile
};
