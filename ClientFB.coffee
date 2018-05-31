#if node
WebSocket = require 'ws'

#A = require './A'
Base = require './Base'
Classes = require './Classes'
ClientSync = require './ClientSync'
O = require './O'
N = require './N'
Store = require './Store'
trace = require './trace'
UT = require './UT'
util = require './Util'
#endif





# needs to be transactional: if you object 10 objects then do o.__save() they hae to be done as a transaction!

# Limitations
# - object notify list is very very difficult to manage and expensive to run
# - Flexbase objects can only be properties of other objects or in an array of a property.  Any deeper than that are FB breaks.  Not true... FB objects can store objects as long as THOSE objects are "simple"... don't have pointers to other objects
# - Perhaps unneccessary server to client sycn'ing when the client really doens't want it.
# - With proxy objects: number of objects is at least doubled (more for property arrays)


# NOTES
# - because not writing out configMap keys, currently doesn't support orphan __id's


# MVP 1
# - just Deanna able to send smiles back and forth


# Links
# https://node.green


# TODO
# - slow down timer: wait until response
# - pull objects from server
# - encrypt on disk
# - don't write object unless dirty
# - __state not consistent
# - save object timeout
# - find Fox recording
# - push to client and add record to end of array
# - classes: add methods
# - download only changed properties????
# - if file type is file then generate GUID
# - combine client and server code for code sharing
# - only list of __ properties to write to disk / upload
# - make sure don't begin NEW file write when one is already in progress!
# - remote: disconnected: semantics???????????  what do???
# - remote: shared code between client/server ("LadyBug like")
# - behavior: real class-based objects
# - https://jwt.io?
# - queue up saves if save already in progress
# - verify not uploading any negative __id's
# - if CLOUD is set to false then phone freezes on "Downloading JavaScript bundle 100.00%"
# - testing database use same moniker as object prefix
# - during object create SAVE current property state and queue
# - tsCBegQ, tsCBeg, tsSBeg, tsSEnd, tsCEnd
# - Why are we uploading wrapped objects in create?
# - __save must create snapshot at point of save
# - send metrics in the "connected" event
# - __save shouldn't strip
# - change type to proxyFriend
# - one master trace file per component
# - saveList, upList
# - what if app exits and saveList isn't empty??????
# - Flexbase multi-instance for unit testing
# - try WebSocket again from Flexbase.coffee







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



_resolve = null

class ClientFBUT extends UT
	run: (@testHub) ->
		@s "HELP", ->
#endif




class ClientFB extends ClientSync
	constructor: (@URL, @directory) ->
		super()
		@log "ClientFB: directory=#{@directory}"			if trace.CONSTRUCTORS
		@store = Store.factory @directory

		@config =
			saveList: []
			upList: []
			proxyMap: {}
			targetMap: {}
			newID: -1
			authenticateID: -1
			procID: 0
			rootID: 0
			transaction: null
			bOpen: false
			outQ: []
			readCnt: 0
			transactionList: []

		FBShared = require './FBShared'
		for pn,pv of FBShared
#			@log pn
			this[pn] = pv

		@config.dateCreated = @dateFlexCur()



	configWrite: ->
#		RETURNS PROMISE
#		@log "configWrite", @config
		_ = {}
		for pn,pv of @config
#			@log "**** #{pn}"
##			unless pn in ["proxyMap","targetMap","newID","procID","rootID","transaction","bOpen","transactionList","outQ"]
			if pn in ["authenticateID","username","password","readCnt","rootID"]
				_[pn] = pv
		##			else if pn is "proxyMap"
		##				proxyMap = Object.create null
		##				for __id of pv
		##					proxyMap["HELP"] = 0
		#		@log "configWrite2", _
#		Expo.FileSystem.writeAsStringAsync @path("config"), JSON.stringify _
		@store.write "config", _


	create: (v) ->
		new Promise (resolve, reject) =>
			if typeof v is "string"
				cn = v
				fo = @objectNew cn
#				@log "create", fo

#				@log "I am: #{@__CLASS_NAME}"
				if @__CLASS_NAME is "ClientFB"
					targetName = "NODE_CLIENT"
				else
					throw new Error @__CLASS_NAME

				if clo = Classes[cn]
					if (latest = util.latestGet clo)?
#						@log "latest", latest, true
						
						if targetName is "NODE_CLIENT"
							if region = latest["NODE_CLIENT"]
#								@log "has NODE_CLIENT"
								if region.p
#									@log "props", region.p
									for pn,pv of region.p
#										@log "p: #{pn}"
										fo[pn] = "HELP"

								if region.m
#									@log "methods", region.p
									for pn,pv of region.m
										fo[pn] = pv

							if region = latest["NODE_SERVER_RPC"]
