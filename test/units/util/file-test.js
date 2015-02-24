var path = require( "path" )
  , fs = require( "fs" )
  , fileUtil = require( path.join(process.cwd(), "lib", "util", "file") )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , wrench = require( "wrench" )
  , sinon = require( "sinon" )
  ;

describe("Mimosa file utility's", function() {

  describe("remove .mimosa function", function() {

    var projectRoot = path.join( process.cwd(), "test", "harness", "run", "remove-dot-mimosa" );

    before(function() {
      wrench.mkdirSyncRecursive( projectRoot, 0777 );
    });

    after(function() {
      wrench.rmdirSyncRecursive( projectRoot );
    });

    it("will remove .mimosa from the cwd", function() {
      var mimosaDirectory = path.join( projectRoot, ".mimosa" );
      wrench.mkdirSyncRecursive( mimosaDirectory, 0777 );

      var origCwd = process.cwd();
      process.chdir( projectRoot );
      fileUtil.removeDotMimosa();
      process.chdir( origCwd );

      expect( fs.existsSync( projectRoot ) ).to.be.true;
      expect( fs.existsSync( mimosaDirectory ) ).to.be.false;
    });

    it("will not error out if .mimosa is missing", function() {
      var badPath = path.join( __dirname, "bad", "path");
      var origCwd = process.cwd();
      process.chdir( projectRoot );
      try {
        fileUtil.removeDotMimosa();
        expect(true).to.be.true;
      } catch ( err ) {
        expect(true).to.be.false;
      }
      process.chdir( origCwd );
    });
  });

  describe("isCSS function", function(){
    var isCSS = fileUtil.isCSS
    it("will properly recognize a CSS file", function() {
      var result1 = isCSS("foo.css");
      var result2 = isCSS("/a/b/c/d.css");
      var result3 = isCSS("../a.css");

      expect(result1).to.be.true;
      expect(result2).to.be.true;
      expect(result3).to.be.true;
    });

    it("will properly recognize when a file is not CSS", function() {
      var result1 = isCSS("foo.css.js");
      var result2 = isCSS("/a/b/c/d.js");
      var result3 = isCSS("../a.cssss");

      expect(result1).to.be.false;
      expect(result2).to.be.false;
      expect(result3).to.be.false;
    });
  });

  describe("isJavascript function", function(){
    var isJS = fileUtil.isJavascript

    it("will properly recognize a JavaScript file", function() {
      var result1 = isJS("foo.js");
      var result2 = isJS("/a/b/c/d.js");
      var result3 = isJS("../a.js");

      expect(result1).to.be.true;
      expect(result2).to.be.true;
      expect(result3).to.be.true;
    });
    it("will properly recognize when a file is not JavaScript", function() {
      var result1 = isJS("foo.css");
      var result2 = isJS("/a/b/c/d.js.css");
      var result3 = isJS("../a.jsss");

      expect(result1).to.be.false;
      expect(result2).to.be.false;
      expect(result3).to.be.false;
    });
  });

  describe("isVendorCSS function", function(){
    var isVCSS = fileUtil.isVendorCSS
    var config = {
      vendor: {
        stylesheets: "foo/vendor"
      }
    };

    it("will properly recognize a Vendor CSS file", function() {
      var result1 = isVCSS(config, "foo/vendor/foo.css");
      var result2 = isVCSS(config, "foo/vendor/a/b/c/d.css");
      var result3 = isVCSS(config, "foo/vendor/a.css");

      expect(result1).to.be.true;
      expect(result2).to.be.true;
      expect(result3).to.be.true;
    });

    it("will properly recognize when a CSS file that is not vendor", function() {
      var result1 = isVCSS(config, "foo/vendo/foo.css");
      var result2 = isVCSS(config, "foo/vendo/a/b/c/d.css");
      var result3 = isVCSS(config, "foo/vendo/a.css");

      expect(result1).to.be.false;
      expect(result2).to.be.false;
      expect(result3).to.be.false;
    });

    it("will not care if file isn't CSS as it is assumed", function() {
      var result1 = isVCSS(config, "foo/vendor/foo.js");
      expect(result1).to.be.true;
    });
  });

  describe("isVendorJS function", function(){
    var isVJS = fileUtil.isVendorJS;
    var config = {
      vendor: {
        javascripts: "foo/vendor"
      }
    };

    it("will properly recognize a Vendor JS file", function() {
      var result1 = isVJS(config, "foo/vendor/foo.js");
      var result2 = isVJS(config, "foo/vendor/a/b/c/d.js");
      var result3 = isVJS(config, "foo/vendor/a.js");

      expect(result1).to.be.true;
      expect(result2).to.be.true;
      expect(result3).to.be.true;
    });
    it("will properly recognize when a JS file that is not vendor", function() {
      var result1 = isVJS(config, "foo/vendo/foo.js");
      var result2 = isVJS(config, "foo/vendo/a/b/c/d.js");
      var result3 = isVJS(config, "foo/vendo/a.js");

      expect(result1).to.be.false;
      expect(result2).to.be.false;
      expect(result3).to.be.false;
    });

    it("will not care if file isn't JS as it is assumed", function() {
      var result1 = isVJS(config, "foo/vendor/foo.css");
      expect(result1).to.be.true;
    });
  });

  describe("mkdirRecursive function", function() {
    var projectRoot = path.join( process.cwd(), "test", "harness", "run", "mkdirrecursive" )
      , mkdir = fileUtil.mkdirRecursive;

    before(function() {
      wrench.mkdirSyncRecursive( projectRoot, 0777 );
    });

    after(function() {
      wrench.rmdirSyncRecursive( projectRoot );
    });

    describe("will make a directory recursively", function(){
      it("one level deep", function() {
        var dir = path.join( projectRoot, "onelevel" );
        mkdir(dir);
        expect(fs.existsSync(dir)).to.be.true;
      });

      it("five levels deep", function() {
        var dir = path.join( projectRoot, "five", "levels", "deep", "deep", "deep" );
        mkdir(dir);
        expect(fs.existsSync(dir)).to.be.true;
      });
    });

    it("will throw an error if asked to make a directory that exists as a file", function() {
      var dir = path.join( projectRoot, "five", "levels", "deep", "deep", "deep" );
      wrench.mkdirSyncRecursive(dir);
      var filePath = path.join( dir, "foo.txt");
      fs.writeFileSync(filePath, "foo");
      expect(fs.existsSync(filePath)).to.be.true;
      try {
        mkdir(filePath);
        expect(false).to.be.true;
      } catch(err) {
        expect(true).to.be.true;
        expect(err.code).to.eql("EEXIST")
      }
    });
    it("will exit gracefully, doing nothing, if asked to make a directory that exists", function() {
      var dir = path.join( projectRoot, "five", "levels", "deep", "deep", "deep" );
      wrench.mkdirSyncRecursive(dir);
      try {
        mkdir(dir);
        expect(true).to.be.true;
        return;
      } catch(err) {
      }
      expect(false).to.be.true
    });
  });

  describe("write file function", function() {
    var projectRoot = path.join( process.cwd(), "test", "harness", "run", "writeFile" )
      , writeFile = fileUtil.writeFile;

    before(function() {
      wrench.mkdirSyncRecursive( projectRoot, 0777 );
    });

    after(function() {
      wrench.rmdirSyncRecursive( projectRoot );
    });

    it("will write a file", function( done ) {
      var outFile = path.join( projectRoot, "out.file" );
      writeFile( outFile, "foo content", function() {
        expect(fs.readFileSync(outFile, "utf8")).to.eql("foo content")
        done();
      });
    });

    it("will write a file inside a directory that does not exist", function(done) {
      var outFile = path.join( projectRoot, "foo", "bar", "out.file" );
      writeFile( outFile, "fooooo content", function() {
        expect(fs.readFileSync(outFile, "utf8")).to.eql("fooooo content")
        done();
      });
    });

    it("will return error if write failed", function(done) {
      var writeFileStub = sinon.stub( fs, "writeFile", function(a, b, c, cb){
        cb("ITS AN ERROR!");
      });
      var outFile = path.join( projectRoot, "foo", "bar", "out.file" );
      writeFile( outFile, "fooooo content", function( error, fileName ) {
        expect(error).to.eql(
          "Failed to write file: " +
          path.join(process.cwd(), "test/harness/run/writeFile/foo/bar/out.file, ITS AN ERROR!")
        )
        fs.writeFile.restore();
        done();
      });
    });
  });

  describe("is file newer function", function() {
    var projectRoot = path.join( process.cwd(), "test", "harness", "run", "filenewer" )
      , fileNewer = fileUtil.isFirstFileNewer
      , olderFile = path.join( projectRoot, "older.js" )
      , newerFile = path.join( projectRoot, "newer.js")

    before(function(done) {
      wrench.mkdirSyncRecursive( projectRoot, 0777 );
      fs.writeFile(olderFile, "olderfile", function() {
        fs.writeFileSync(newerFile, "newerFile");
        var oldDate = (new Date().getTime()) - 1000000;
        fs.utimesSync(olderFile, oldDate / 1000, oldDate / 1000);
        done();
      });
    });

    after(function() {
      wrench.rmdirSyncRecursive( projectRoot );
    });

    describe("will report the first file as newer", function() {
      it("if the second file passed in is null", function(done) {
        fileNewer("foo", null, function(isNewer) {
          expect(isNewer).to.be.true;
          done();
        });
      });
      it("if the second file does not exist", function(done) {
        fileNewer(olderFile, "blahhhhh", function(isNewer) {
          expect(isNewer).to.be.true;
          done();
        });
      });
      it("if the first file is newer", function(done) {
        fileNewer(newerFile, olderFile, function(isNewer) {
          expect(isNewer).to.be.true;
          done();
        })
      });
    });
    describe("will report the second file as newer", function() {
      it("if the first file passed in is null", function(done) {
        fileNewer(null, "foo", function(isNewer) {
          expect(isNewer).to.be.false;
          done();
        });
      });
      it("if the first file does not exist",  function(done) {
        fileNewer("blahhhhh", olderFile, function(isNewer) {
          expect(isNewer).to.be.false;
          done();
        });
      });
      it("if the second file is newer", function(done) {
        fileNewer(olderFile, newerFile, function(isNewer) {
          expect(isNewer).to.be.false;
          done();
        })
      });
    });
  });

  describe("read dir sync recursive function", function() {
    var projectRoot = path.join( process.cwd(), "test", "harness", "run", "readdir" )
      , projectPath = path.join( projectRoot, "folder", "subfolder", "subsubfolder" )
      , readSync = fileUtil.readdirSyncRecursive
      ;

    before(function() {
      wrench.mkdirSyncRecursive( projectPath, 0777 );
      var file1 = path.join( projectPath, "file1.js");
      var file2 = path.join( projectPath, "..", "file2.js");
      var file3 = path.join( projectPath, "..", "..", "file3.js");
      var file4 = path.join( projectPath, "..", "..", "..", "file4.js");
      [file1, file2, file3, file4].forEach( function( file ) {
        fs.writeFileSync( file, "this is " + file, "utf8" );
      })
    });

    after(function() {
      wrench.rmdirSyncRecursive( projectRoot );
    });

    it("will return files/directories in a folder", function() {
      var filesAndDirectories = readSync(projectRoot);
      expect(filesAndDirectories.length).to.eql(7)
    });

    it("will exclude files specific by string path", function() {
      var filesAndDirectories = readSync(projectRoot,
        [path.join(process.cwd(), "test/harness/run/readdir/folder/subfolder/file2.js"),
        path.join(process.cwd(), "test/harness/run/readdir/folder/file3.js")]);
      expect(filesAndDirectories.length).to.eql(5)
    });

    it("will exclude files specific by regex", function() {
      var filesAndDirectories = readSync(projectRoot, [], /(file3.js|file2.js)$/);
      expect(filesAndDirectories.length).to.eql(5)
    });

    it("will leave out directories when specified", function() {
      var filesAndDirectories = readSync(projectRoot, null, null, true);
      expect(filesAndDirectories.length).to.eql(4)
    });

    it("will exclude files specific by regex and string", function() {
      var filesAndDirectories = readSync(projectRoot,
        [path.join(process.cwd(), "/test/harness/run/readdir/folder/subfolder/file2.js")],
        /(file3.js|file1.js)$/);
      expect(filesAndDirectories.length).to.eql(4)
    });

  });

})
