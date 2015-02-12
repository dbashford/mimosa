var utils = require( "../../utils" )
  ;

var basicBuild = function(finishedLoc, filesOut) {
  return function(sout, projectData, done) {
    var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
    expect(sout.indexOf("Finished build")).to.be.above(finishedLoc);
    expect(assetCount).to.eql(filesOut);
    done();
  };
};

describe("Mimosa's watcher", function() {

  describe("on mimosa build", function() {

    utils.runBuildThenTest({
      testSpec: "will run and exit successfully when there are no files in the asset directory",
      configFile: "watcher/build-empty",
      project: "empty",
      asserts: basicBuild(100, 0)
    });

    describe("will process all of a projects files into the public directory", function() {

      var basicTest = basicBuild(500, 11);

      utils.runBuildThenTest({
        testSpec: "with the default config",
        configFile: "watcher/build",
        project: "basic",
        asserts: basicTest
      });

      utils.runBuildThenTest({
        testSpec: "when throttle is set",
        configFile: "watcher/build-throttle",
        project: "basic",
        asserts: basicTest
      });

      utils.runBuildThenTest({
        testSpec: "when delay is set",
        configFile: "watcher/build-delay",
        project: "basic",
        asserts: basicTest
      });

      utils.runBuildThenTest({
        testSpec: "when interval is set",
        configFile: "watcher/build-interval",
        project: "basic",
        asserts: basicTest
      });

      utils.runBuildThenTest({
        testSpec: "when polling is set to false",
        configFile: "watcher/build-polling",
        project: "basic",
        asserts: basicTest
      });
    });

    describe("will exclude files from being processed into the public directory", function() {
      utils.runBuildThenTest({
        testSpec: "via string match",
        configFile: "watcher/build-exclude-string",
        project: "basic",
        asserts: basicBuild(400, 8)
      });

      utils.runBuildThenTest({
        testSpec: "via regex match",
        configFile: "watcher/build-exclude-regex",
        project: "basic",
        asserts: basicBuild(400, 8)
      });

      utils.runBuildThenTest({
        testSpec: "via both string and regex match",
        configFile: "watcher/build-exclude-both",
        project: "basic",
        asserts: basicBuild(400, 8)
      });
    });
  });

  describe("on mimosa watch", function() {

    it("will stop watching and exit when STOPMIMOSA is sent");

    describe("will exclude files from being processed into the public directory", function() {

      describe("via string exclude", function() {
        var testOpts = {
          testSpec: "when an excluded file is added",
          configFile: "watcher/watch-exclude-string-add",
          project: "basic",
          fileSuccessCount: 3,
          postWatch: function(projectData, killCallback) {
            killCallback();
          },
          asserts: function(sout, projectData, done) {
            // var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
            // expect(sout.indexOf("Finished build")).to.be.above(finishedLoc);
            // expect(assetCount).to.eql(filesOut);
            done();
          }
        }

        utils.runWatchThenTest(testOpts);
      });
      //
      //   runTest(
      //     "when an excluded file is updated",
      //     "watcher/build-exclude-string-update",
      //     "basic",
      //     basicBuild(400, 8)
      //   );
      //
      //   runTest(
      //     "when an excluded file is deleted",
      //     "watcher/build-exclude-string-delete",
      //     "basic",
      //     basicBuild(400, 8)
      //   );
      // });

      describe("via regex exclude", function() {

      });

      describe("via string and regex exclude", function() {

      });
    });

    describe("after the initial build", function(){
      it("will keep watching");
      it("will process file adds");
      it("will process file deletes");
      it("will process file updates");
      it("will process file moves (add and delete at same time)");

      describe("with throttle engaged", function() {
        it("will process file adds");
        it("will process file moves (add and delete at same time)");
      });

      describe("with delay engaged", function() {
        it("will process file adds")
        it("will process file updates");
        it("will process file moves (add and delete at same time)");
      });
    });

    it("can handle adding file to empty project")

  });

});
