#if node
WebSocket = require 'ws'

A = require './A'
API = require './API'
#ClientFB = require './ClientFB'		#H: why isn't this bold?  The IDE knows something I don't!  SOLN: require it inline, below
Base = require './Base'
O = require './O'
trace = require './trace'
UT = require './UT'
util = require './Util'
#endif




#H
# - how upgrade an object if the new code to handle upgrade isn't deployed EVERYWHERE?  kinda kills the whole concept???
# - what if an object is of a class that isn't implemented in an old app?  	invalidates whole concept???
# need to be able to interrogate object: o.__version is 3
# or o.__supports "voice"			# feature-oriented
# perhaps it's more of a bridge rather than actually modifying the data.  Creating property aliases, etc.
# how to use a new abstraction of old data that older installations still need to rely on contracturally

###
    bottom line as one cannot change the semantics of existing data b/c of old installations
###

###
    Unit Testing

    The UT, for the server, choses either a blank Flexbase database or a database with small user pool
    For local, it chooses either a brand-new install, or a already established user account.
    server: "blank" or "std"
    client: "blank" or "std"

    Everything is logged.... in fact you can do @snap to take a picture of both databases and all object state at that moment in separate data directory
###


#peter =
#	HEllo: "hello"
#	fred: -> "fred"
#console.log "peter: #{JSON.stringify peter}"
#console.log peter.fred()



# ########################################## FLEXBASE ##########################################
module.exports =
	"UT.Peter":
		meta:
			comment: "not sure where to put this class or unit test"
		version0:
			NODE_CLIENT:
				p:
					color:
						cn: "string"
				m:
					cap: (s) ->
						if s.length
							s.charAt(0).toUpperCase() + s.slice(1)
						else
							""
				ut: (@testHub) ->	#COL17
					@a "utPete", (ut) ->
						@log "client rain today"
						ut.resolve()
					@A "simple RPC", (ut) ->
						cleanUp = =>
							@log "cleanUp"
							@testEnv?.destroy()
							@client.listen false
						@testHub.serverFresh()
						.then (@testEnv) =>
							ClientFB = require './ClientFB'
							@client = new ClientFB "ws://localhost:#{@testEnv.port}", @testEnv.clientDirectory
							@client.listen true
						.then =>
							#HERE
							@client.create "UT.Peter"
						.then (fo) =>
#							@log "after create", fo
							@eq fo.cap("fred"), "Fred"
							@log "calling..."
							fo.reverse "Hello"
						.then (reversed) =>
							@log "reversed: #{reversed}"
							if 1
								cleanUp()
								ut.resolve()
						.catch (ex) =>
							@logCatch "simple RPC", ex
							cleanUp()
							ut.reject ex
			NODE_SERVER:
				p:
					serverInfo:
						IP: "127.0.0.0"
				ut: (@testHub) ->	#COL17
					@a "utPete", (ut) ->
						@log "server rain today"
						ut.resolve()
			NODE_SERVER_RPC:
				m:
					reverse: (s) ->
						new Promise (ff, rj) =>
							@log "reverse: #{s}!!!"
							ff s.split("").reverse().join ""


	#H: does this object need to save any data at all?  If not, just create singleton on the fly each time!
	"Flexbase.Authenticate":
		meta:
			bSingleton: true
		version0:
			NODE_CLIENT:
				ut: (@testHub) ->	#COL17
					@a "register", (ut) ->
						cleanUp = =>
							#TODO: return Promise
							@log "cleanUp"
							@testEnv?.destroy()
							@client.listen false

						@testHub.serverFresh()
						.then (@testEnv) =>
#							O.LOG @testEnv
							
#							@log "testEnv: #{@testEnv.infoFN()}"
							ClientFB = require './ClientFB'
							@client = new ClientFB "ws://localhost:#{@testEnv.port}", @testEnv.clientDirectory
							@client.listen true
#						.then =>
#							@log "both listening", @client.config
						.then =>
							@client.config.authenticateID = 55
							@client.configWrite()
						.then =>
							#HERE
							@client.createSingletonByClass "Flexbase.Authenticate"
							.then (auth) =>
								@log "call emailHold"
								auth.emailHold "peter@domain.com"
							.catch (ex) =>
								@logCatch "cr auth", ex
						.then =>
							@log "done", "and again done"
							if 1
								cleanUp()
								ut.resolve()

