"use strict";
var compile, compiler, config, ember, emberBoilerplate, fs, handlebars, init, logger, path, prefix, regularBoilerplate, suffix, __determineHandlebars;

fs = require('fs');

path = require('path');

logger = require('logmimosa');

handlebars = null;

ember = false;

config = {};

compiler = null;

regularBoilerplate = "if (!Handlebars) {\n  console.log(\"Handlebars library has not been passed in successfully\");\n  return;\n}\n\nif (!Object.keys) {\n   Object.keys = function (obj) {\n       var keys = [],\n           k;\n       for (k in obj) {\n           if (Object.prototype.hasOwnProperty.call(obj, k)) {\n               keys.push(k);\n           }\n       }\n       return keys;\n   };\n}\n\nvar template = Handlebars.template, templates = {};\nHandlebars.partials = templates;\n";

emberBoilerplate = "var template = Ember.Handlebars.template, templates = {};\n";

__determineHandlebars = function() {
  var ec, hbs;
  ember = config.template.handlebars.ember.enabled;
  hbs = config.compilers.libs.handlebars ? config.compilers.libs.handlebars : require('handlebars');
  return handlebars = ember ? (ec = require('./resources/ember-comp'), ec.makeHandlebars(hbs)) : hbs;
};

prefix = function(config, libraryPath) {
  var boilerplate, defineString, defines, ext, helperDefine, helperFile, helperPath, helperPaths, jsDir, params, possibleHelperPaths, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
  boilerplate = ember ? emberBoilerplate : regularBoilerplate;
  if (config.template.wrapType === 'amd') {
    logger.debug("Building Handlebars template file wrapper");
    jsDir = path.join(config.watch.sourceDir, config.watch.javascriptDir);
    possibleHelperPaths = [];
    _ref = config.extensions.javascript;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      ext = _ref[_i];
      _ref1 = config.template.handlebars.helpers;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        helperFile = _ref1[_j];
        possibleHelperPaths.push(path.join(jsDir, "" + helperFile + "." + ext));
      }
    }
    helperPaths = possibleHelperPaths.filter(function(p) {
      return fs.existsSync(p);
    });
    _ref2 = ember ? {
      defines: ["'" + config.template.handlebars.ember.path + "'"],
      params: ["Ember"]
    } : {
      defines: ["'" + libraryPath + "'"],
      params: ["Handlebars"]
    }, defines = _ref2.defines, params = _ref2.params;
    for (_k = 0, _len2 = helperPaths.length; _k < _len2; _k++) {
      helperPath = helperPaths[_k];
      helperDefine = helperPath.replace(config.watch.sourceDir, '').replace(/\\/g, '/').replace(/^\/?\w+\/|\.\w+$/g, '');
      defines.push("'" + helperDefine + "'");
    }
    defineString = defines.join(',');
    logger.debug("Define string for Handlebars templates [[ " + defineString + " ]]");
    return "define([" + defineString + "], function (" + (params.join(',')) + "){\n  " + boilerplate;
  } else if (config.template.wrapType === 'common') {
    if (ember) {
      return "var Ember = require('" + config.template.commonLibPath + "');\n" + boilerplate;
    } else {
      return "var Handlebars = require('" + config.template.commonLibPath + "');\n" + boilerplate;
    }
  } else {
    return boilerplate;
  }
};

suffix = function(config) {
  if (config.template.wrapType === 'amd') {
    return 'return templates; });';
  } else if (config.template.wrapType === "common") {
    return "\nmodule.exports = templates;";
  } else {
    return "";
  }
};

init = function(conf) {
  return config = conf;
};

compile = function(file, cb) {
  var err, error, output;
  if (!handlebars) {
    __determineHandlebars();
  }
  try {
    output = handlebars.precompile(file.inputFileText);
    output = "template(" + (output.toString()) + ")";
    if (ember) {
      output = "Ember.TEMPLATES['" + file.templateName + "'] = " + output;
    }
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "handlebars",
  compilerType: "template",
  defaultExtensions: ["hbs", "handlebars"],
  clientLibrary: "handlebars",
  compile: compile,
  init: init,
  suffix: suffix,
  prefix: prefix
};
