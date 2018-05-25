TRACE_ID_TRANSLATE = false
TRACE_INTERNET = false		#H
TRACE_INTERNET_NOISE = false		#H
TRACE_PROPERTY_DELETE = false
TRACE_RESET = false
TRACE_SAVE_ID = false
TRACE_UPLIST_EMPTY = false
TRACE_UPLOAD = true



TRACE_ID_TRANSLATE = true
TRACE_INTERNET = true		#H
TRACE_PROPERTY_DELETE = true
TRACE_RESET = true
TRACE_SAVE_ID = true
TRACE_UPLIST_EMPTY = true
TRACE_UPLOAD = true






### FLEXBASE ###

# https://github.com/substack/dnode

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







# export default class HomeScreen extends React.Component
# @navigationOptions =   (@ instead of 'static ')
#	title: 'Home Screen'

import Expo, { FileSystem, SQLite } from 'expo'
import logBase from './Log'
import O from './O'
import Classes from '../Ladybug/Classes'



arraysEqual = (a, b) ->
	if a == b
		return true
	if a == null or b == null
		return false
	if a.length != b.length
		return false
	# If you don't care about the order of the elements inside
	# the array, you should sort both arrays here.
	i = 0
	while i < a.length
		if a[i] != b[i]
			return false
		++i
	true







console.log "##################################################"
console.log "NEW RUN"
console.log "##################################################"


invokeList = []
sendMap = {}





#ws = new WebSocket 'ws://localhost:3366'
#console.log "ws=#{ws}"
#
#
#ws.onopen = =>
#	console.log "Internet connected!"
#
#	ws.send JSON.stringify
#		cmd: "c-fb-hi"
#		connectedCnt: 0
#		attemptCnt: 0
#		clientUpMinutes: 0
#		blonde: 777
#
#ws.onmessage = (e) =>
#	console.log "msg: #{e}"
#
#ws.onclose = (e) =>
#	console.log "msg: #{e}"









send = (cmd, po) ->
	new Promise (resolve, reject) =>
		if flexbase.ws
			_ =
				guid: guid=GUID()
				cmd: cmd
				resolve: resolve
				reject: reject
				tsCBeg: Date.now()

			for pn,pv of po
				_[pn] = pv

			sendMap[guid] = _
			logBase "Flexbase", "send", _					#HERE TRACE
			flexbase.ws.send JSON.stringify _
		else
			console.log "send:OFFLINE"
			reject "OFFLINE"


# opposite: bless
strip = (o) ->
#	console.log "strip #{o.__id}"

	one = (v, k) ->
#		console.log "one: #{v} <#{Object.prototype.toString.call v}>"

		if Object.prototype.toString.call(v) is '[object Date]'
			v.valueOf()
		else if typeof v is 'object'													# if Object::toString.call(v) is '[object Object]'
#			console.log "OBJ"
			if v.__id > 0 or v.__id < 0
#				console.log "FB obj"		#TODO: just replace THAT element
				unless v.__id > 0
					throw "NEGATIVE __ID"
				#HACK: late binding of referenced object's __id: idRecording: recording
#				console.log "#{k} ----- #{v.__id}"
				if k is "idRecording"
					v.__id
				else
					"$$#{v.__id}"
			else
#				console.log "NOT FLEXBASE OBJ"
				v
		else
#			console.log "!OBJ"
			v


	out = {}

	for k,v of o
		if typeof v is "function"
			continue
		else
#			@__log "?? #{Object::toString.call(v)}"
			if Object::toString.call(v) is '[object Array]'
#				@__log "ARRAY"
				#TODO
				v2 = []
#				for item in v
#					v2.push one(item, k)
			else if k in ["__bDirty","__state"]
#				@__log "SKIP: #{k}"
				continue
			else
#				@__log "primitive: #{k}"
				v2 = one v, k

		out[k] = v2

	out


positive = (o) ->
#	console.log "strip #{o.__id}"

	one = (v) ->
#		console.log "one: #{v} <#{Object.prototype.toString.call v}>"

		if Object.prototype.toString.call(v) is '[object Date]'
			v.valueOf()
		else if typeof v is 'object'													# if Object::toString.call(v) is '[object Object]'
