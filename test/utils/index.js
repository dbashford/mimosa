var intSpawn = require( "./integration/spawn" )
  , intProcess = require( "./integration/in-process" )
  , commandUtil = require( "./integration/command-util" )
  , utils = require( "./utils" )
  ;

module.exports = {

  setup: {
    projectData: utils.setupProjectData,
    project: utils.setupProject,
    cleanProject: utils.cleanProject
  },

  util: {
    filesAndDirsInFolder: utils.filesAndDirsInFolder
  },

  fake: {
    mimosaConfig: utils.fakeMimosaConfig,
    file: utils.fileFixture,
    program: utils.fakeProgram
  },

  test: {
    registration: utils.testRegistration,
    command: {
      watch: intProcess.watchTest,
      build: intProcess.buildTest,
      clean: intProcess.cleanTest,
      flags: {
        help: commandUtil.commandHelpTest,
        invalid: commandUtil.testBadCommandFlags,
        missingProfile: commandUtil.missingProfile,
        handlesFlags: commandUtil.handlesFlags,
        debugSetup: commandUtil.debugSetup
      },
      spawn: {
        build: intSpawn.buildTest,
        buildClean: intSpawn.buildCleanTest,
        watch: intSpawn.watchTest,
        clean: intSpawn.cleanTest
      }
    }
  }

};