#							@log "xxx", @client, true
#							@log @client.dateCur()
#						.then =>
#							ut.resolve()
#						.then =>
#							@log "call"
##							@client.createSingletonByClass "Flexbase.Authenticate"
#						.then (fo) =>
#							@log "read", fo
#							ut.resolve()
						.catch (ex) =>
							@logCatch "register chain", ex
#							@testEnv?.destroy()
							cleanUp()
							ut.reject ex
			NODE_SERVER_RPC:
				m:
					emailHold: (email) ->
						@log "emailHold: #{email}"

#						new Promise (resolve, reject) =>
#							c = API.apiFactory()		#DEPRECATED
#							c.query "call emailHold(?)", [email]
#							.then (rsets) =>
#								@log "then", rsets
#								c.d()
#								resolve 1 * rsets[0][0].emailHoldID
#							.catch (ex) =>
#								@logFatal "query", "ex="+ex
#								c.d()
#								reject err
			NODE_SERVER:
				ut: (@testHub) ->	#COL17
					@_a "NOT HERE", (ut) ->
#						@testHub.serverFresh()
#						.then =>
#							ClientFB = require './ClientFB'
#							@client = new ClientFB @testHub.c, "/tmp/ut/register"
##							@client.start null
#						.then =>
#							@log "call"
##							@client.createSingletonByClass "Flexbase.Authenticate"
#						.then (fo) =>
#							@log "read", fo
#							ut.resolve()
#						.catch (ex) =>
#							ut.reject ex



	"Flexbase.Singleton_HELP":
		meta:
			bSingleton: true
		version0:
			NODE_CLIENT:
				p:
					color:
						cn: "string"
				ut: (@testHub) ->	#COL17
					@a "stub", (ut) ->
#						@log "in stub"
#						@log "CLOUD=#{@testHub.c.CLOUD}"
						ut.resolve()

					@a "placeholder", (ut) ->
#						@log "placeholder"
						ut.resolve()



	"Flexbase.Transaction":
		version0:
			ALL:
				p:
					opList:
						cn: "Array"
						itemCn: "Flexbase.Object.HELP"
						required: true
			NODE_CLIENT:
				m:
					commit: ->
						@log "commit"
				ut: (@testHub) ->	#COL17
#					@a "two objects", (ut) ->
#						#MIRACLE OCCURS
#						fb = {}
#
#						fb.tran fb.PROP_GRANULARITY
#						one.abc = "abc"
#						fb.commit()			# fb.rollback()
#
#						# commit adds all the atomic operations to opList
#						# like this:
#						op =
#							__id: 56
#							pList: [
#									pn: "name"
#									v: "Janet"
#								,
#									pn: "zipCode"
#									cmd: fb.DELETE
#							]
#
#
#						commit = ->
#							idx = 0
#							loop
#								op = opList[idx]
#								if op.bLocked
#									@log "HELP: already locked"
#
#						tran = fb.tran()
#						tran.commit()
#						.then =>
#							ut.resolve()
#						.catch (ex) =>
#							@logCatch null, ex
#							reject ex
			NODE_SERVER:
				p:
					opList_HELP:
						cn: "Array"
						itemCn: "Flexbase.Object.HELP"
						required: true
				m:
					commit: ->
						@log "commit"
				ut: (@testHub) ->	#COL17
#					@a "process commit", (ut) ->
#						commit = ->
#							idx = 0
#							loop
#								op = opList[idx]
#								fb.get op.__id
#								.then (o) =>
#									if o.bLocked
#										# allowed to steal away from lower-priority grabbers if not started yet
#									else
#										o.bLocked = true
#
#								if op.bLocked
#									@log "HELP: already locked"
#
#						tran = fb.tran()
#						tran.commit()
#						.then =>
#							ut.resolve()
#						.catch (ex) =>
#							@logCatch null, ex
#							reject ex


	"Flexbase.UT":
		meta:
			bSingleton: true
		version0:
			NODE_SERVER_RPC:
#				m:
#					hello:
#						concurrentAllowed: true
#						fn: (a, b) ->
#						parametersList: [
#								a:
#									type: "int"
#									required: true
#							,
#								b:
#									type: "int"
#									required: false
#						]
				m:
					hello: (a, b) ->
						@log "hello from server: #{a}"
			NODE_SERVER:
				p:
					color:
						cn: "string"
				ut: (@testHub) ->	#COL17
					@a "initialize ut database", (ut) ->
						@log "initialize ut database: #{@testHub.info}"
						@testHub.tablesCreate()
						.then =>
							ut.resolve()
						.catch (ex) =>
							ut.reject()
			NODE_CLIENT:
				p:
					color:
						cn: "string"