#								@log "NODE_SERVER_RPC"

								if region.m
									# create RPC proxy
									for pn,pv of region.m
										do (pn) ->
											fo[pn] = (->
												@__log "#{pn} PROXY").bind fo

#							@log "DONE DECORATING", fo
							@addMethodsAndCreateProxy fo, true

#				config.targetMap[ o.__id ] = o
#
#				@configWrite()
#				.then =>
#					wrapped = @addMethodsAndCreateProxy o, true
#					config.upList.push o
#					resolve wrapped
#				.catch (ex) =>
#					reject ex
#			.catch (ex) =>
#			@logCatch "create #{JSON.stringify o}: Can't write 'object#{o.__id}.json'", ex
#			reject null

						else
							@logFatal "target not supported yet: #{targetName}"
					else
						throw "not find latest"
				else
					@logWarning "#{cn} not found"
				
				fo.__save()
				.then =>
					resolve fo
				.catch (ex) =>
					reject ex
			else
				throw "NOT-IMPL"
				
	listen: (@bAlive) ->
# @log "listen: bAlive=#{@bAlive}"

		if @bAlive
#PATTERN: super returns promise
			new Promise (resolve, reject) =>
				pr = super @bAlive
				pr.then =>
					@store.init()
					.then =>
						new Promise (resolve, reject) =>
							@store.read "config"
							.then (_config) =>
								for pn,pv of @config
									unless _config.hasOwnProperty pn
										@log "adding: #{pn}"
										_config[pn] = @config[pn]
								_config.readCnt++
								@log "readCnt=#{_config.readCnt}"
								# copy back to keep reference
								for pn,pv of _config
									@config[pn] = _config[pn]
								resolve _config
							.catch (ex) =>
								if ex.code is "ENOENT"
#									@logWarning "Unable to locate; creating one from scratch!"
									resolve @config
								else
									@logCatch "store.read", ex, true
									reject ex
					.then (_config) =>
#						O.LOG _config
						@configWrite()
					.then =>
#						@log "listen chain completed"
						resolve()
					.catch (ex) =>
						@logCatch "store.init", ex
						reject ex
		else
			super false


	onReceive: (o) ->
#		@log "onReceive [DEFAULT]", o
		_resolve o
		throw "_resolve deprecated"
#		@log "_resolve() called"

	sendSync: (o) ->
		new Promise (resolve, reject) =>
			_resolve = resolve
			@store.write "test", sent:"bbb"
			@log "sendSync", o
			@ws.send JSON.stringify o




#if ut
	@s_ut: (testHub) -> new ClientFBUT().run testHub
#endif



module.exports = ClientFB
#################################################################
return































class ClientFBUT extends UT
	run: (@testHub) ->
#		@log "CLOUD3=#{@testHub.c.CLOUD}"

		@_s "negative", ->
			@a "get", (ut) ->
				@client = new ClientFB @testHub.c, "/tmp/ut/FBClientNodeUT_get"
				@client.start null
				.then =>
					@client.get 1
				.then (fo) =>
#					@log "read", fo
#					@log fo.pi()
					@eq fo.pi(), 3.1415926
					ut.resolve()
				.catch (ex) =>
#					O.LOG ex
					if ex.code is "ENOENT"
#						@log "correct"
						ut.resolve()
					else
						@logCatch @context, ex
						ut.reject ex
		@s "positive", ->
			@t "simple", ->




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
#					O.LOG @sess.fbc.user
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

#		@_s "FIFO queue to server", ->
#endif





			
cn = -1

class ClientFB extends Base
	constructor: (@c, @directory) ->					#H: ClientFB shouldn't know about @c
		super "ClientFB"
		@log "ClientFB: #{@c} #{@directory}"													if trace.CONSTRUCTORS
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
					# / NODE_CLIENT
					# / p
					# / activity
					# cn, enumValues, required

					version = 0
					while clo["version#{version+1}"]
						version++
					@log "version=#{version}"
					here = "NODE_CLIENT"		#H
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

#			O.LOG @c

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
								@log "[#{@attemptCnt}] ws=#{@ws} PROD=#{@c.PROD} mOnline=#{@mOnline}"			if trace.SOCKET_NOISE #or true

								unless @ws
									@attemptCnt++

									@log "[#{@attemptCnt}] attempting to connect to WebSocket #{@URL}"			if trace.SOCKET_NOISE
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
	@s_ut: (testHub) ->
#		@log "CLOUD2=#{testHub.c.CLOUD}"
		new ClientFBUT().run testHub, "/tmp/ut/tests"	#H
#endif


module.exports = ClientFB
