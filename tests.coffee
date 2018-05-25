CLOUD = false
PROD = false
CONCURRENT_COUNT = 2
RUN_ALL_UT = true


# isomorphic code, which runs both under NodeJS and the browser, has exploded.
# https://medium.com/@giltayar/native-es-modules-in-nodejs-status-and-future-directions-part-i-ee5ea3001f71
# https://nodejs.org/api/esm.html


Base = require './Base'
FBClientNode = require './FBClientNode'
Classes = require './Classes'
Store = require './Store'
TestHub = require './TestHub'
TestClient = require './TestClient'
trace = require './trace'
UT = require './UT'
util = require './Util'
V = require './V'

c =				#H: spell out context
	CLOUD: CLOUD
	PROD: PROD			#H semantics is weird between PROD and UT
	UT: true
	directory: "/tmp/ut/c"


class GenericUT extends UT


	# commit messages  23-34 (pass-fail)

#MOVE: TO PROOF
array1 = [
	'a'
	'b'
	'c'
]
#array1.forEach (element) ->
#	console.log element



new (class Tests extends Base
	constructor: ->
		super "Tests"

		testHub = new TestHub c
		testHub.resetSync()
		util.fs_directoryEnsurePromise "/tmp/ut"
		.then =>
			console.log "\n\n\n\n\n########## RUN ##########"

			#H: FIX: divorice TestHub from HT but somehow give a fresh TestHub for each test
			# overall, NOT a particular test
			# only for transport of UT server communication
			# uses a Flexbase system account
			testHub.startClient "hub"
#				.then => @log "database created"
			.catch (ex) => @logFatal "start", ex

			if 0 or RUN_ALL_UT
				@client = new FBClientNode testHub, "/tmp/ut/FBClientNode"
				@client.s_ut testHub		#H do real static

			if 1 or RUN_ALL_UT
				Store.UTRun()

			if 0 or RUN_ALL_UT
				ut = new UT testHub
				ut.ut testHub

			if 0 #or RUN_ALL_UT
				clients = []

				for n in [1..CONCURRENT_COUNT]
					tc = new TestClient testHub
					clients.push tc.start()

			if 0 or RUN_ALL_UT
				for fq,clo of Classes
	#				version = 0
	#				while clo["version#{version+1}"]
	#					version++
	#				@log "[#{fq}] version=#{version}"
	#
	#				if latest = clo["version#{version}"]
					if latest = util.latestGet clo
						here = "NODE_LOCAL"		#H
						if region = latest[here]
							if region.ut
	#							@log "[#{fq}] found unit test"

			#					class GenericUT extends UT {}
			#					TypeError: Class constructor UT cannot be invoked without 'new'

			#					for k,v of region.ut()
			#						GenericUT[k] = v

								some = new GenericUT()
								some.ut = region.ut
			#					some.ut.name = "XXX"		#H TypeError: Cannot assign to read only property 'name' of function 'function (testHub) {
								some.ut testHub
						else
							@logError "[#{fq}] Unsupported deployment target", clo, true


			ut = new UT false, (eventName, primative, utParameter, objectThis) =>	#  bRunToCompletion @fnCallback "pre", "t", utParameter, objectThis
	#			@log "UT EVENT: #{eventName} #{primative}"
				utParameter.say_hi_to_peter = "Hi Pete!"
				objectThis.testHub = testHub
			ut.run testHub			#H
	#		.then => @log "all tests done"
			.catch (ex) => @logFatal "ut.run", ex
		.catch (ex) => @logFatal "tests", ex
)()