"use strict";
/*
Meaty bits yanked from: https://github.com/eknkc/typescript-require/
With a tip of the hat to: https://github.com/joshheyse/typescript-brunch/
*/

var JSCompiler, TypeScript, TypeScriptCompiler, fs, io, logger, path,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

fs = require("fs");

path = require("path");

logger = require("logmimosa");

io = require("./resources/io");

TypeScript = require("./resources/typescript");

JSCompiler = require("./javascript");

module.exports = TypeScriptCompiler = (function(_super) {
  __extends(TypeScriptCompiler, _super);

  TypeScriptCompiler.prettyName = "TypeScript - http://www.typescriptlang.org";

  TypeScriptCompiler.defaultExtensions = ["ts"];

  function TypeScriptCompiler(config, extensions) {
    var _ref;

    this.config = config;
    this.extensions = extensions;
    TypeScriptCompiler.__super__.constructor.call(this);
    this.defaultLibPath = path.join(__dirname, "resources", "lib.d.ts");
    this.compilationSettings = new TypeScript.CompilationSettings();
    this.compilationSettings.codeGenTarget = TypeScript.CodeGenTarget.ES5;
    this.compilationSettings.errorRecovery = true;
    if (((_ref = this.config.typescript) != null ? _ref.module : void 0) != null) {
      if (this.config.typescript.module === "commonjs") {
        TypeScript.moduleGenTarget = TypeScript.ModuleGenTarget.Synchronous;
      } else if (this.config.typescript.module === "amd") {
        TypeScript.moduleGenTarget = TypeScript.ModuleGenTarget.Asynchronous;
      }
    }
  }

  TypeScriptCompiler.prototype.compile = function(file, cb) {
    var code, compiler, depScriptWriter, emitterIOHost, err, error, errorMessage, mapInputToOutput, outText, preEnv, resolutionDispatcher, resolvedEnv, resolvedPaths, resolver, stderr, targetJsFile, targetScriptAssembler, _i, _j, _len, _len1, _ref, _ref1;

    targetJsFile = file.outputFileName.replace(this.config.watch.compiledDir, this.config.watch.sourceDir);
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
    preEnv = new TypeScript.CompilationEnvironment(this.compilationSettings, io);
    resolver = new TypeScript.CodeResolver(preEnv);
    resolvedEnv = new TypeScript.CompilationEnvironment(this.compilationSettings, io);
    compiler = new TypeScript.TypeScriptCompiler(stderr, new TypeScript.NullLogger(), this.compilationSettings);
    compiler.setErrorOutput(stderr);
    if (this.compilationSettings.errorRecovery) {
      compiler.parser.setErrorRecovery(stderr);
    }
    code = new TypeScript.SourceUnit(this.defaultLibPath, null);
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

  return TypeScriptCompiler;

})(JSCompiler);