#			console.log "OBJ"
			if v.__id > 0 or v.__id < 0
#				console.log "FB obj"		#TODO: just replace THAT element
				unless v.__id > 0
					throw "NEGATIVE __ID"
				"$$#{v.__id}"
			else
#				console.log "NOT FLEXBASE OBJ"
				v
		else
#			console.log "!OBJ"
			v


	out = {}

	for k,v of o
		if typeof v is "function"
			continue
		else
#			@__log "?? #{Object::toString.call(v)}"
			if Object::toString.call(v) is '[object Array]'
#				@__log "ARRAY"
				#TODO
				v2 = []
#				for item in v
#					v2.push one(item)
			else if k in ["__bDirty","__state"]
#				@__log "SKIP: #{k}"
				continue
			else
#				@__log "primitive: #{k}"
				v2 = one v

		out[k] = v2

	out


#TODO: move
GUID = ->		# uuidv4
	'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
		r = Math.random() * 16 | 0
		v = if c == 'x' then r else r & 0x3 | 0x8
		v.toString 16
# console.log uuidv4()


if !Array.isArray
	Array.isArray = (arg) -> Object::toString.call(arg) is '[object Array]'



## config ## MUST BE PRIVATE INSIDE Flexbase
config =
	saveList: []
	upList: []
	proxyMap: Object.create null
	targetMap: Object.create null
	newID: -1
	procID: 0
	rootID: 0
	transaction: null
#	affectedMap: new Map()
	bOpen: false
	GUID: GUID()
	outQ: []
	transactionList: []


notifyList = []



setInterval (-> flexbase.tick()), 1000


#	invokeList.push
#		guid: GUID()
#		resolve: resolve
#		reject: reject
#		fo: this
#		fn: pn
#		args: args
invoke = null
setInterval (->
#	invokeList[0].resolve "A6"
#	console.log "invoke: #{invoke}"

	if invoke is null
		if flexbase.ws and invokeList.length > 0
#			invoke = invokeList.unshift()		#HELP
			invoke = invokeList.pop()

#			console.log "invoke loop: guid=#{invoke.guid}"

			flexbase.ws.send JSON.stringify
				target: "flexbase"
				cmd: "c-fb-invoke"
				guid: invoke.guid
				fn: invoke.fn
				args: invoke.args
	else
		_ = Date.now() - invoke.msStart
#		console.log "invoke: dur=#{_}"
		if _ > 30000
			console.log "RCP TIMEOUT: invoke: dur=#{_} OVER 30s"
			invoke.reject Object.assign invoke,
				dur: _
				error: "TIMEOUT"
#			O.DUMP invoke
			invoke = null
), 5000




FB = null


flexbase =
	log: (s, o) =>			logBase "Flexbase", s, o
	logError: (s, o) =>		logBase "Flexbase", "ERROR: #{s}", o
	logCatch: (s, o) =>		logBase "Flexbase", "CATCH: #{s}", o
		

	adjust: (src, goal) ->
#		@log "adjust"

		added = []
		modified = []
		deleted = []

		# new & modified
		for pn,pv of goal
			if pn[0..1] isnt "__"
				if src[pn]
					# BROKEN
					if Array.isArray src[pn] and Array.isArray pv
						if arraysEqual src[pn] is arraysEqual pv
	#						@log "goal: equal arrays: #{pn}"
						else
	#						@log "goal arrays: NOT equal: #{pn}"
							modified.push pn
							src[pn] = pv
					else if typeof src[pn] is 'object' or typeof pv is 'object'
	#					@log "goal: at least object: #{pn}"
	#					@log "	old: #{src[pn]} => #{JSON.stringify src[pn]}"
	#					@log "	new: #{pv} => #{JSON.stringify pv}"
						#HELP: not super-accurate... check type
						#HELP: misbehaving for arrayw
						if JSON.stringify src[pn] isnt JSON.stringify pv
	#						@log "goal: modify: #{pn}=#{pv}"
							modified.push pn
							src[pn] = pv
					else if src[pn] isnt pv
