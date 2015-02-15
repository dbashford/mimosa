var fs = require( "fs" )
  , path = require( "path" )
  , utils = require( "../../utils" )
  ;

var basicBuild = function(filesOut) {
  return function(output, projectData, done) {
    var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
    expect(assetCount).to.eql(filesOut);
    done();
  };
};

describe("Mimosa's watcher", function() {

  describe("on mimosa build", function() {

    utils.buildTest({
      testSpec: "will run and exit successfully when there are no files in the asset directory",
      configFile: "watcher/build-empty",
      project: "empty",
      asserts: basicBuild(0)
    });

    describe("will process all of a projects files into the public directory", function() {

      var basicTest = basicBuild(11);

      utils.buildTest({
        testSpec: "with the default config",
        configFile: "watcher/build",
        project: "basic",
        asserts: basicTest
      });

      utils.buildTest({
        testSpec: "when throttle is set",
        configFile: "watcher/build-throttle",
        project: "basic",
        asserts: basicTest
      });

      utils.buildTest({
        testSpec: "when delay is set",
        configFile: "watcher/build-delay",
        project: "basic",
        asserts: basicTest
      });

      utils.buildTest({
        testSpec: "when interval is set",
        configFile: "watcher/build-interval",
        project: "basic",
        asserts: basicTest
      });

      if (__dirname.indexOf("/travis/") < 0) {
        utils.buildTest({
          testSpec: "when polling is set to false",
          configFile: "watcher/build-polling",
          project: "basic",
          asserts: basicTest
        });
      }
    });

    describe("will exclude files from being processed into the public directory", function() {
      utils.buildTest({
        testSpec: "via string match",
        configFile: "watcher/build-exclude-string",
        project: "basic",
        asserts: basicBuild(8)
      });

      utils.buildTest({
        testSpec: "via regex match",
        configFile: "watcher/build-exclude-regex",
        project: "basic",
        asserts: basicBuild(8)
      });

      utils.buildTest({
        testSpec: "via both string and regex match",
        configFile: "watcher/build-exclude-both",
        project: "basic",
        asserts: basicBuild(8)
      });
    });
  });

  describe("on mimosa watch", function() {

    it("will stop watching and exit when STOPMIMOSA is sent");

    describe("will exclude files from being processed into the public directory", function() {

      var excludeTests = function( files ) {
        var testOpts1 = {
          testSpec: "when an excluded file is added",
          configFile: files.add,
          project: "basic",
          postBuild: function(projectData, cb) {
            var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
            expect(assetCount).to.eql(8);

            // write one file that will get excluded and
            // one that will not
            var ignoredFilePath = path.join( projectData.javascriptInDir, "foo.js")
            var notIgnoredFilePath = path.join( projectData.javascriptInDir, "bar.js")
            fs.writeFileSync(ignoredFilePath, "console.log('test')");
            fs.writeFileSync(notIgnoredFilePath, "console.log('test')");
            cb();
          },
          asserts: function(output, projectData, done) {
            var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
            expect(assetCount).to.eql(9);

            expect(output.log.indexOf("foo.js")).to.eql(-1);
            expect(output.log.indexOf("bar.js")).to.be.above(100);
            done();
          }
        }
        utils.watchTest(testOpts1);

        var testOpts2 = {
          testSpec: "when an excluded file is updated",
          configFile: files.update,
          project: "basic",
          postBuild: function(projectData, cb) {
            var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
            expect(assetCount).to.eql(8);

            // write one file that will get excluded and
            // one that will not
            var ignoredFilePath = path.join( projectData.javascriptInDir, "main.js")
            fs.writeFileSync(ignoredFilePath, "console.log('test')");
            cb();
          },
          asserts: function(output, projectData, done) {
            var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
            expect(assetCount).to.eql(8);
            expect(output.log.indexOf("main.js")).to.eql(-1);
            done();
          }
        }

        utils.watchTest(testOpts2);

        var testOpts3 = {
          testSpec: "when an excluded file is deleted",
          configFile: files.remove,
          project: "basic",
          postBuild: function(projectData, cb) {
            var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
            expect(assetCount).to.eql(8);

            // write one file that will get excluded and
            // one that will not
            var ignoredFilePath = path.join( projectData.javascriptInDir, "main.js")
            fs.unlinkSync(ignoredFilePath);
            cb();
          },
          asserts: function(output, projectData, done) {
            var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
            expect(assetCount).to.eql(8);
            expect(output.log.indexOf("main.js")).to.eql(-1);
            done();
          }
        }

        utils.watchTest(testOpts3);
      };

      describe("via string exclude", function() {
        var files = {
          add: "watcher/watch-exclude-string-add",
          update: "watcher/watch-exclude-string-update",
          remove: "watcher/watch-exclude-string-delete"
        };

        excludeTests( files );
      });

      describe("via regex exclude", function() {
        var files = {
          add: "watcher/watch-exclude-regex-add",
          update: "watcher/watch-exclude-regex-update",
          remove: "watcher/watch-exclude-regex-delete"
        };

        excludeTests( files );
      });

      describe("via string and regex exclude", function() {
        var files = {
          add: "watcher/watch-exclude-both-add",
          update: "watcher/watch-exclude-both-update",
          remove: "watcher/watch-exclude-both-delete"
        };

        excludeTests( files );
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
