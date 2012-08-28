var index = function(useReload, optimize) {
    var env = "development"
    if (process.env.NODE_ENV)
      env = process.env.NODE_ENV

    var options = {
      title: "Express",
      reload: useReload,
      optimize: optimize != null ? optimize : false,
      env: env
    };

    return function(req, res) {
      res.render('index', options);
    };
  };

exports.index = index;
