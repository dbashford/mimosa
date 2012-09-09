var index = function(config) {
  cachebust = ''
  if (process.env.NODE_ENV !== "production") {
    cachebust = "?b=" + (new Date()).getTime()
  }

  var options = {
    reload:    config.server.useReload,
    optimize:  config.optimize != null ? config.optimize : false,
    cachebust: cachebust
  };

  // In the event plain html pages are being used, need to
  // switch to different page for optimized view
  var name = "index";
  if (config.optimize && config.server.views.html) {
    name += "-optimize";
  }

  return function(req, res) {
    res.render(name, options);
  };
};

exports.index = index;