#						@log "goal: modify: #{pn}=#{pv}"
						modified.push pn
						src[pn] = pv
	#				else
	#					@log "goal: same: #{pn}"
				else
#					@log "goal: new: #{pn}=#{pv}"
					added.push pn
					src[pn] = pv

		# delete
		for pn,pv of src
#			@log "src: #{pn}=#{pv}"

			if pn[0..1] isnt "__" and pn !of goal
				@log "delete: #{pn}=#{pv}"					if TRACE_PROPERTY_DELETE
				delete src[pn]
				deleted.push pn
#			else
#				@log "skip: #{pn}"

		{
			added,
			modified,
			deleted
		}



# load all objects and verify integrity
	check: ->
		new Promise (resolve, reject) =>
			@log "check"
			a = []
			for id,o of config.proxyMap
				@log "read __id=#{id}"
				a.push Expo.FileSystem.readAsStringAsync @path("object#{id}")
			Promise.all(a).then =>
				@log "check: #{a.length} all done"
				resolve()
			.catch (ex) =>
				@logCatch "check: Promise.all", ex
				reject ex


	configWrite: ->
#		@log "configWrite", config
		o = {}
		for pn,pv of config
#			@log "**** #{pn}"
##			unless pn in ["proxyMap","targetMap","newID","procID","rootID","transaction","bOpen","transactionList","outQ"]
			if pn in ["username","password","rootID"]
				o[pn] = pv
##			else if pn is "proxyMap"
##				proxyMap = Object.create null
##				for __id of pv
##					proxyMap["HELP"] = 0
#		@log "configWrite2", o
		Expo.FileSystem.writeAsStringAsync @path("config"), JSON.stringify o

	create: (o) ->
		# @log "create", o

		new Promise (resolve, reject) =>
			o.__id = config.newID--		# start -1
			o.__state = "CREATED"
			o.__dateCreated = new Date()
#			@log "create2", o

			Expo.FileSystem.writeAsStringAsync(@path("object#{o.__id}"), JSON.stringify(o))
			.then =>
#				@log "create3", o

				config.targetMap[ o.__id ] = o

				@configWrite()
				.then =>
					wrapped = @addMethodsAndCreateProxy o, true
					config.upList.push o
					resolve wrapped
				.catch (ex) =>
					reject ex
			.catch (ex) =>
				@logCatch "create #{JSON.stringify o}: Can't write 'object#{o.__id}.json'", ex
				reject null

#TODO: currently loaded vs. all on disk
#TODO: remove Promise
	dump: ->
		new Promise (resolve, reject) =>
#			@log "dump"
			s = "config:\n"
			s += "    newID: #{config.newID}\n"
			s += "    bOpen: #{config.bOpen}\n"
			s += "    transactionList: #{config.transactionList.length} transaction(s)\n"
			for id,o of config.proxyMap
#				s += "[#{id}] #{JSON.stringify o}\n"
#				@log "DUMP", o
				ss = ""
				for pn,pv of o
					if typeof pv is "function"
						continue

					if pn not in ["__bDirty","__cn","__id","__state"]
						ss += "    #{pn}: #{JSON.stringify pv}\n"
				s += "[#{id}] <#{o.__cn}> state=#{o.__state} dirty=#{o.__bDirty}\n#{ss}\n"
			console.log s
			resolve s


	# get(__id, ~degree)... look at piece of paper...
	get: (__id) ->
		new Promise (resolve, reject) =>
			if _=config.proxyMap[ __id ]
#				@log "get #{__id} **** HIT ****"
				resolve _
			else
				@log "get #{__id}"
				Expo.FileSystem.readAsStringAsync(@path("object#{__id}")).then (json) =>
					o = JSON.parse json
					@propertiesLoad o
				.catch (ex) =>
					@logCatch "get #{__id}: Can't find 'object#{__id}.json': #{ex}"

					#TODO: get from server
					#TODO: o.__id = __id
					reject ex

	GUID: GUID

	loggedOn: (config) ->
		new Promise (resolve, reject) =>
#			@log "loggedOn", config

			me = config.rootID

			@get(config.rootID).then (root) =>
