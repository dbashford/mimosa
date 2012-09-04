var index = function(useReload, optimize) {
    cachebust = ''
    if (process.env.NODE_ENV !== "production") {
      cachebust = "?b=" + (new Date()).getTime()
    }

    var options = {
      title:     "Express",
      reload:    useReload,
      optimize:  optimize != null ? optimize : false,
      cachebust: cachebust
    };

    return function(req, res) {
      res.render('index', options);
    };
  };

exports.index = index;
