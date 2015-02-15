var utils = require( "../../utils" )
  ;

var basicRun = function(sout, projectData, done) {
  var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
  expect(assetCount).to.eql(0);
  done();
};

describe("Mimosa's cleaner", function() {

  utils.cleanTest({
    testSpec: "when processing completes will remove all code and call the finish callback",
    configFile: "cleaner/clean",
    project: "basic",
    asserts: basicRun
  });

  utils.cleanTest({
    testSpec: "will ignore files when configured to ignore files",
    configFile: "cleaner/exclude",
    project: "basic",
    asserts: function(output, projectData, done) {
      var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
      expect(output.log.indexOf("requirejs/require.js")).to.be.above(100);
      expect(output.log.indexOf("main.js")).to.eql(-1);
      expect(assetCount).to.eql(0);
      done();
    }
  });

  utils.cleanTest({
    testSpec: "works when setting interval",
    configFile: "cleaner/interval",
    project: "basic",
    asserts: basicRun
  });

  utils.cleanTest({
    testSpec: "works when setting polling to false",
    configFile: "cleaner/polling",
    project: "basic",
    asserts: basicRun
  });

  utils.cleanTest({
    testSpec: "will clean and exit when no files in asset directory",
    configFile: "cleaner/empty",
    project: "empty",
    asserts: basicRun
  });
});
