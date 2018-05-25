#if node
WebSocket = require 'ws'

A = require './A'
Base = require './Base'
Classes = require './Classes'
O = require './O'
Store = require './Store'
trace = require './trace'
UT = require './UT'
util = require './Util'
#endif




#if ut
#flexbaseAuth = require './flexbaseAuth'		#H
#TestClient = require './TestClient'



#TRIED to move to FlexbaseCoffee.coffee
#33:02 DEV 18-04-20.2 (0.0.95) [0] connect ::ffff:73.53.168.153
#
#curl ifconfig.me
#73.53.168.153
#
#http://www.skillsplanet.com:3366



class FBClientNodeUT extends UT
	run: (@testHub) ->
#		@log "CLOUD3=#{@testHub.c.CLOUD}"


		@s "HELP", ->
			@a "get", (ut) ->
				@client = new FBClientNode @testHub.c, "/tmp/ut/FBClientNodeUT_get"
				@client.start null
				.then =>
					@client.get 1
				.then (fo) =>
					@log "read", fo
					@log fo.pi()
					@eq fo.pi(), 3.1415926
					ut.resolve()
				.catch (ex) =>
#					O.DUMP ex
					if ex.code is "ENOENT"
#						@log "correct"
						ut.resolve()
					else
						@logCatch @context, ex
						ut.reject ex


#		@_s "future", ->
#			@_a "register + create obj + re-login + get", (ut) ->
#				@sess.clear()
#
#				@testHub.init @testHub.NEW_DB_NEW_CLIENT
#				.then (db) =>
#					@log "got fresh db: #{db.about}"
#					@testHub.clientFBCCreateUserRandomRegister()
#				.then (fbc) =>
#					@sess.fbc = fbc
#					O.DUMP @sess.fbc.user
#					@sess.user = fbc.user
#
#					fbc.create
#						flavor: "chocolate"
#					.then (first) =>
#						@sess.first__id = first.__id
#						@eq first.__id, 2
#						@sess.fbc.localDataCompletelyErase()
#					.then =>
#						@sess.fbc.userLogout()
#					.then =>
#						@testHub.clientFBCUserLogon @sess.user.username, @sess.user.password
#					.then (fbc) =>
#						@sess.fbc = fbc
#						@sess.fbc.get @sess.first__id
#					.then (first) =>
#						@eq first.__id, 2
#						@eq first.flavor, "chocolate"
#						ut.resolve()
#				.catch (ex) =>
#					@logCatch null, ex

		@_s "FIFO queue to server", ->
#endif



logBase = util.logBase

cn = -1

class FBClientNode extends Base
	constructor: (@c, @directory) ->					#H: FBClientNode shouldn't know about @c
		super "FBClientNode"
		@log "FBClientNode: #{@c} #{@directory}"													if trace.CONSTRUCTORS
		throw "c req" unless @c
		throw "directory req" unless @directory
		@cn = ++cn
		@store = Store.factory @directory
		@bSocketListenerRunning = false


	ensure: (cn) ->
		new Promise (resolve, reject) =>
			@log "ensure: cn=#{cn}"
			#TODO


	get: (id) ->
		new Promise (resolve, reject) =>
			@store.read id
			.then (o) =>
				@log "c", Classes

#HACK
				o.__cn = "SmileSpeak.App"
				if clo = Classes[o.__cn]
	#						@log "xxx=#{clo.meta.bSingleton}"

	#						ttt = JSON.stringify clo.meta
	#						@log "ttt=#{ttt}"
					@log "found", clo
					@log "found", clo.meta
#					@log "j=#{clo.meta.john()}"
					# meta
					# verion0
					# / NODE_LOCAL
					# / p
					# / activity
					# cn, enumValues, required

					version = 0
					while clo["version#{version+1}"]
						version++
					@log "version=#{version}"
					here = "NODE_LOCAL"		#H
					region = clo["version#{version}"][here]
					@log "region", region
					@log "region.p", region.p
					@log "region.m", region.m

					for k,v of region.m
						o[k] = v

					resolve o
				else
					@logWarning "not found: #{o.__cn}"
			.catch (ex) =>
				@logWarning "get:", ex
				reject ex



	one: "TODO"		#H


	sendToServer: (fo) ->
		@log "sendToServer"
		#TODO


	start: (@URL) ->
		new Promise (resolve, reject) =>
#			@log "START: #{@URL}"

#			O.DUMP @c

			@store.init()
			.then =>
#				@log "&&&&&&&&&&&&&&&&&&&&& created #{path}: err=#{err}"

				if @bSocketListenerRunning
					if @ws
						throw "already started!"
					else if @URL
						@mOnline = 0
						@uptimeBeg = Date.now()		#H
						@bConnected = false
						@bNoConnectionDisplayed = false
						@attemptCnt = 0
						@connectedCnt = 0

						#TODO: clearInterval @thread
						@thread = setInterval =>
								@log "[#{@attemptCnt}] ws=#{@ws} PROD=#{@c.PROD} mOnline=#{@mOnline}"			if trace.INTERNET_NOISE #or true

								unless @ws
									@attemptCnt++

									@log "[#{@attemptCnt}] attempting to connect to WebSocket #{@URL}"			if trace.INTERNET_NOISE
									@mOnline = 1

									# https://github.com/websockets/ws
									@ws = new WebSocket @URL

									@ws.onopen = =>
										@connectedCnt++

										@log "Internet connected!! connectedCnt=#{@connectedCnt}"				if trace.INTERNET

			#							@ws_onopen();

										@ws.send JSON.stringify
											cmd: "c-fb-hi"
											connectedCnt: 0
											attemptCnt: @attemptCnt
											clientUpMinutes: 0
											cn: @cn

										@bConnected = true
										bNoConnectionDisplayed = false
										attemptCnt = 0

										@mOnline = 2


									@ws.onmessage = (e) =>
										@log "msg", e.data
										o = JSON.parse e.data
										if o.target is "flexbase"
											@log "FB: onmessage: #{e.data}"
			#							if @ws_onmessage o
			#								@mOnline = 3

									@ws.onerror = (ex) =>
										@log "onerror"
										if ex.message.includes "Connection refused"				# The operation couldn’t be completed. Connection refused
											unless bNoConnectionDisplayed
												@log "No Internet connection"
												this.mOnline = 4
												#TODO: display to user
												bNoConnectionDisplayed = true
										else
											@logError "onerror: #{ex.message}", ex
										# util.dumpSafeRecursive(ex);
										# 1001 websocket "stream end encountered"
										# https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent
										# 1000: Normal closure; the connection successfully completed whatever purpose for which it was created.

										@ws = null		# RECENT2

									@ws.onclose = (ex) =>
										@log "onclose", ex

										if @bConnected
											_ = "onclose: code=#{ex.code} reason=#{ex.reason}"
											unless onCloseErrorMap[_]
												onCloseErrorMap[_] = true
												log(_)
			#								@ws_onclose()
											@ws = null
							,
								1000
				@logWarning "start() exiting because @bSocketListenerRunning=false"
				resolve()
			.catch (ex) => @logCatch "tank of gas", ex
	stop: ->
		@log "stop"
		@bSocketListenerRunning = false




#if ut
	s_ut: (testHub) ->
#		@log "CLOUD2=#{testHub.c.CLOUD}"
		new FBClientNodeUT().run testHub, "/tmp/ut/tests"	#H
#endif


module.exports = FBClientNode