# @log "loggedOn #{me}: get.then: root=", root
				resolve root
			.catch (ex) =>
				@logCatch "loggedOn: get", ex
				reject ex

	login: (username, password) ->
		send "c-fb-login",
			username: username
			password: password


	init: (applicationObjectID, appInitialize, CLOUD) ->
#		@log "init"
		new Promise (resolve, reject) =>
			Expo.FileSystem.readAsStringAsync(@path("config"))
			.then (json) =>
				config = JSON.parse json			#WARN
				config.bOpen |= false

#				@log "init: json=#{json}"
				_ = JSON.parse json
				@log "initializing config.json"
				O.DUMP _
#				@log "----------"
				if _.__id > 0
					@loggedOn(_).then (root) =>
#						@log "GOT BBB: root=", root
						resolve root
					.catch (ex) =>
						@logCatch "init: loggedOn caller", ex
						reject ex
				else
					resolve root
			.catch (ex) =>
				if (""+ex).includes("could not be read")
#					@log "init: Can't find: config.json"
				else
					@logError "init: config.json", ex

				@configWrite()
#				.then =>
#					@loggedOn config
				.then (root) =>
					resolve config
				.catch (ex) =>
					@logCatch "init::readAsStringAsync::catch::call configWrite", ex
					reject ex


#	init: (applicationObjectID, appInitialize, CLOUD) ->
##		@log "init"
#		new Promise (resolve, reject) =>
#			Expo.FileSystem.readAsStringAsync(@path("config")).then (json) =>
#				config = JSON.parse json			#WARN
#				config.bOpen |= false
#				config.rootID = 0
#
##				@log "init: json=#{json}"
#				_ = JSON.parse json
#				@log "init"
#				O.DUMP _
##				@log "----------"
#				@loggedOn(_).then (root) =>
##						@log "GOT BBB: root=", root
#					resolve root
#				.catch (ex) =>
#					@logCatch "loggedOn caller", ex
#					reject ex
#			.catch (ex) =>
#				@log "init: Can't find config.json"		# , ex
#
#				@transactionStart()
#				@create username:"remoteportal", password:"1234"				#H
#				.then (root) =>
#					config.rootID = root.__id
#					config.outQ = []
#
##					appInitialize? this, root
#					root.__save()		#WAIT
#
#					#							@log "111", root
#					@configWrite()
#					.then =>
##						@log "222"
#						@loggedOn(config)
#						.then (root) =>
##							@log "333"
#							resolve root		#WRONG: config  #TODO
#						.catch (ex) =>
#							@logCatch "login::readAsStringAsync::catch::create::call configWrite", ex
#							reject ex
#				.catch (ex) =>
#					@logCatch "init: Can't write config.json", ex
#					reject ex

	logoff: ->
		@log "logoff"
		@save()


	notifyPush: (subo) ->
		for subscriber in notifyList
			subscriber subo

	path: (fn) -> FileSystem.documentDirectory + fn + ".json"


	phoneHome: (CLOUD, PROD) ->
		@log "phoneHome"
		
		@uptimeBeg = Date.now()
		@bConnected = false
		@bNoConnectionDisplayed = false
		@attemptCnt = 0
		@connectedCnt = 0

		onCloseErrorMap = {}

		setInterval =>
				@log "[#{@attemptCnt}] ws=#{@ws} PROD=#{PROD} mOnline=#{@mOnline}"					if TRACE_INTERNET_NOISE or true

				unless @ws
					@attemptCnt++

					PORT_WEB_SOCKET=if PROD then 3355 else 3366

					if CLOUD
						URL = "ws://www.skillsplanet.com:#{PORT_WEB_SOCKET}"
					else
						URL = "ws://localhost:#{PORT_WEB_SOCKET}"

					@log "[#{attemptCnt}] attempting to connect to WebSocket #{URL}"				if TRACE_INTERNET_NOISE
					@mOnline = 1

					@ws = new WebSocket URL
