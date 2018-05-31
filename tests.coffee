CLOUD = false
PROD = false
CONCURRENT_COUNT = 2		#MOVE: TO OPTIONS
RUN_ALL_UT = 1
bRunToCompletion = true

OPTS =
	timeout: 6000
	perTestOpts:
		ServerUT:
			blah: "blah blah"
		UTUT:
			aaa: "AAA"
			bbb: "BBB"

###
tests - run all unit tests


USAGE:
cd /Users/pete/gitlab/rn/API/Flexbase
node tests.js


EXTENDS: Base


DESCRIPTION



FEATURES
-


NOTES
force stack dump ---> throw new Error "XXX"


TODOs
- file-based individual test configurations: node test.js runall
- after completion, copy all /tmp/ut files to the current logging directory
- throw Error		every time


KNOWN BUGS:
-
###


	

fs = require 'fs'


Base = require './Base'
ClientFB = require './ClientFB'
Classes = require './Classes'
Client = require './Client'
ClientFB = require './ClientFB'
ClientSync = require './ClientSync'
Date = require './Date'
N = require './N'
O = require './O'
O_UT = require './O_UT'
Proof = require './Proof'
Server = require './Server'
ServerFB = require './ServerFB'
ServerSync = require './ServerSync'
Store = require './Store'
TestHub = require './TestHub'
TestClient = require './TestClient'
trace = require './trace'
UT = require './UT'
util = require './Util'
V = require './V'
VUT = require './VUT'



c =				#H: spell out context
	CLOUD: CLOUD
	PROD: PROD			#H semantics is weird between PROD and UT
	UT: true
	directory: "/tmp/ut"


class GenericUT extends UT

logFN = "/Users/pete/logs/#{Date.dateTimeHyphenated()}.txt"

c.logStream = fs.createWriteStream logFN, 'flags': 'a'
c.logStream.write "--BOF--\n"
util.streamSet c.logStream


O.LOGIgnore["__client"] = true
O.LOGIgnore["logStream"] = true
O.LOGIgnore["thread"] = true
#O.LOGIgnore["_idleNext"] = true			# thread
#O.LOGIgnore["_idlePrev"] = true			# thread
O.LOGIgnore["ws"] = true				# web socket





new (class Tests extends Base
	constructor: ->
		super "Tests"

		testHub = new TestHub c
		testHub.resetSync()
		util.fs_directoryEnsurePromise "/tmp/ut"
		.then =>
			console.log "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n########## RUN ##########"

			#H #FIX: divorce TestHub from HT but somehow give a fresh TestHub for each test
			# overall, NOT a particular test
			# only for transport of UT server communication
			# uses a Flexbase system account
#			testHub.startClient "hub"
#				.then => @log "database created"
#			.catch (ex) => @logFatal "start", ex



			if 0 or RUN_ALL_UT
				Client.s_ut()
			if 0 or RUN_ALL_UT
				ClientFB.s_ut testHub
			if 0 or RUN_ALL_UT
				ClientSync.s_ut()


			if 0 or RUN_ALL_UT
				Server.s_ut()
			if 1 or RUN_ALL_UT
				ServerFB.s_ut()
			if 0 or RUN_ALL_UT
				ServerSync.s_ut()



			if 0 or RUN_ALL_UT
				Store.UTRun()

			if 0 or RUN_ALL_UT
				UT.ut testHub

			if 0 or RUN_ALL_UT
				O_UT.UTRun()
			if 0 or RUN_ALL_UT
				VUT.s_ut()


			if 0 or RUN_ALL_UT
				Proof.s_ut()

#H: needs lots of love
#			if 1 #or RUN_ALL_UT
#				@log "RUNNING CONCURRENCY TEST"
#
#				clients = []
#
#				for n in [1..CONCURRENT_COUNT]
#					tc = new TestClient testHub
#					clients.push tc.start()

			if 0 or RUN_ALL_UT
				for fq,clo of Classes
					if latest = util.latestGet clo
						#H: should only run the ones for this target, right?
						for target in ["NODE_CLIENT", "NODE_SERVER","NODE_SERVER_RPC"]
#							@log "target=#{target}"
							if region = latest[target]
								if region.ut
		#							@log "[#{fq}] found unit test"
									some = new GenericUT null, null, null, fq
									some.ut = region.ut
									some.stackReset()
									some.ut testHub
#							else
#								@logFatal "[#{fq}] Unsupported deployment target", clo, true


			ut = new UT bRunToCompletion, (eventName, primative, utParameter, objectThis) =>	#  bRunToCompletion @fnCallback "pre", "t", utParameter, objectThis
			#			@log "UT EVENT: #{eventName} #{primative}"
						utParameter.say_hi_to_peter = "Hi Pete!"
						objectThis.testHub = testHub
					,
						OPTS
			ut.run testHub			#H: don't pass testHub to UT because it's not generic
			.then (frag) =>
#				@log "all tests done"

				c.logStream.end "\n--EOF--"
				util.streamSet null
				fn = logFN.replace ".txt", " #{frag}.txt"
				fs.renameSync logFN, fn
			.catch (ex) =>
				@logFatal "ut.run", ex

				c.logStream.end "\n--EOF WITH ERRORS--"
				util.streamSet null
				@log logFN
				@log "#{logFN} complete"
				fs.renameSync logFN, "#{logFN} complete"
		.catch (ex) => @logFatal "tests", ex
)()