expect = require('chai').expect
defaultNetwork = require('../src/index')
net = require('net')
os = require('os')

describe 'default-network', ->
  describe 'collect()', ->
    data = null
    before (done) ->
      defaultNetwork.collect (error, result) ->
        data = result
        done(error)
    it 'is an data object', ->
      expect(data).to.be.an.any('object')
    it "has interface names which are included in os.networkInterfaces()", ->
      for iface, values of data
        expect(os.networkInterfaces()).to.include.keys(iface)
    it 'has values which include a family and an address', ->
      for iface, values of data
        for value in values
          expect(['IPv4', 'IPv6']).to.include(value.family)
          switch value.family
            when 'IPv4'
              expect(net.isIPv4(value.address)).to.be.true
            when 'IPv6'
              expect(net.isIPv6(value.address)).to.be.true
