"use strict";
var beforeRead, clean, del, init, modules, read, write;

init = require('./init');

beforeRead = require('./beforeRead');

read = require('./read');

write = require('./write');

del = require('./delete');

clean = require('./clean');

modules = [init, beforeRead, read, write, del, clean];

exports.registration = function(config, register) {
  return modules.forEach(function(module) {
    return module.registration(config, register);
  });
};