#					console.log "ws=#{@ws}"

					@ws.onopen = =>
						@connectedCnt++

						@log "Internet connected!! connectedCnt=#{@connectedCnt}"					if TRACE_INTERNET

						@ws_onopen();
						
						@ws.send JSON.stringify
							cmd: "c-fb-hi"
							connectedCnt: 0
							attemptCnt: 0
							clientUpMinutes: 0
							blonde: 777

						bConnected = true
						bNoConnectionDisplayed = false
						attemptCnt = 0

						@mOnline = 2


					@ws.onmessage = (e) =>
#						@log "msg", e.data
						o = JSON.parse e.data
						if o.target is "flexbase"
							@log "FB: onmessage: #{e.data}"
						if @ws_onmessage o
							@mOnline = 3

					@ws.onerror = (ex) =>
						@log "onerror"
						if ex.message.includes "Connection refused"				# The operation couldn’t be completed. Connection refused
							unless bNoConnectionDisplayed
								@log "No Internet connection"
								this.mOnline = 4
								#TODO: display to user
								bNoConnectionDisplayed = true
						else
							logError "onerror: #{ex.message}", ex
							# util.dumpSafeRecursive(ex);
							# 1001 websocket "stream end encountered"
							# https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent
							# 1000: Normal closure; the connection successfully completed whatever purpose for which it was created.

						@ws = null		# RECENT2

					@ws.onclose = (ex) =>
						@log "onclose", ex

						if bConnected
							_ = "onclose: code=#{e.code} reason=#{e.reason}"
							unless onCloseErrorMap[_]
								onCloseErrorMap[_] = true
								log(_)
							@ws_onclose()
							@ws = null
			,
				10000


	propertiesLoad: (o) ->
		new Promise (resolve, reject) =>
			@log "propertiesLoad #{o.__id}"

			a = []

			myRegexp = /\$\$(.*?)(?:\s|$)/

			for pn,pv of o
#				@log "?? #{Object::toString.call(v)}"
				if Object::toString.call(pv) is '[object Array]'
#					@log "get: ARRAY"
					for item,i in pv
#							@log "ITEM!!! i=#{i}: #{item}"
						if match = myRegexp.exec item
							do (pn, i, id=match[1]) =>
#									@log "RECURSIVE: match=#{match[1]}"
								a.push new Promise (resolve, reject) =>
									@get(id).then( (child) =>
										@log "MICKY MOUSE: #{__id}.get(#{id}): pn=#{pn} i=#{i}", child
										o[pn][i] = child
										resolve();
									).catch( (ex) =>
										@logCatch "#{__id}.get(#{id}): can't get child': #{ex}"
										reject ex;
									)
#							else
#								@log "!RE"
				else if match = myRegexp.exec pv
#						throw "NOT-IMPL"
					@log "get: OBJECT CHILD: #{match[1]}"
					#						getChild match[1]
					do (pn, id=match[1]) =>
#							@log "RECURSIVE: match=#{match[1]}"
						a.push new Promise (resolve, reject) =>
							@get(id).then (child) =>
#									@log "SLEEPY: #{__id}.get(#{id}): pn=#{pn}", child
								o[pn] = child
								resolve();
							.catch (ex) =>
								@logCatch "#{__id}.get(#{id}): can't get child': #{ex}"
								reject ex;

			#				a.push new Promise (resolve, reject) =>
			#					@log "*********** FAKE"

			if a.length > 0
#Q: can you resolve an unfulfilled promise?  after it works just resolve the 'all'
				@log "wait for #{a.length} subgets"
				Promise.all(a).then =>
#						@log "CASE All: #{a.length} all done for #{o.__id}", o
					resolve @addMethodsAndCreateProxy o
				.catch (ex) =>
					@logCatch "Promise.all #{o.__id}", ex
					reject ex
			else
#				@log "CASE DIRECT: done for #{o.__id}", o
				resolve @addMethodsAndCreateProxy o


	register: (username, password, email, fname, lname) ->
		send "c-fb-register",
			username: username
			password: password
			email: email
			fname: fname
			lname: lname

	reset: ->
		@log "*** RESET ***"								if TRACE_RESET
		Expo.FileSystem.deleteAsync @path("config"), idempotent:false


	save: ->
		@configWrite()
