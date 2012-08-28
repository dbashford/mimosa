var express = require('express'),
    gzip = require('gzippo'),
    reloadOnChange = require('watch-connect'),
    routes = require('./routes');

exports.startServer = function(publicPath, useReload, optimize) {
  var app = express(),
      viewDirectory = __dirname + "/views",
      server;

  server = app.listen(3000, function() {
    console.log("Express server listening on port %d in %s mode", server.address().port, app.settings.env);
  });

  app.configure(function() {
    var options;
    app.set('port', process.env.PORT || 3000);
    app.set('views', viewDirectory);
    app.set('view engine', 'jade');
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
        additionaldirs: [viewDirectory]
      };
      app.use(reloadOnChange(options));
    }
    app.use(app.router);
    app.use(gzip.staticGzip(publicPath));
  });

  app.configure('development', function() {
    app.use(express.errorHandler());
  });

  app.get('/', routes.index(useReload, optimize));
};

