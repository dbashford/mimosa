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

var updateTest = function( conf ) {
  var testOpts = {
    testSpec: "will process file updates",
    configFile: conf,
    project: "basic",
    postBuild: function(projectData, cb) {
      var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
      expect(assetCount).to.eql(11);

      // write one file that will get excluded and
      // one that will not
      var updateFileAssets = path.join( projectData.javascriptInDir, "main.js")
      fs.writeFileSync(updateFileAssets, "console.log(\"\");");
      cb();
    },
    asserts: function(output, projectData, done) {
      var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
      expect(assetCount).to.eql(11);

      // get file from output directory
      var updateFilePublic = path.join( projectData.javascriptOutDir, "main.js")
      fs.writeFileSync(updateFilePublic, "console.log(\"\");")
      done();
    }
  }
  utils.watchTest(testOpts);
};

var addTest = function( conf ) {
  var testOpts = {
    testSpec: "will process file adds",
    configFile: conf,
    project: "basic",
    postBuild: function(projectData, cb) {
      var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
      expect(assetCount).to.eql(11);

      // write one file that will get excluded and
      // one that will not
      var addFileAssets = path.join( projectData.javascriptInDir, "foo.js")
      fs.writeFileSync(addFileAssets, "console.log(\"\");");
      cb();
    },
    asserts: function(output, projectData, done) {
      var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
      expect(assetCount).to.eql(12);
      expect(output.log.indexOf("foo.js")).to.be.above(100);

      // get file from output directory
      var addFilePublic = path.join( projectData.javascriptOutDir, "foo.js")
      var fileText = fs.readFileSync(addFilePublic).toString();
      expect(fileText).to.eql("console.log(\"\");");
      done();
    }
  }
  utils.watchTest(testOpts);
}

var moveTest = function( conf ) {
  var testOpts = {
    testSpec: "will process file moves (add and delete at same time)",
    configFile: conf,
    project: "basic",
    postBuild: function(projectData, cb) {
      var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
      expect(assetCount).to.eql(11);

      // write one file that will get excluded and
      // one that will not
      var removeFileAssets = path.join( projectData.javascriptInDir, "main.js")
      var newFileAssets = path.join( projectData.javascriptInDir, "app", "main.js")
      fs.renameSync(removeFileAssets, newFileAssets);
      cb();
    },
    asserts: function(output, projectData, done) {
      var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
      expect(assetCount).to.eql(11);

      // write one file that will get excluded and
      // one that will not
      var removeFilePublic = path.join( projectData.javascriptOutDir, "main.js")
      var newFilePublic = path.join( projectData.javascriptOutDir, "app", "main.js")

      expect(fs.existsSync(removeFilePublic)).to.be.false;
      expect(fs.existsSync(newFilePublic)).to.be.true;
      done();
    }
  }
  utils.watchTest(testOpts);
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

    var testOpts12343 = {
      testSpec: "will stop watching and exit when STOPMIMOSA is sent",
      configFile: "watcher/watch-stop",
      project: "basic",
      postBuild: function(projectData, cb) {
        var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
        expect(assetCount).to.eql(11);

        var hadListeners = process.emit("STOPMIMOSA");
        process.nextTick(function() {
          var notWatchedPath = path.join( projectData.javascriptInDir, "foo.js")
          fs.writeFileSync(notWatchedPath, "console.log('test')");
          cb();
        });
      },
      asserts: function(output, projectData, done) {
        var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
        expect(assetCount).to.eql(11);
        var notWrittenPath = path.join( projectData.javascriptOutDir, "foo.js")
        expect(fs.existsSync(notWrittenPath)).to.be.false;
        done();
      }
    }
    utils.watchTest(testOpts12343);

    describe("will exclude files from being processed into the public directory", function() {

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

      addTest("watcher/watch-add");

      var testOpts2 = {
        testSpec: "will process file deletes",
        configFile: "watcher/watch-delete",
        project: "basic",
        postBuild: function(projectData, cb) {
          var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
          expect(assetCount).to.eql(11);

          // ensure file we intend to delete exists
          var removeFilePublic = path.join( projectData.javascriptOutDir, "main.js")
          expect(fs.existsSync(removeFilePublic)).to.be.true;

          var removeFileAssets = path.join( projectData.javascriptInDir, "main.js")
          fs.unlinkSync(removeFileAssets);
          cb();
        },
        asserts: function(output, projectData, done) {
          var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
          expect(assetCount).to.eql(10);

          // get file from output directory
          var removeFilePublic = path.join( projectData.javascriptOutDir, "main.js")
          expect(fs.existsSync(removeFilePublic)).to.be.false;
          done();
        }
      }
      utils.watchTest(testOpts2);

      updateTest("watcher/watch-update");
      moveTest("watcher/watch-move");

      describe("with throttle engaged", function() {
        addTest("watcher/watch-add-throttle");
        moveTest("watcher/watch-move-throttle");
      });

      describe("with delay engaged", function() {
        updateTest("watcher/watch-update-delay");
        addTest("watcher/watch-add-delay");
        moveTest("watcher/watch-move-delay");
      });
    });

    var testOpts314 = {
      testSpec: "can handle adding file to empty project",
      configFile: "watcher/watch-empty",
      project: "empty",
      postBuild: function(projectData, cb) {
        var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);
        // doesn't create empty folders
        expect(assetCount).to.eql(0);

        // write one file that will get excluded and
        // one that will not
        var addFileAssets = path.join( projectData.javascriptInDir, "foo.js")
        fs.writeFileSync(addFileAssets, "console.log(\"\");");
        cb();
      },
      asserts: function(output, projectData, done) {
        var assetCount = utils.filesAndDirsInFolder(projectData.publicDir);

        // folder and file in it.
        expect(assetCount).to.eql(2);
        expect(output.log.indexOf("foo.js")).to.be.above(100);

        // get file from output directory
        var addFilePublic = path.join( projectData.javascriptOutDir, "foo.js")
        var fileText = fs.readFileSync(addFilePublic).toString();
        expect(fileText).to.eql("console.log(\"\");");
        done();
      }
    };
    utils.watchTest(testOpts314);

  });
});
