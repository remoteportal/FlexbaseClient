#if NODE
Base = require './Base'
FBClientNode = require './FBClientNode'
trace = require './trace'
util = require './Util'
#endif


#H: deprecate?  value?
class TestClient extends Base
	constructor: (@testHub) -> super "TestClient"

	#TODO: deprecate necessity to call start()... it's just an extra step I'll forget to do
	start: ->
		@log "START #{@testHub.URLGet()}"															if trace.TEST_CLIENT

		@client = new FBClientNode @testHub.c, "/tmp/ut/TestClient"

#		@log "[#{attemptCnt}] attempting to connect to WebSocket #{URL}"
		@client.start @testHub.URLGet()

module.exports = TestClient