#				ut: (@testHub) ->	#COL17
#					@a "initialize ut database", (ut) ->
#						@log "initialize ut database: #{@testHub.info}"
#						@testHub.tablesCreate()
#						.then =>
#							ut.resolve()
#						.catch (ex) =>
#							ut.reject()





# ########################################## SMILESPEAK ##########################################
	# stuff from API
	"SmileSpeak.App":
		meta:
			bSingleton: true
			bStaticOnly: true		# no class data, either #H
		version0:
#			SYNC:					# these are sync'ed across all instantations
#				activity:
#					cn: "Flexbase.Enum"
#					enumValues: "RECORDED"
#					required: true
#			{RN|SERVER|WEB}_{ASYNC_LOCAL_SYNC}:
			NODE_CLIENT:
				p:
					activity:
						cn: "Flexbase.Enum"
						enumValues: "RECORDED,SENT"
						required: true
					user:
						cn: "SmileSpeak.User"
#					move:
#						cn: "Flexbase.User"
#						required: true
				m:
					hello: ->
						log "hello"
					pi: -> 3.1415926
#					deliver: (delivery) ->
#						@__assertClass delivery, "SmileSpeak.Delivery"
#						#H: central queue or per-user?
#						#TODO: add to queue
#						@__fbc.sendToServer delivery
					autoLoginMaybe: ->


					recordingSend: (__idTo, uri, key) ->
						new Promise (resolve, reject) =>
							@log "recordingSend: to=#{__idTo} key=#{key} uri=#{uri}"

							recipient = app.root.friendList.find (o) ->
								o.__id is __idTo

				#			@log "222", recipient

							o =
								__cn: "SmileSpeak.Smile"
								from: @user.__id
								to: __idTo
								key: key

							fb.create o
							.then (recording) =>
				#				@log "333 recording.__id=#{recording.__id}"
								recipient.listOut.push recording
								recipient.__save()
								recording
							.then (recording) =>
								@log "444: recording=", recording
								fb.create
									__cn: "SmileSpeak.Delivery"
									idFrom: root.__id
									idTo: recipient.real__id
									#idRecording: recording.__id
									idRecording: recording
							.then (delivery) =>
								@log "444: delivery has been queued", delivery

								fb.create
									__cn: "SmileSpeak.ActivityEntry"
									activity: "recorded"
							.then (activity) =>
				#				@log "555", root
								root.activityList.push activity
								root.__save()
							.then =>
				#				@log "666"
								fb.save()
								resolve {}
							.catch (ex) =>
								@logCatch "recordingSend", ex
								reject ex
#					friendProxyEnter: (fields) ->			#OLD: friendEnter
#					uploadAudioAsync_DNW: (uri) ->
				ut: (@testHub) ->	#COL17
					@a "stub", (ut) ->
#						@log "in stub"
#						@log "CLOUD=#{@testHub.c.CLOUD}"
						ut.resolve()

					@a "deliver", (ut) ->
#						@log "deliver"
						
						
						ut.resolve()

					


#					"a_friendEnter": (ut, ff, rj) ->		# a=async
#						ut.ss.appFreshInstall()
#						.then (fb) =>
#							fb.get "SmileSpeak.App"
#							.then (ss) =>
#								ss.init fb
#								ss.friendProxyEnter
#									fname: 'Bree',
#									lname: 'Boskovich',
#									phoneNumber: "704-293-4893‬"
#									activity: "recorded"
#							.then (proxy) =>
#								ff()
#							.catch (ex) =>
#								rj ex
#			SERVER_LOCAL:
#				m:
#					peter: -> "peter"
#			SERVER_SYNC:
#				m:
#					ping: (contextDoINeedThisQ_or_po, message) ->
#					ping: (po, message) ->
#						@__log "ping message: #{message}"
#						@__success null,
#							ping: "pong"
#



