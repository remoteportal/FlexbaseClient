###
ClientSync - communication persistence


EXTENDS: blah


DESCRIPTION


FEATURES
-


NOTES


TODOs
-


KNOWN BUGS:
-
###







#if node
WebSocket = require 'ws'

#A = require './A'
Base = require './Base'
Client = require './Client'
Classes = require './Classes'
N = require './N'
O = require './O'
Store = require './Store'
trace = require './trace'
UT = require './UT'
util = require './Util'
#endif





#if ut
class ClientSyncUT extends UT
	run: (@testHub) ->
		@s "HELP", ->
#endif




_resolve = null

class ClientSync extends Client
	constructor: (@URL, @directory) ->
		super()
		@log "ClientSync: directory=#{@directory}"													if trace.CONSTRUCTORS
#		throw new Error "XXX"
		@sendMap = {}
		@store = Store.factory @directory

	listen: (@bAlive) ->
		@log "listen: bAlive=#{@bAlive}"															if trace.SOCKET_LISTEN

		if @bAlive
			#PATTERN: super returns promise
			new Promise (resolve, reject) =>
				pr = super @bAlive
				pr.then =>
					@store.init()
					.then =>
						resolve()
					.catch (ex) =>
						@logCatch "store.init", ex
						reject ex
		else
			super false


	onReceive: (DO) ->
#		@log "onReceive [DEFAULT]", DO

		#TODO: build @assert into Base class which will throw Error(...)
		unless DO.cmd is "s-to-c"
			@logAssert "DO.cmd: expecting='s-to-c' got=#{DO.cmd}", DO, true
			return

		if rec = @sendMap[DO.GUID]
#			@log "onReceive: found GUID in map", rec, true
			rec.resolve DO
		else
			@logWarning "onReceive: GUID not found", DO


	sendSync: (o) ->
		new Promise (resolve, reject) =>
			DO =	# DO=Disk Object
				cmd: "c-to-s"
				GUID: N.GUIDNew()
				o: o
				resolve: resolve
				reject: reject
				tsCBeg: Date.now()		#H

#			@log "sendSync", DO, true

			@sendMap[DO.GUID] = DO

			@store.write DO.GUID, DO
			.then =>
#				resolve()
			.catch (ex) =>
				@logCatch "store.write", ex
				reject ex

			if @ws
				@send DO
			else
				@logInfo "sendSynx: OFFLINE"





#if ut
	@s_ut: (testHub) -> new ClientSyncUT().run testHub
#endif


module.exports = ClientSync
