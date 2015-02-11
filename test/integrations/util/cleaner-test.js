var utils = require( "../../utils" )
  ;

var basicRun = function(cleanLoc) {
  return function(sout, projectData, done) {
    var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
    expect(sout.indexOf("has been cleaned.")).to.above(cleanLoc);
    expect(assetCount).to.eql(0);
    done();
  };
};

describe("Mimosa's cleaner", function() {

  utils.runBuildAndCleanThenTest(
    "when processing completes will remove all code and call the finish callback",
    "cleaner/clean",
    "basic",
    basicRun(900)
  );

  utils.runBuildAndCleanThenTest(
    "will ignore files when configured to ignore files",
    "cleaner/exclude",
    "basic",
    function(sout, projectData, done) {
      var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
      expect(sout.indexOf("has been cleaned.")).to.be.above(900);
      expect(sout.indexOf("requirejs/require.js")).to.be.above(300);
      expect(sout.indexOf("main.js")).to.eql(-1);
      expect(assetCount).to.eql(0);
      done();
    }
  );

  utils.runBuildAndCleanThenTest(
    "works when setting interval",
    "cleaner/interval",
    "basic",
    basicRun(900)
  );

  utils.runBuildAndCleanThenTest(
    "works when setting polling to false",
    "cleaner/polling",
    "basic",
    basicRun(900)
  );

  utils.runBuildAndCleanThenTest(
    "will clean and exit when no files in asset directory",
    "cleaner/empty",
    "empty",
    basicRun(50)
  );
});
