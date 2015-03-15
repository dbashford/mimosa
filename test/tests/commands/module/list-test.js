var cp = require( 'child_process' )
  , color = require( "ansi-color" ).set
  , path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , request = require( "request" )
  , modulePath = path.join(process.cwd(), "lib", "modules")
  , moduleMetadata = require(modulePath).installedMetadata
  , commandPath = path.join( process.cwd(), "lib", "command", "module", "list")
  , command = require( commandPath )
  , utils = require( path.join(process.cwd(), "test", "utils"))
  ;

var moduleData = [{
    "name": "mimosa-asset-cache-bust",
    "version": "2.0.0",
    "site": "https://github.com/ifraixedes/mimosa-asset-cache-bust/tree/v1.0.0",
    "dependencies": {},
    "desc": "mimosa module to rename assets files appending a file digest providing a unique name, so breaking the browser cache, when they change",
    "updated": "2015-03-11 19:19:48",
    "pastVersions": [
      "0.0.1",
      "0.0.2",
      "0.0.3",
      "1.0.0",
      "2.0.0"
    ],
    "keywords": [
      "mimosa",
      "mmodule",
      "cache bust",
      "asset"
    ]
  },
  {
    "name": "mimosa-autoprefixer",
    "version": "0.3.0",
    "site": "https://github.com/dbashford/mimosa-autoprefixer",
    "dependencies": {
      "autoprefixer": "5.1.0",
      "lodash": "2.4.1"
    },
    "desc": "An autoprefixer module for Mimosa",
    "updated": "2015-03-01 13:49:44",
    "pastVersions": [
      "0.1.0",
      "0.2.0",
      "0.3.0"
    ],
    "keywords": [
      "mimosa",
      "mmodule",
      "autoprefix",
      "vendor",
      "prefix",
      "css"
    ]
  },
  {
    "name": "mimosa-babel",
    "version": "0.4.3",
    "site": "https://github.com/YoloDev/mimosa-babel",
    "dependencies": {
      "babel": "^4.0.0",
      "deepmerge": "^0.2.7"
    },
    "desc": "babel mimosa files",
    "updated": "2015-02-16 17:08:45",
    "pastVersions": [
      "0.4.0",
      "0.4.1",
      "0.4.2",
      "0.4.3"
    ],
    "keywords": [
      "mimosa",
      "rename"
    ]
  }];

var executeCommand = function() {
  var fakeProgram = utils.fake.program();
  fakeProgram.action = function( funct ) {
    funct( {} );
    return fakeProgram;
  }
  command( fakeProgram );
}

describe("Mimosa's list command", function() {

  utils.test.command.flags.help( command );
  utils.test.command.flags.debugSetup( "modlist", command );

  describe("will", function() {
    var execStub
      , requestGetStub
      , oldMods
      , loggerGreenStub
      ;

    before(function(done) {
      loggerGreenSpy = sinon.stub(logger, "green")
      sinon.stub(process, "exit", function(){
        done()
      });
      requestGetStub = sinon.stub( request, "get", function( uri, opts, cb) {
        cb( null, null, JSON.stringify(moduleData) );
      })
      execStub = sinon.stub(cp, "exec", function( str, cb ){
        // no proxy
        cb( null, "proxyproxyproxy", null)
      });
      oldMods = require(modulePath).installedMetadata
      require(modulePath).installedMetadata = [{name:"mimosa-babel", version:"0.4.0"}];
      executeCommand();
    });

    after(function(){
      require(modulePath).installedMetadata = oldMods;
      cp.exec.restore();
      process.exit.restore();
      request.get.restore();
      logger.green.restore();
    });

    it("will ask for proxy", function() {
      expect(execStub.calledOnce).to.be.true;
      expect(execStub.args[0][0]).to.eql("npm config get proxy")
    });

    it("will make request to proper heroku url", function() {
      expect(requestGetStub.calledOnce).to.be.true;
      expect(requestGetStub.args[0][0]).to.eql("http://mimosa-data.herokuapp.com/modules")
    });

    it("will include any given proxy as part of the request", function() {
      expect(requestGetStub.args[0][1].proxy).to.eql("proxyproxyproxy")
    })

    describe("print to the console", function() {
      var log;
      before(function() {
        log = loggerGreenSpy.args.map( function(arg) {
          return arg[0]
        }).join("\n")
      });

      it("the right modules", function() {
        expect(/mimosa-babel/.test(log)).to.be.true;
        expect(/mimosa-autoprefixer/.test(log)).to.be.true;
        expect(/mimosa-asset-cache-bust/.test(log)).to.be.true;
      });

      it("the old module version in red", function() {
        var colorString = color("0.4.0", "red");
        expect(log.indexOf(colorString) > 0).to.be.true;
      });
    });
  });
});