"use strict";
var CSSCompiler, JavaScriptCompiler, MiscCompiler, TemplateCompiler, fs, logger, path, templateLibrariesBeingUsed, _, _testDifferentTemplateLibraries;

path = require('path');

fs = require('fs');

_ = require('lodash');

logger = require('logmimosa');

JavaScriptCompiler = require("./javascript");

CSSCompiler = require("./css");

TemplateCompiler = require("./template");

MiscCompiler = require("./misc");

templateLibrariesBeingUsed = 0;

exports.compilers = [];

_testDifferentTemplateLibraries = function(config, options, next) {
  var hasFiles, _ref;
  hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
  if (!hasFiles) {
    return next();
  }
  if (typeof config.template.outputFileName !== "string") {
    return next();
  }
  if (++templateLibrariesBeingUsed === 2) {
    logger.error("More than one template library is being used, but multiple template.outputFileName entries not found." + " You will want to configure a map of template.outputFileName entries in your config, otherwise you will only get" + " template output for one of the libraries.");
  }
  return next();
};

exports.setupCompilers = function(config) {
  var backloadCompilers, compiler, copyMisc, extensions, exts, mod, modName, type, _i, _len, _ref, _ref1, _ref2, _ref3;
  if (exports.compilers.length) {
    exports.compilers = [];
  }
  _ref = config.installedModules;
  for (modName in _ref) {
    mod = _ref[modName];
    if (mod.compilerType) {
      if (logger.isDebug()) {
        logger.debug("Found compiler [[ " + mod.name + " ]], adding to array of compilers");
      }
      exports.compilers.push(mod);
    }
  }
  _ref1 = exports.compilers;
  for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
    compiler = _ref1[_i];
    exts = compiler.extensions(config);
    (_ref2 = config.extensions[compiler.compilerType]).push.apply(_ref2, exts);
  }
  _ref3 = config.extensions;
  for (type in _ref3) {
    extensions = _ref3[type];
    config.extensions[type] = _.uniq(extensions);
  }
  if (config.resortCompilers) {
    backloadCompilers = ["copy", "misc"];
    copyMisc = _.remove(exports.compilers, function(comp) {
      return backloadCompilers.indexOf(comp.compilerType) > -1;
    });
    return exports.compilers = exports.compilers.concat(copyMisc);
  }
};

exports.registration = function(config, register) {
  var CompilerClass, compiler, compilerInstance, _i, _len, _ref;
  _ref = exports.compilers;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    compiler = _ref[_i];
    if (logger.isDebug()) {
      logger.debug("Creating compiler " + compiler.name);
    }
    CompilerClass = (function() {
      switch (compiler.compilerType) {
        case "copy":
          return MiscCompiler;
        case "misc":
          return MiscCompiler;
        case "javascript":
          return JavaScriptCompiler;
        case "template":
          return TemplateCompiler;
        case "css":
          return CSSCompiler;
      }
    })();
    compilerInstance = new CompilerClass(config, compiler);
    compilerInstance.name = compiler.name;
    compilerInstance.registration(config, register);
    if (compiler.registration) {
      compiler.registration(config, register);
    }
    if (logger.isDebug()) {
      logger.debug("Done with compiler " + compiler.name);
    }
  }
  if (config.template) {
    return register(['buildExtension'], 'complete', _testDifferentTemplateLibraries, config.extensions.template);
  }
};

exports.defaults = function() {
  return {
    resortCompilers: true,
    template: {
      writeLibrary: true,
      wrapType: "amd",
      commonLibPath: null,
      nameTransform: "fileName",
      outputFileName: "javascripts/templates"
    }
  };
};

exports.validate = function(config, validators) {
  var errors, fName, fileNames, folder, newFolders, outputConfig, tComp, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
  errors = [];
  validators.ifExistsIsBoolean(errors, "resortCompilers", config.resortCompilers);
  if (validators.ifExistsIsObject(errors, "template config", config.template)) {
    validators.ifExistsIsBoolean(errors, "template.writeLibrary", config.template.writeLibrary);
    if (config.template.output && config.template.outputFileName) {
      delete config.template.outputFileName;
    }
    if (validators.ifExistsIsString(errors, "template.wrapType", config.template.wrapType)) {
      if (["common", "amd", "none"].indexOf(config.template.wrapType) === -1) {
        errors.push("template.wrapType must be one of: 'common', 'amd', 'none'");
      }
    }
    if (config.template.nameTransform != null) {
      if (typeof config.template.nameTransform === "string") {
        if (["fileName", "filePath"].indexOf(config.template.nameTransform) === -1) {
          errors.push("config.template.nameTransform valid string values are filePath or fileName");
        }
      } else if (typeof config.template.nameTransform === "function" || config.template.nameTransform instanceof RegExp) {

      } else {
        errors.push("config.template.nameTransform property must be a string, regex or function");
      }
    }
    if (config.template.outputFileName) {
      config.template.output = [
        {
          folders: [""],
          outputFileName: config.template.outputFileName
        }
      ];
    }
    if (validators.ifExistsIsArrayOfObjects(errors, "template.output", config.template.output)) {
      fileNames = [];
      _ref = config.template.output;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        outputConfig = _ref[_i];
        if (validators.isArrayOfStringsMustExist(errors, "template.output.folders", outputConfig.folders)) {
          if (outputConfig.folders.length === 0) {
            errors.push("template.output.folders must have at least one entry");
          } else {
            newFolders = [];
            _ref1 = outputConfig.folders;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              folder = _ref1[_j];
              folder = path.join(config.watch.sourceDir, folder);
              if (!fs.existsSync(folder)) {
                errors.push("template.output.folders must exist, folder resolved to [[ " + folder + " ]]");
              }
              newFolders.push(folder);
            }
            outputConfig.folders = newFolders;
          }
        }
        if (outputConfig.outputFileName) {
          fName = outputConfig.outputFileName;
          if (typeof fName === "string") {
            fileNames.push(fName);
          } else if (typeof fName === "object" && !Array.isArray(fName)) {
            _ref2 = Object.keys(fName);
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              tComp = _ref2[_k];
              fileNames.push(fName[tComp]);
            }
          } else {
            errors.push("template.outputFileName must be an object or a string.");
          }
        } else {
          errors.push("template.output.outputFileName must exist for each entry in array.");
        }
      }
      if (fileNames.length !== _.uniq(fileNames).length) {
        errors.push("template.output.outputFileName names must be unique.");
      }
    }
  }
  return errors;
};
