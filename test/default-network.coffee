expect = require('chai').expect
defaultNetwork = require('../src/default-network')
net = require('net')
os = require('os')

describe 'default-network', ->
  describe 'get()', ->
    data = null
    before (done) ->
      defaultNetwork.get (error, result) ->
        return throw error if error
        data = result
        done()
    it 'returns an data object', ->
      expect(data).to.be.an.any('object')
    describe 'data', ->
      it "includes 'defaultInterface'", ->
        expect(data).to.include.keys('defaultInterface')
      it "includes 'defaultGateway'", ->
        expect(data).to.include.keys('defaultGateway')
      describe 'defaultInterface', ->
        it "is included in os.networkInterfaces()", ->
          expect(os.networkInterfaces()).to.include.keys(data.defaultInterface)
      describe 'defaultGateway', ->
        it "is IP", ->
          expect(net.isIP(data.defaultGateway)).to.be.not.zero