#		new Promise (resolve, reject) =>
#			a = []
#			for id,o of config.proxyMap
##				@log "FOUND in config.proxyMap: #{id}"
#				#BUG
#				#WRONG!
#				a.push Expo.FileSystem.writeAsStringAsync(@path("object#{o.id}"), JSON.stringify(o))
#
#			Promise.all(a).then( =>
#				@log "save: (SKIP BECAUSE BUG) wrote #{a.length} objects"
#
#				@configWrite()
#			).then( =>
#				resolve()
#			).catch( (ex) =>
#				@logCatch "save: attempted to write #{a.length} objects", ex
#				reject null
#			)


	space: ""


#	en
# 		"connected"
#		"disconnected"
	subscribe: (fn) -> notifyList.push fn

	
	test: ->
#		@log "sending test"
		send "test"
		
			
	tick: ->
		s = ""
		for fo,i in config.upList
			s += "#{fo.__id},"

#		@log "tick: ws=#{@ws} config.procID=#{config.procID} upQ=#{config.upList.length} #{s}"

		if @ws and config.procID is 0 and config.upList.length > 0
			fo = config.upList.splice(0, 1)[0]

			# all positive?
			bPositive = positive fo


			config.procID = fo.__id

			#TODO: check to see if -1 references
			#TODO: if so, split in two and only save the non-project... queue a subsequent

			cmd = "c-fb-object-#{if fo.__id < 0 then "insert" else "update"}"
#			@log "TICK: #{cmd} #{fo.__id}"
			po = JSON.stringify
				target: "flexbase"
				cmd: cmd
				fo: strip fo			#H: ensure target so don't have to strip
			@log "UPLOAD", po								if TRACE_UPLOAD
			@ws.send po

	transactionStart: ->
		if config.bOpen
			throw "transaction already open"

		transaction =
			affectedMap: new Map()
			bOpen: true			#HELP: in or out?
			GUID: GUID()

		config.transaction = transaction

		config.transactionList.push transaction

		transaction

	unitTest: (@space) ->
		@log "unitTest #{@space}"

		if @space.length > 0
			@reset()

	who: "FlexBase"

	addMethodsAndCreateProxy: (target, __bDirty=false) ->
		throw "already addMethodsAndCreateProxy!!!" if target.__notifyUpdateFN

		wrapper =
			__commit: ->
				@__log "__commit"
				config.transaction.bOpen = false
				#				flexbase.log "see me?"
				#				@__log "bOpen=#{config.transaction.bOpen}"
				#				@__log "bOpen=#{config.transaction.affectedMap}"
				#				config.transaction.affectedMap.set this, this
				flexbase.transactionStart()

			__delete: ->
				@__log "__delete"
				target.__state = "DELETE"
#				config.transaction.affectedMap.set this, this

			__log: (s, o) ->
				logBase "Object #{@__id}#{if @__cn then " <#{@__cn}>" else ""}", s, o

			__save: ->
				new Promise (resolve, reject) =>
#					@__log "__save", this
#					@__log "__save #{@__notifyUpdateFN}", @__notifyUpdateFN

					if @__bDirty
						@__log "__save #{@__id}"		if TRACE_SAVE_ID

						@__bDirty = false

						#TODO: look in config.targetMap
						stripped = strip this

						#HERE
						# snapshot = Object.assign {}, stripped.... ==> json *is* the snapshot
						json = JSON.stringify stripped

						if @__id > 0
							config.upList.push this

						#						@__log "__save: upQ=#{config.upList.length}", stripped
#						@__log "save: DONE", stripped
						Expo.FileSystem.writeAsStringAsync flexbase.path("object#{@__id}"), json
						.then => resolve this
						.catch (ex) -> reject ex
						#LEARNED: MUST MUST MUST call resolve explicitly; can't just return promise (can only do that in promise chain)
					else
#						@__log "__save #{@__id} SKIP"
						resolve this

			__who: ->
				@__log "Object #{@__id}"


		for pn,pv of wrapper
#			@log "ADD: #{pn}=#{pv}"
			target[pn] = pv


		target.__notifyUpdateFN = []

		if target.fname is 'Deanna'
			target.__notifyUpdate = (fn) ->
				target.__notifyUpdateFN.push fn
