expect = require('chai').expect
net = require('../src/default-network')

describe 'default-network', ->
  data = null
  before (done) ->
    net.get (error, result) ->
      return throw error if error
      data = result
      console.log data
      done()
  it 'returns an object', ->
    expect(data).to.be.an.any('object')
  it "The object includes keys 'defaultInterface' and 'defaultGateway'", ->
    expect(data).to.include.keys('defaultInterface', 'defaultGateway')
