var express = require('express'),
    routes = require('./routes'),
    engines = require('consolidate');

exports.startServer = function(config) {
  var app = express(),
      publicPath = config.watch.compiledDir;

  var server = app.listen(config.server.port, function() {
    console.log("Express server listening on port %d in %s mode", server.address().port, app.settings.env);
  });

  app.get('/', routes.index(config));

  app.configure(function() {
    app.set('port', config.server.port);
    app.set('views', config.server.views.path);
    app.engine(config.server.views.extension, engines[config.server.views.compileWith]);
    app.set('view engine', config.server.views.extension);
    app.use(express.favicon());
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.compress());
    app.use(config.server.base, app.router);
    app.use(express.static(publicPath));
  });

  app.configure('development', function() {
    app.use(express.errorHandler());
  });

  return server;
};

