var express = require('express'),
    routes = require('./routes'),
    engines = require('consolidate');

exports.startServer = function(config, callback) {

  var port = process.env.PORT || config.server.port;


  var app = express();
  var server = app.listen(port, function() {
    console.log("Express server listening on port %d in %s mode", server.address().port, app.settings.env);
  });

  app.configure(function() {
    app.set('port', port);
    app.set('views', config.server.views.path);
    app.engine(config.server.views.extension, engines[config.server.views.compileWith]);
    app.set('view engine', config.server.views.extension);
    app.use(express.favicon());
    app.use(express.urlencoded());
    app.use(express.json());
    app.use(express.methodOverride());
    app.use(express.compress());
    app.use(config.server.base, app.router);
    app.use(express.static(config.watch.compiledDir));
  });

  app.configure('development', function() {
    app.use(express.errorHandler());
  });

  app.get('/', routes.index(config));

  callback(server);
};

