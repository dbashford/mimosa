var getCallbacks = function( compiler, config, cb ) {
  var i = 0
    , determineOutputFile
    , compile
    ;

  compiler.registration( config, function(a, b, lifecycle, d) {
    if (i++) {
      cb({
        determineOutputFile: determineOutputFile,
        compile: lifecycle
      });
    } else {
      determineOutputFile = lifecycle;
    }
  })
};

module.exports = {
  getCallbacks: getCallbacks
};