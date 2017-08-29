chai = require 'chai'
assert = chai.assert
sinon = require 'sinon'
chai.use require 'sinon-chai'
Taskmaster = require('../src/objectTemplate')
expect = chai.expect

describe 'object template', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()
      brain: {
        on: sinon.spy()
        set: sinon.spy()
      }

    @objectTemplate = ObjectTemplate(@robot)

  it 'registers appropriate respond listeners', ->
    expect(@robot.respond).to.have.been.calledWith(/task create (.*)/i)
