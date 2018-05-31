Classes = require './Classes'
trace = require './trace'
O = require './O'
S = require './S'
trace = require './trace'
util = require './Util'
V = require './V'


# shared between Flexbase client, server, etc.







module.exports =
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

			__log: ->
#				logBase "Object #{@__id}#{if @__cn then " <#{@__cn}>" else ""}", s, o
				util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME ? "FO", arguments...]

			__save: ->
				new Promise (resolve, reject) =>
#					@__log "__save", this
#					@__log "__save #{@__notifyUpdateFN}", @__notifyUpdateFN

					if @__bDirty
						@__log "__save #{@__id}"		if trace.SAVE_ID

						@__bDirty = false

#						O.LOG this
#						@__log "A"
#						O.LOG @__client
#						@__log "B"
#						O.LOG @__client.strip
#						@__log "C"

						#TODO: look in config.targetMap
						stripped = @__client.strip this

						# snapshot = Object.assign {}, stripped.... ==> json *is* the snapshot
						json = JSON.stringify stripped

#						if @__id > 0
#							config.upList.push this

						#						@__log "__save: upQ=#{config.upList.length}", stripped
						#						@__log "save: DONE", stripped
#						Expo.FileSystem.writeAsStringAsync flexbase.path("object#{@__id}"), json
						@client.store.write @__id, json
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

		@config.targetMap[ target.__id ] = target

		proxy = new Proxy target, handler
		@config.proxyMap[ proxy.__id ] = proxy
		proxy

		
#	createSingletonByClass: (cn) ->
#		@log "createSingletonByClass"
#		@log "work? #{@config.authenticateID}"


	createSingletonByClass: (cn) ->
		buildObject = (cn, target) =>
			@log "buildObject: #{cn}"

			#MOVE: do integrity checking at startup
			#TODO: @enumCheck
#			util.enumCheck target, "NODE_SERVER_RPC,two,three"

			new Promise (resolve, reject) =>
				if clo = Classes[cn]
					if (latest = util.latestGet clo)?
#						@log "latest", latest, true

						if target is "NODE_CLIENT"
							fo = @objectNew()

							# create RPC proxy

							if region = latest["NODE_SERVER_RPC"]
	#							@log "found region"

								#TODO: scan all objects to see if one already has the correct type
								if false
									found=true
								else
	#								O.LOG region.m
#									for pn,pv of region.m
#										fo[pn] = region.m[pn].bind this

									#HERE
									for pn,pv of region.m
#										fo[pn] = =>
											# package arguments
#											start sync call
											@log "I am a proxy"

									resolve fo
	#							region.m   WHAT IS THIS?
							else
								throw "region not found"
						else
							@logFatal "target not supported yet: #{target}"
					else
						throw "not find latest"
				else
					throw "#{cn} not found"

		# what is my situation?
#		O.LOG this
		@log "I am: #{@__CLASS_NAME}"	# ClientFB

#		new Promise (resolve, reject) =>
		buildObject cn, "NODE_CLIENT"	#WARNING
#			.then (fo) =>
##				@log "got", fo, true
#
#				#H #WRONG_PLACE!
#				fo.emailHold "a@b.c"
#				.then (emailHoldID) =>
#					@log "emailHoldID",
#						emailHoldID: emailHoldID
#				.catch (ex) =>
#					resolve "buildObject", ex
#
#				resolve fo
#			.catch (ex) =>
#				resolve "objectNew", ex



	dateFlexCur: ->
		#TODO: coordinate with server
		new Date() * 1

	objectNew: (cn) ->
#		@log "objectNew"
		fo =
			__bDirty: true
			__client: this
			__cn: cn
			__dateCreated: @dateFlexCur()
			__id: @config.newID--		# start -1
			__state: "CREATED"

	strip: (o) ->
		@log "strip #{o.__id}"

		one = (v, k) =>
			@log "one: #{V.KV k, v}"
			
			type = V.TYPE v

			if type is 'Date'
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
					@logFatal "NOT FLEXBASE OBJ", v
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
					throw "NOTSUP"
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

		@log "done......", out
		out


	targetCheck: (target) -> S.enumCheck target, "ALL,FUSE,NODE_CLIENT,NODE_SERVER,NODE_SERVER_RPC,RN_LOCAL,WEB"

		
		
