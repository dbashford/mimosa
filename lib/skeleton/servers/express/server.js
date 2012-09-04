var express = require('express'),
    gzip = require('gzippo'),
    reloadOnChange = require('watch-connect'),
    routes = require('./routes');

exports.startServer = function(config) {
  var app = express(),
      publicPath = config.watch.compiledDir,
      useReload = config.server.useReload,
      server;

  server = app.listen(3000, function() {
    console.log("Express server listening on port %d in %s mode", server.address().port, app.settings.env);
  });

  app.configure(function() {
    var options;
    app.set('port', process.env.PORT || 3000);
    app.set('views', config.server.views.path);
    app.set('view engine', config.server.views.compileWith);
    app.use(express.favicon());
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    if (useReload) {
      options = {
        server: server,
        watchdir: publicPath,
        verbose: false,
        skipAdding: true,
        exclude: ["almond\.js"],
        additionaldirs: [config.server.views.path]
      };
      app.use(reloadOnChange(options));
    }
    app.use(app.router);
    app.use(gzip.staticGzip(publicPath));
  });

  app.configure('development', function() {
    app.use(express.errorHandler());
  });

  app.get('/', routes.index(useReload, config.optimize));
};

