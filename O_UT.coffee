#if node
#elseif rn
#import Expo, { FileSystem, SQLite } from 'expo'
#endif

O = require './O'
trace = require './trace'
UT = require './UT'




# THIS REQUIRED A separate FILE FROM UT.coffee because of a perceived cyclical dependency problem



#if ut
class OUT extends UT
	constructor: ->
		super "OUT"

	run: ->
		@s "LOG", (ut) ->
			@t "(LOG)simple", (ut) ->
				if trace.UT_TEST_LOG_ENABLED
					O.LOG null
					O.LOG 3.1415926
					O.LOG a:"a"
					O.LOG ["a","b"]
					O.LOG [[[["a","b"],"c"],"b"],"c"]

					o = {}
					o.z = "some value"
					o.a = "some value"
					o.q = "some value"
					o.k = "some value"
					o.r = "some value"
					for p of o
						@log "p=#{p}"
					O.LOG o
			@t "(LOG)multiple parameters", (ut) ->
				if trace.UT_TEST_LOG_ENABLED
					O.LOG "peter", "charles", "alvin"
					O.LOG {"a":"peter"}, {"b":"charles"}, {"c":"alvin"}
#endif




module.exports =
#if ut
	UTRun: -> new OUT().run()
#endif