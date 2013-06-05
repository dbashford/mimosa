var Ember = {
  assert: function() {},
  Handlebars: {
    precompile: function() {}
  }
};

// Eliminate dependency on any Ember to simplify precompilation workflow
var objectCreate = Object.create || function(parent) {
  function F() {}
  F.prototype = parent;
  return new F();
};

var makeHandlebars = function (hbs) {
  var Handlebars = hbs;

  Ember.Handlebars = objectCreate(Handlebars);

  function makeBindings(options) {
    var hash = options.hash,
        hashType = options.hashTypes;

    for (var prop in hash) {
      if (hashType[prop] === 'ID') {
        hash[prop + 'Binding'] = hash[prop];
        hashType[prop + 'Binding'] = 'STRING';
        delete hash[prop];
        delete hashType[prop];
      }
    }
  }

  Ember.Handlebars.helper = function(name, value) {
    if (Ember.View.detect(value)) {
      Ember.Handlebars.registerHelper(name, function(options) {
        Ember.assert("You can only pass attributes as parameters (not values) to a application-defined helper", arguments.length < 2);
        makeBindings(options);
        return Ember.Handlebars.helpers.view.call(this, value, options);
      });
    } else {
      Ember.Handlebars.registerBoundHelper.apply(null, arguments);
    }
  }

  Ember.Handlebars.helpers = objectCreate(Handlebars.helpers);
  Ember.Handlebars.Compiler = function() {};

  // Handlebars.Compiler doesn't exist in runtime-only
  if (Handlebars.Compiler) {
    Ember.Handlebars.Compiler.prototype = objectCreate(Handlebars.Compiler.prototype);
  }

  Ember.Handlebars.Compiler.prototype.compiler = Ember.Handlebars.Compiler;
  Ember.Handlebars.JavaScriptCompiler = function() {};

  // Handlebars.JavaScriptCompiler doesn't exist in runtime-only
  if (Handlebars.JavaScriptCompiler) {
    Ember.Handlebars.JavaScriptCompiler.prototype = objectCreate(Handlebars.JavaScriptCompiler.prototype);
    Ember.Handlebars.JavaScriptCompiler.prototype.compiler = Ember.Handlebars.JavaScriptCompiler;
  }

  Ember.Handlebars.JavaScriptCompiler.prototype.namespace = "Ember.Handlebars";
  Ember.Handlebars.JavaScriptCompiler.prototype.initializeBuffer = function() {
    return "''";
  };

  Ember.Handlebars.JavaScriptCompiler.prototype.appendToBuffer = function(string) {
    return "data.buffer.push("+string+");";
  };

  var prefix = "ember" + (+new Date()), incr = 1;

  Ember.Handlebars.Compiler.prototype.mustache = function(mustache) {
    if (mustache.isHelper && mustache.id.string === 'control') {
      mustache.hash = mustache.hash || new Handlebars.AST.HashNode([]);
      mustache.hash.pairs.push(["controlID", new Handlebars.AST.StringNode(prefix + incr++)]);
    } else if (mustache.params.length || mustache.hash) {
      // no changes required
    } else {
      var id = new Handlebars.AST.IdNode(['_triageMustache']);
      if(!mustache.escaped) {
        mustache.hash = mustache.hash || new Handlebars.AST.HashNode([]);
        mustache.hash.pairs.push(["unescaped", new Handlebars.AST.StringNode("true")]);
      }
      mustache = new Handlebars.AST.MustacheNode([id].concat([mustache.id]), mustache.hash, !mustache.escaped);
    }

    return Handlebars.Compiler.prototype.mustache.call(this, mustache);
  };

  Ember.Handlebars.precompile = function(string) {
    var ast = Handlebars.parse(string);

    var options = {
      knownHelpers: {
        action: true,
        unbound: true,
        bindAttr: true,
        template: true,
        view: true,
        _triageMustache: true
      },
      data: true,
      stringParams: true
    };

    var environment = new Ember.Handlebars.Compiler().compile(ast, options);
    return new Ember.Handlebars.JavaScriptCompiler().compile(environment, options, undefined, true);
  };

  // We don't support this for Handlebars runtime-only
  if (Handlebars.compile) {

    Ember.Handlebars.compile = function(string) {
      var ast = Handlebars.parse(string);
      var options = { data: true, stringParams: true };
      var environment = new Ember.Handlebars.Compiler().compile(ast, options);
      var templateSpec = new Ember.Handlebars.JavaScriptCompiler().compile(environment, options, undefined, true);

      return Ember.Handlebars.template(templateSpec);
    };
  }

  return Ember.Handlebars;
}

exports.makeHandlebars = makeHandlebars;