#				@__log "set2 __notifyUpdateFN: length=#{target.__notifyUpdateFN.length}"
#				@__log "66666666666", target.__notifyUpdateFN

		target.__bDirty = __bDirty

		# C_ client only
		# S_ server only
		# CS_ client calls server
		# SC_ server calls client
		myObj =
			CS_server3: ->
				console.log "CS_server3 called on server!"


		handler = {
#			get: (target, pn) ->
#				console.log("proxy get: #{pn}=#{target[pn]}");
#				target[pn]

			get: (target, pn) ->
				if pn is "server"
					(...args) ->			#WORKS
						"PeTeR"
				else if pn is "server2"
					(s) ->					#WORKS
						s.toUpperCase()
				else if pn is "server3"		#MATCH substring above
					#HELP: what if offline?
					#TODO: MINIMIZE BOILERPLATE
					#NOTE: there are TWO timeouts: waiting in queue to be sent, and time waiting on server.  For now, do both in one
					(...args) ->					#WORKS?
						args = [...args]
#						@__log "server3 ARGS", args
						new Promise (resolve, reject) =>
#							@__log "server3", this

							if flexbase.ws
								invokeList.push
									guid: GUID()
									resolve: resolve
									reject: reject
									fo: this
									fn: pn			#+"!"
									args: args
									msStart: Date.now()
							else
								console.log "server3:OFFLINE"
								reject "OFFLINE"
#
#							# @ws may not be set yet
#							flexbase.ws.send JSON.stringify
#								target: "flexbase"
#								cmd: "c-fb-invoke"
#								fo:
#									hello: "there"

#							resolve
#								aaa: "aaa"
				else
					target[pn]

#			let result = origMethod.apply(this, args);
#				console.log(propKey + JSON.stringify(args)
#					+ ' -> ' + JSON.stringify(result));
#				return result;


			deleteProperty: (target, pn) ->
#				console.log "proxy: deleteProperty: #{pn}"


			set: (target, pn, pv) ->
#				console.log "proxy: set: #{pn}=#{pv} <#{typeof pv}>"

				#DUCK
				if Object::toString.call(pv) is '[object Object]'
					unless pv.__id
						throw "{__id=#{target.__id} property '#{pn}': Cannot assign POJOs to FOs"

#TODO: ignore __id
#				config.transaction.affectedMap.set this, this
				target[pn] = pv
				target.__bDirty = true
		};

		config.targetMap[ target.__id ] = target

		proxy = new Proxy target, handler
		config.proxyMap[ proxy.__id ] = proxy
		proxy




	ws_onopen: ->
		@log "ws_onopen &&&&&&&&&&&&"
		config.procID = 0
		@notifyPush
			en: "connected"
#			ws: @_ws

	#TODO: fbo for flexbaseObject vs. o for just POJO (Plain Old JavaScript Object)
	ws_onmessage: (po) ->
#		@log "ws_onmessage2", po

		unless po.cmd in ["c-fb-hi-ack","c-fb-invoke-ack","c-fb-object-insert-ack","c-fb-object-update-ack","s-fb-object-push"]
#			@log "sendMap-based"
			po.tsCEnd = Date.now()

			# sendAck
			if so = sendMap[po.guid]
#				@log "ack received for '#{po.cmd}' (#{po.tsCEnd - po.tsCBeg}ms)"
				delete sendMap[po.guid]

				switch po.cmd
					when "test-ack"
#						@log "got test"
						so.resolve @addMethodsAndCreateProxy po.user

					when "c-fb-login-ack"
#						@log "c-fb-login-ack", po
#						@log "c-fb-login-ack: user", po.user
						so.resolve @addMethodsAndCreateProxy po.user

					when "c-fb-register-ack"
#						@log "c-fb-register-ack", po
#						@log "c-fb-register-ack: user", po.user
						so.resolve @addMethodsAndCreateProxy po.user
					else
						@logError "unknown client command: '#{po.cmd}' for guid '#{po.guid}'"
			else
				@logError "GUID not found: '#{po.cmd}' for guid '#{po.guid}'"
				for guid of sendMap
					@log "sendMap: guid=#{guid}"

		else
