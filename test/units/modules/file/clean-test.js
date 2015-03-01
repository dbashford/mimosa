var fs = require( "fs" )
  , path = require( "path" )
  , sinon = require( "sinon" )
  , wrench = require( "wrench" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , cleanModule = require( path.join(process.cwd(), "lib", "modules", "file", "clean") )
  , fakeMimosaConfig = utils.fake.mimosaConfig();
  ;

describe( "Mimosa file cleaning workflow module", function(){
  var cleanFunction
    , spy
    , wrenchStub
    ;

  var createWrenchStub = function( directories ) {
    sinon.stub(wrench, "readdirSyncRecursive", function(){
      return directories;
    });
  }

  before(function(done) {
    spy = sinon.spy();
    utils.test.registration( cleanModule, function( func ) {
      cleanFunction = func;
      done();
    }, true);
  });

  afterEach(function() {
    spy.reset();
    wrench.readdirSyncRecursive.restore();
  });

  it("will call lifecycle callback if no directories in project", function() {
    createWrenchStub([]);
    cleanFunction( fakeMimosaConfig, {}, spy );
    expect(spy.calledOnce).to.be.true;
  });

  var testCallbackWithFiles = function( files, exists ) {
    createWrenchStub(files);
    var rmdirStub = sinon.stub( fs, "rmdirSync", function(p, cb){
      cb();
    });
    var existsStub = sinon.stub( fs, "existsSync", function(p, cb){
      if( exists === true ) {
        return true;
      } else if( exists === false ) {
        return false;
      } else {
        return Math.random() >= 0.5;
      }
    });
    var statSyncStub = sinon.stub( fs, "statSync", function() {
      return {
        isDirectory: function() {
          return true;
        }
      }
    });
    cleanFunction( fakeMimosaConfig, {}, spy );

    // if not random, then all directories "do not exist"
    // so no attempt to remove the directory will take place
    if( exists === false) {
      expect(rmdirStub.callCount).to.eql(0);
    } else if ( exists === true) {
      expect(rmdirStub.callCount).to.eql(files.length);
    }

    expect(spy.calledOnce).to.be.true;
    expect(existsStub.callCount).to.eql(files.length);
    expect(statSyncStub.callCount).to.eql(files.length);
    fs.existsSync.restore();
    fs.statSync.restore();
    fs.rmdirSync.restore();
  };

  it("will call lifecycle callback if one directory in project", function() {
    testCallbackWithFiles(["foo"]);
  });

  it("will call lifecycle callback if multiple directories in project", function() {
    testCallbackWithFiles(["foo", "foooooo", "bar", "foo/bar", "baarrrrerrrrr"]);
  });

  it("will call lifecycle callback and not attempt to remove directories if files do not exist ", function(){
    testCallbackWithFiles(["foo", "foooooo"], false);
  });

  it("will call lifecycle callback and attempt to remove directories if they do exist", function(){
    testCallbackWithFiles(["foo", "foooooo"], true);
  });
});