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

    utils.runBuildThenTest(
      "will run and exit successfully when there are no files in the asset directory",
      "watcher/build-empty",
      "empty",
      basicBuild(100, 0)
    );

    describe("will process all of a projects files into the public directory", function() {

      var basicTest = basicBuild(500, 11);

      utils.runBuildThenTest(
        "with the default config",
        "watcher/build",
        "basic",
        basicTest
      );

      utils.runBuildThenTest(
        "when throttle is set",
        "watcher/build-throttle",
        "basic",
        basicTest
      );

      utils.runBuildThenTest(
        "when delay is set",
        "watcher/build-delay",
        "basic",
        basicTest
      );

      utils.runBuildThenTest(
        "when interval is set",
        "watcher/build-interval",
        "basic",
        basicTest
      );

      utils.runBuildThenTest(
        "when polling is set to false",
        "watcher/build-polling",
        "basic",
        basicTest
      );
    });

    describe("will exclude files from being processed into the public directory", function() {
      utils.runBuildThenTest(
        "via string match",
        "watcher/build-exclude-string",
        "basic",
        basicBuild(400, 8)
      );

      utils.runBuildThenTest(
        "via regex match",
        "watcher/build-exclude-regex",
        "basic",
        basicBuild(400, 8)
      );

      utils.runBuildThenTest(
        "via both string and regex match",
        "watcher/build-exclude-both",
        "basic",
        basicBuild(400, 8)
      );
    });
  });

  describe("on mimosa watch", function() {

    it("will stop watching and exit when STOPMIMOSA is sent");

    describe("will exclude files from being processed into the public directory", function() {
      // describe("via string exclude", function() {
      //   runTest(
      //     "when an excluded file is added",
      //     "watcher/build-exclude-string-add",
      //     "basic",
      //     function(sout, projectData, done) {
      //       var assetCount = filesDirectoriesInFolder(projectData.publicDir);
      //       expect(sout.indexOf("Finished build")).to.be.above(finishedLoc);
      //       expect(assetCount).to.eql(filesOut);
      //       done();
      //     };
      //     basicBuild(400, 8)
      //   );
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
