#if NODE
Base = require './Base'
ClientFB = require './ClientFB'
trace = require './trace'
util = require './Util'
#endif


#H: deprecate?  value?
class TestClient extends Base
	constructor: (@testHub) -> super "TestClient"

	#TODO: deprecate necessity to call start()... it's just an extra step I'll forget to do
	start: ->
		@log "START #{@testHub.URLGet()}"															if trace.TEST_CLIENT or 1

		@client = new ClientFB @testHub.c, "/tmp/ut/TestClient"

		@client.start @testHub.URLGet()

module.exports = TestClient

