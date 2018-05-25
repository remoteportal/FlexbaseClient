#if node
fs = require 'fs'
path = require 'path'
#elseif rn
#import Expo, { FileSystem, SQLite } from 'expo'
#endif

A = require './A'
Base = require './Base'
O = require './O'
trace = require './trace'
UT = require './UT'
util = require './Util'


#if ut
class StoreUT extends UT
	constructor: ->
		super "StoreUT"

	run: ->
		@a "HELP", (ut) ->
			store = factory "/tmp/StoreUT"
			ut.resolve()

		@a "concurrent writes", (ut) ->
#			@log "****777** hello: #{@peter}"
#			@log "hello"

			a = []

			store = factory "/tmp/ConcurrentWrites"
			store.init()
			.then =>
				a.push store.write 1, a:"first"
				a.push store.write 1, a:"second"
				a.push store.write 1, a:"third"
				a.push store.write 2, b:"b value"
				a.push store.write 3, c:"c value"

				Promise.all a
			.then (a2) =>
#				@log "all written", a2

				a = []

				a.push store.read 1
				a.push store.read 1
				a.push store.read 1
				a.push store.read 2
				a.push store.read 2
				a.push store.read 3

				Promise.all a
			.then (a2) =>
#				@log "all read", a2
				ut.resolve()
			.catch (ex) =>
				@logCatch "How I got rid of long-term plantar fasciitis", ex

#			@log "exit but may still have stuff running"

		@a "2nd", (ut) ->
#			@log "2nd"
			ut.resolve()
#endif




class Store extends Base
	constructor: (@directory) ->
		super "IGNORE"
		@log "Store: directory=#{@directory}"																	if trace.CONSTRUCTORS
		@map = {}


	destroy: ->
		@log "DESTROY"


	init: -> util.fs_directoryEnsurePromise @directory


	json: (substitute) -> path.join @directory, "#{substitute}.json"


	metaCreateAndCache: (__id) ->
		@map[__id] =
			o: null
			bReading: false
			readList: []
			writeList: []

# read object.  If subsequent read while first read in progress then queue and notify once first is finished
#SIG: get(__id, ~degree)... look at piece of paper...
	read: (id) ->
		new Promise (resolve, reject) =>
			unless meta = @map[id]
				meta = @metaCreateAndCache id

			if meta.o
#				@log "get #{id} hit"
				resolve meta.o
			else if meta.bReading
#				@log "get #{id} read in progress"
				meta.readList.unshift
					resolve: resolve
					reject: reject
			else
#				@log "get #{id} read from disk"

				meta.bReading = true
#if node
				fs.readFile @json(id), (err, data) =>
#elseif rn
#				Expo.FileSystem.readAsStringAsync(@json("object#{id}")).then (json) =>
#				o = JSON.parse json
#endif
#					@log "get #{id} done: #{data.length} bytes"

					notify = (method, o) ->
						meta.bReading = false
						for reader in meta.readList
							reader[method] o
						meta.readList.length = 0

					if err
						@logWarning "readFile", err
						notify "reject", data
						reject err
					else
						meta.o = data
						resolve data
						notify "resolve", data



	write: (id, o) ->
		#OPTIMIZE: no reason to write intermediate copies
		new Promise (resolve, reject) =>
			unless meta = @map[id]
				meta = @metaCreateAndCache id

#			@log "#{meta.writeList.length} in progress"
			meta.writeList.unshift
				o: o
				resolve: resolve
				reject: reject

			if meta.writeList.length is 1
				fnWriteNextObject = =>
#if node
					fs.writeFile @json(id), JSON.stringify(o), (err) =>
#elseif rn
#						Expo.FileSystem.writeAsStringAsync flexbase_HELP.path("object#{@id}"), json
#endif
#							@log "write done"
						rec2 = meta.writeList.pop()

						if err
							@logError "writeFile", err
							rec2.reject err
						else
#							@log "succ: #{meta.writeList.length}"
							rec2.resolve id
							if meta.writeList.length > 0
#								@log "more waiting!"
								o = meta.writeList[0]
								fnWriteNextObject()
				fnWriteNextObject()


factory = (directory) ->
	new Store directory






module.exports =
#if ut
	UTRun: -> new StoreUT().run()
#endif

	factory: factory