#	"SmileSpeak.ActivityEntry"
#		version0:
#			SYNC:					# these are sync'ed across all instantations
#				activity:
#					cn: "Flexbase.Enum"
#					enumValues: "RECORDED"
#					required: true
##			{RN|SERVER|WEB}_{ASYNC_LOCAL_SYNC}:
#			RN_LOCAL:
#				attemptToPutPropsAndMethodsTogether:
#					counterForSomething:
#						cn: "int"
#						def: 33
#
#					peter: -> "peter"
#					callPing: ->
#						@ping "hello, this is RN"
#				ut:
#					#H: what are we testing?  Ladybug classes themselves or Flexbase plumbing
#					testA: (context) ->
#						@pass()
#					simple: (context) ->
#						@eq 1, 2		# fail
#					"a_test long": (ut, ff, rj) ->		# a=async
#						ut.fbJunk.create "SmileSpeak.ActivityEntry",		#fbJunk is a random drunk drawer of objects
#							activity: "recorded"
#						.then (ae) =>
#							ut.eq ae.activity, "recorded"
#						.catch (ex) =>
#							rj ex
#			SERVER_LOCAL:
#				m:
#					peter: -> "peter"
#			SERVER_SYNC:
#				m:
#					ping: (contextDoINeedThisQ_or_po, message) ->
#					ping: (po, message) ->
#						@__log "ping message: #{message}"
#						@__success null,
#							ping: "pong"
##			RN_SYNC:
##				m:
##					ping: (, message) ->
##						@__log "ping message: #{message}"
##						@__success null,
##							ping: "pong"








	"SmileSpeak.Delivery":
		version0:
			NODE_CLIENT:
				p:
					smileUserFromID:
						cn: "int"		#TODO: "Flexbase.id"		Will be updated NEG_TO_POS
						required: true
					smileUserToID:
						cn: "int"		#TODO: "Flexbase.id"		Will be updated NEG_TO_POS
						required: true
					smileID:
						cn: "int"		#TODO: "Flexbase.id"		Will be updated NEG_TO_POS
						required: true




	"SmileSpeak.Smile":
		version0:
			NODE_CLIENT:
				p:
					smileUserFromID:
						cn: "int"		#TODO: "Flexbase.id"		Will be updated NEG_TO_POS
						required: true
					smileUserToID:
						cn: "int"		#TODO: "Flexbase.id"		Will be updated NEG_TO_POS
						required: true
				m:
					play: ->
					record: ->
				ut: (@testHub) ->	#COL17
					@a "placeholder", (ut) ->
#						@log "placeholder"
						ut.resolve()



#	record: () ->
##		version1:
##			add:
##				peter: () ->
##			delete:
##				record: ->
##			replace:
#			upgrade_0_1: (v0) ->
#				@log "hey, I'm upgrading"
#				# return v1
#				v0			# no change
#			upgrade_1_2: (v1) ->
#				# return v2
#				peter: 4
#				lastName: v1.lname
#				firstName: v1.fname





	"SmileSpeak.User":
		version0:
			NODE_CLIENT:
				p:
					user:		#H
						cn: "Flexbase.User"
						required: true
					appEngagedMetric:
						cn: "int"
						def: 0
						required: true
					activityList:
						cn: "Array"
						itemCn: "SmileSpeak.ActivityEntry"
						required: true
					friendList:
						cn: "Array"
						itemCn: "SmileSpeak.SmileUserProxy"
						required: true
					tagList:
						cn: "string"
						def: ""
						required: true
					fname:
						cn: "string"		#TODO: "Flexbase.Name"
						def: ""
						required: true
					lname:
						cn: "string"		#TODO: "Flexbase.Name"
						def: ""
						required: true
					phoneNumber:
						cn: "string"		#TODO: "Flexbase.Phone"
						def: ""
						required: true
				m:
					SERVER_SYNC_sayHi: ->
					RN_SYNC_sayHi: ->		# react native version
					WEB_SYNC_sayHi: ->		# website version
					SERVER_ASYNC_ping: ->

					autoLoginMaybe: ->
					friendFindByID: (id) ->
						friend = @friendList.find (fo) ->
							fo.__id is id
					register: (username, password) ->
				ut: (@testHub) ->	#COL17
					@a "stub", (ut) ->
#						@log "in stub"
#						@log "CLOUD=#{@testHub.c.CLOUD}"
						ut.resolve()

					@a "placeholder", (ut) ->
#						@log "placeholder"
						ut.resolve()



	"SmileSpeak.Friend":
		version0:
			NODE_CLIENT:
				p:
					play: () ->	#H
						obj =
							isFavorite: false
							listIn: []
							listOut: []
							fname: 'Deanna'
							lname: 'Boskovich'
							isFavorite: true
							nickname: "girlfriend"
							phoneNumber: "704-293-4893‬"
				m:
					SERVER_SYNC_sayHi: ->
				ut: (@testHub) ->	#COL17
					@a "placeholder", (ut) ->
#						@log "placeholder"
						ut.resolve()





#console.log "in classes"

#if rn
#export default Classes
#endif
