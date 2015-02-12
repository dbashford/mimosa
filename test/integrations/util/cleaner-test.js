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

  utils.runBuildAndCleanThenTest({
    testSpec: "when processing completes will remove all code and call the finish callback",
    configFile: "cleaner/clean",
    project: "basic",
    asserts: basicRun(900)
  });

  utils.runBuildAndCleanThenTest({
    testSpec: "will ignore files when configured to ignore files",
    configFile: "cleaner/exclude",
    project: "basic",
    asserts: function(sout, projectData, done) {
      var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
      expect(sout.indexOf("has been cleaned.")).to.be.above(900);
      expect(sout.indexOf("requirejs/require.js")).to.be.above(100);
      expect(sout.indexOf("main.js")).to.eql(-1);
      expect(assetCount).to.eql(0);
      done();
    }
  });

  utils.runBuildAndCleanThenTest({
    testSpec: "works when setting interval",
    configFile: "cleaner/interval",
    project: "basic",
    asserts: basicRun(900)
  });

  utils.runBuildAndCleanThenTest({
    testSpec: "works when setting polling to false",
    configFile: "cleaner/polling",
    project: "basic",
    asserts: basicRun(900)
  });

  utils.runBuildAndCleanThenTest({
    testSpec: "will clean and exit when no files in asset directory",
    configFile: "cleaner/empty",
    project: "empty",
    asserts: basicRun(50)
  });
});
