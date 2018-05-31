A = require './A'
API = require './API'
Base = require './Base'
O = require './O'
trace = require './trace'
UT = require './UT'
util = require './Util'






argsNode = process.argv.slice 2



class Server_UT extends Base
	constructor: ->
		super()

	listen: ->
		@log "listen"																				if trace.SOCKET_LISTEN
		argsNode.forEach (item) ->
			console.log item






server_UT = new Server_UT()
server_UT.listen()