#			@log "not sendMap-based: #{po.cmd}", po
#			return false	#TEST

			switch po.cmd
				when "c-fb-hi-ack"
#						@log "c-fb-hi-ack: #{po}"
					@ws = @_ws
					delete this._ws		#H
					return true	# connected
				when "c-fb-object-insert-ack"
					@log "c-fb-object-insert-ack: #{po.__orig} => #{po.__id}"		if TRACE_ID_TRANSLATE
					if _proxy=config.proxyMap[ po.__orig ]
						_proxy.__id = po.__id
						_proxy.__save()

						_target = config.targetMap[ po.__orig ]

						delete config.targetMap[ po.__orig ]
						delete config.proxyMap[ po.__orig ]

						config.targetMap[ po.__id ] = _target
						config.proxyMap[ po.__id ] = _proxy

						#					if _proxy.__notifyUpdateFN
						#						_proxy.__log "ack: found __notifyUpdateFN"

						if _proxy.fname is 'Deanna'
							@DEANNA_ID = _proxy.__id

						#TODO: re-save ALL objects pointing to it so that they now store the positive __id
						#WORK-AROUND: re-save all objects
						#					@save().then -> config.procID=0
						@save().then =>
							config.procID=0
							@log "upList EMPTY (insert)" 	if config.upList.length is 0 and TRACE_UPLIST_EMPTY
#						@log "c-fb-object-insert-ack: #{po.__orig} => #{po.__id} DONE"
					else
						@logError "c-fb-object-insert-ack: #{po.__orig} => #{po.__id}: can't find orig!"

				when "c-fb-object-update-ack"
#					@log "c-fb-object-update-ack", po
					if _=config.proxyMap[ po.__id ]
#TODO: change state that saved on server
#					_.__save()
						config.procID=0
						@log "upList EMPTY (update)"		if config.upList.length is 0 and TRACE_UPLIST_EMPTY
					else
						@logError "c-fb-object-update-ack: can't find id=#{po.__id}"

					#TODO: create object
				when "s-fb-object-push"
					#				@log "s-fb-object-push", po.fo
					if _=config.targetMap[ po.fo.__id ]
						aa = @adjust _, po.fo
						#					@log "BACK", aa
						#					@log "aa.modified.l=#{aa.modified.length}"
						#					@propertiesLoad(_).then (fo) =>
						#						@log "resolved #{fo.__id}"
						_.__save()
						.then (fo) =>
#							@log "saved #{fo.__id}"

							if fo.__notifyUpdateFN
#								@log "found update notify functions: len=#{fo.__notifyUpdateFN.length}"
								for fn in fo.__notifyUpdateFN
									fn aa
							else
								@log "!DEF __notifyUpdateFN"
							fo.__onUpdate? fo
						.catch (ex) =>
							@logCatch "s-fb-object-push: #{po.fo.__id}: #{ex}"
#						reject ex
					else
#TODO: start from scratch
						@logError "s-fb-object-push: can't find! #{po.fo.__id}"
				when "c-fb-invoke-ack"
					if invoke
						if po.guid is invoke.guid
							if po.error?
								invoke.reject Object.assign invoke,
									dur: _
									error: po.error
							else
								invoke.resolve po
							invoke = null
						else
							@logError "GUID mismatch: #{po.guid} vs. #{invoke.guid}"
					else
						@logError "HELP! c-fb-invoke-ack is received but 'invoke' object is null!!!"
				else
					@logError "Can't find ANY handler for cmd '#{po.cmd}' guid '#{po.guid}'"

		false	# not connected	#H

	ws_onclose: ->
		@log "ws_onclose"
		if @ws
			@notifyPush
				en: "disconnected"
			invokeList = []
			sendMap = {}
			@ws = null

FB = flexbase	#TRY

#if 0
#	try
#		src =
#			a: "a"
#			b: "b"
#			d: []
#		goal =
#			b: "bb"
#			c: "c"
#			d: []
#		flexbase.adjust src, goal
#	catch ex
#		logBase "Flexbase", "CATCH2: UNIT TEST", ex

import UT from '../UnitTest/UnitTest';



export default flexbase