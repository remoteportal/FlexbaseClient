###
O - Object Functions					*** PROJECT AGNOSTIC ***


WHAT: Node module


DESCRIPTION



FEATURES
-


NOTES
-


TODOs
- LOG: pass explicit opts
- LOG: maxDepth option
- LOG: look at arguments.length to see if any passed parameters are undefined or null and PUT IN ALL CAPS!
- LOG: Object.getOwnProperty to show hidden (non-enumerable) properties


KNOWN BUGS:
-
###






#if node
trace = require './trace'
#UT = require './UT'
V = require './V'
#endif





#MOVE: to pre-processor
#H: what are the differences between these?
#UT: UT-ize
CNT = (o) ->
	a = []
	loop
		a.push.apply a, Object.getOwnPropertyNames o
		break unless o = Object.getPrototypeOf o
	a.length
CNT_OWN = (o) -> Object.getOwnPropertyNames(o).length
CNT_ENUM = (o) ->
	n = 0
	n++ for k of o
	n
CNT_ENUM_OWN = (o) -> Object.keys(o).length




KEYS = (o) ->
	a = []
	loop
		a.push.apply a, Object.getOwnPropertyNames o
		break unless o = Object.getPrototypeOf o
	a
KEYS_OWN = (o) -> Object.getOwnPropertyNames(o)
KEYS_ENUM = (o) ->
	a = []
	a.push(k) for k of o
	a
KEYS_ENUM_OWN = (o) -> Object.keys(o)







CLR_ENUM = (o) ->
	for k of o
		delete o[k]
	o
A_CLR_ENUM = ->
	for j in [0..arguments.length-1]
		CLR_ENUM arguments[j]
	return


CONTAINS_INSENSITIVE = (haystack, needle) -> S.CONTAINS_INSENSITIVE ""+haystack, ""+needle


DFS_BREAKABLE = (o, fn) ->								#REC
	bContinue = true
	DFS_ = (o, depth) ->
		for k,v of o
			switch dt = IS.dt v
				when "a"
					unless bContinue = fn o, k, v, dt, depth
						return false

					for V,idx in v
						dt = IS.dt v

						unless bContinue = fn v, idx, V, dt, depth
							return false

						if dt is "o"
							unless bContinue = DFS_ V, depth+1
								return false
					return
				when "o"
					unless bContinue = fn o, k, v, dt, depth
						return false

					unless bContinue = DFS_ v, depth+1
						return false
				else
					unless bContinue = fn o, k, v, dt, depth
						return false
		true
	DFS_ o, 0


	
LOGIgnore = {}
duck = (o) ->
	switch
		when o.hasOwnProperty "__cn"
			"Flexbase object"
		when o.hasOwnProperty "__CLASS_NAME"
			o.__CLASS_NAME
		else
			"OBJ"


#TODO: flag 'undefined' unless opt set
LOG = (o) ->
	DEBUG = 0
	#	iter = 0
	#	MAX_ITER = 100
	MAX_DEPTH = 15
	MAX_PROPERTY_DEPTH = 5

	if DEBUG
		console.log "\n\n\n\n\n\n\n\n\n\n"
		console.log "O.LOG:"
		console.log JSON.stringify o
		console.log "O.LOG: o=#{o} ARRAY=#{Array.isArray o} TYPEOF=#{typeof o}) TYPE=#{Object::toString.call o} JSON=#{JSON.stringify o}"
		console.log "==============================================="

	Q = ">  "

	propertyHitsMap = Object.create null

	bRecurse = true

	log = (p, v, depth) ->
		#TODO: use V.TYPE
		type = Object::toString.call v
		
#		console.log "DEBUG: #{p}=#{v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE2=#{type} JSON=#{JSON.stringify v}"

		#TODO: pass p as parameter
		indent = (s) -> console.log "#{Q}#{" ".repeat depth * 8}#{if depth > 0 then " ∟ " else ""}#{if p.length > 0 then "#{p}:" else ""} #{s}"

		if depth is MAX_DEPTH
			indent "MAX_DEPTH (#{MAX_DEPTH}) exceeded"
			bRecurse = false
			return

		if Array.isArray v
			if v.length is 0
				indent "[]"
			else
				indent "ARRAY (len=#{v.length}):"

				for item,n in v
					log "#{if p.length > 0 and p[0] isnt '[' then "" else ""}[#{n}]", item, depth+1
		else if v instanceof Error
			indent "details:"
			a = Object.getOwnPropertyNames v
			for pn in a
				log pn, v[pn], depth+1
		else if type is '[object Arguments]'
			indent "found arguments (length=#{v.length})"
			for arg,i in v
#				indent "arguments[#{i}] = #{arg}"

#				indent "arguments[#{i}] ===================="
#				LOG arg

				log "arguments[#{i}]", arg, depth+1
		else if type is '[object Object]'
			if cnt = CNT_OWN v
				try
					indent "#{duck v} (#{cnt})"
				catch ex
					indent "duck exception (#{cnt})"

#				for p of v
#					console.log "of: p=#{p}"
#
#				#NOTE: "including non-enumerable properties except for those which use Symbol"
#				for p in Object.getOwnPropertyNames v
#					console.log "Object.getOwnPropertyNames: p=#{p}"

				#TODO: identify non-enumerable properties just because!

				a = Object.keys v

				a.sort()

				for p in a
					if propertyHitsMap[p]?
						if ++propertyHitsMap[p] is MAX_PROPERTY_DEPTH
							indent "########## property '#{p}' has occurred too many times.  Stopped at #{MAX_PROPERTY_DEPTH}.  Circular structure?"
							bRecurse = false
					else
						propertyHitsMap[p] = 1

					if bRecurse
						if LOGIgnore[p]
							log p, "**LogIgnore**", depth+1
						else
							log p, v[p], depth+1
			else
				indent "OBJ EMPTY"
		else
			indent V.DUMP v


	if arguments.length is 0
		console.log "WARNING: LOG wasn't passed anything"
	else if arguments.length is 1
		log "", o, 0
	else
		if true
			objectFoundNbr = 0
			for v,i in arguments
				unless v?
					console.log "#{Q}LOGARG[#{i}]: UNDEFINED"
				else if Object::toString.call(v) is '[object String]'
	#				console.log "#{v}"	# echo plain strings out directly as we find them
					console.log "#{Q}LOGARG[#{i}]: #{V.DUMP v}"
				else
	#				log "#{["1st","2nd","3rd","4th","5th","6th","7th","8th","9th","next","next","next"][objectFoundNbr++]} OBJ PASSED", v, 0
					log "LOGARG[#{i}]:", v, 0
		else
			#TODO: put on a same line
			objectFoundNbr = 0
			for v,i in arguments
				unless v?
					console.log "#{Q}LOGARG[#{i}]: UNDEFINED"
				else if Object::toString.call(v) is '[object String]'
	#				console.log "#{v}"	# echo plain strings out directly as we find them
					console.log "#{Q}LOGARG[#{i}]: #{V.DUMP v}"
				else
	#				log "#{["1st","2nd","3rd","4th","5th","6th","7th","8th","9th","next","next","next"][objectFoundNbr++]} OBJ PASSED", v, 0
					log "LOGARG[#{i}]:", v, 0

	if DEBUG
		console.log "\n\n\n\n\n\n\n\n\n\n"

	return





stringifySafe = (o) ->
	if o isnt null and typeof o is 'object'
		s = ""

		for pn of o
			s += "#{pn}=${o[pn]} "

		s
	else
		o


		


module.exports =
#	CLR_ENUM:CLR_ENUM
#	A_CLR_ENUM:A_CLR_ENUM
#	CONTAINS_INSENSITIVE:CONTAINS_INSENSITIVE
#	DFS_BREAKABLE: DFS_BREAKABLE
#	DELTA: (o0, o1) ->
#		for k of o1
#			delete o0[k]
#		o0
#	DIFF: (a, b) ->												# a-b
#		o = Object.create null
#		for pn in KEYS a
#			o[pn] = b[pn] if pn !of b
#		o




	EQUALS: (o0, o1) ->
		leftChain=rightChain=null								#CLOSURE

		compareTwo = (o0, o1) ->
# remember that NaN===NaN returns false and isNaN(undefined) returns true
#GETTING: 0x800a1389 - Microsoft JScript runtime error: Number expected
#if !(o0 instanceof Object and o1 instanceof Object)
			if Object::toString.call(o0) is "[object Object]" and Object::toString.call(o1) is "[object Object]"
				return true if Object.keys(o0).length is 0 and Object.keys(o1).length is 0
			else
				return true if isNaN(o0) && isNaN(o1) && typeof o0 is 'number' && typeof o1 is 'number'

			# compare primitives and functions
			# check if both arguments reference the same object
			# especially useful on step when comparing prototypes
			return true if o0 is o1

			#IMPROVED: seems like "no brainer???"
			return false if o0 and !o1 or !o0 and o1

			# works in case when functions are created in constructor
			# comparing dates is a common scenario. Another built-ins?
			# we can even handle functions passed across iframes
			# precedence: instanceOf then && then ||
#			if typeof o0 is 'function' and typeof o1 is 'function'									or
#				o0 instanceof Date		and	o1 instanceof Date										or
#				o0 instanceof RegExp	and	o1 instanceof RegExp									or
#				o0 instanceof String	and	o1 instanceof String									r
#				o0 instanceof Number	and	o1 instanceof Number
#return o0.toString() is o1.toString()
#return o0.toString().replace /~/g, "|"  is o1.toString().replace / /g, ""
#				return o0.toString().replace(/\ /g, "") is o1.toString().replace /\ /g, ""
#
#			#IMPROVED: seems like "no brainer???"
#			return false if Object.keys(o0).length isnt Object.keys(o1).length
#
#
#			# check for infinitive linking loops
#			return false if leftChain.indexOf(o0) >= 0 || rightChain.indexOf(o1) >= 0
##
#			# quick checking of one object being a subset of another
#			#OPTIM: cache the structure of arguments[0]
#			for k of o1
##return false if o1.hasOwnProperty(k) isnt o0.hasOwnProperty(k)
#				return false if Object::hasOwnProperty.call(o0, k) isnt Object::hasOwnProperty.call(o1, k)
#				return false if typeof o1[k] isnt typeof o0[k]
#
#			for k of o0
##return false if o1.hasOwnProperty(k) isnt o0.hasOwnProperty(k)
#				return false if Object::hasOwnProperty.call(o0, k) isnt Object::hasOwnProperty.call(o1, k)
#				return false if typeof o1[k] isnt typeof o0[k]
#
#				switch typeof o0[k]
#					when 'object', 'function'
##CASE: NON-PRIMITIVE
#						leftChain.push o0
#						rightChain.push o1
#
#						return false if !compareTwo o0[k], o1[k]
#
#						leftChain.pop()
#						rightChain.pop()
#					else
##CASE: PRIMITIVE
#						return false if o0[k] isnt o1[k]
#
#			# at last checking prototypes as good as we can
#			#home grown objects don't neccessary inherit from Object: return false if !(o0 instanceof Object && o1 instanceof Object)
#			#return false if o0.isPrototypeOf(o1) || o1.isPrototypeOf(o0)
#			return false if Object::isPrototypeOf.call(o0, o1) || Object::isPrototypeOf.call(o1, o0)
#			return false if o0.constructor isnt o1.constructor
#			return false if o0.prototype isnt o1.prototype
#
#			true												#END: compareTwo
#
#		for j in [1..arguments.length-1]
#			leftChain = []
#			rightChain = []
#
#			return false if !compareTwo arguments[0], arguments[j]
#
#		true#/EQUALS
#	EQUALS_OBJECTS_THAT_ARE_CHAINED_TO_OBJECT_PROTOTYPE: (o0, o1) ->#NOT-USED
#		leftChain=rightChain=null								#CLOSURE
#
#		compareTwo = (o0, o1) ->
## remember that NaN===NaN returns false and isNaN(undefined) returns true
#			return true if isNaN(o0) && isNaN(o1) && typeof o0 is 'number' && typeof o1 is 'number'
#
#			# compare primitives and functions
#			# check if both arguments reference the same object
#			# especially useful on step when comparing prototypes
#			return true if o0 is o1
#
#			#IMPROVED: seems like "no brainer???"
#			return false if o0 and !o1 or !o0 and o1
#
#			# works in case when functions are created in constructor
#			# comparing dates is a common scenario. Another built-ins?
#			# we can even handle functions passed across iframes
#			# precedence: instanceOf then && then ||
#			if	typeof o0 is 'function'	&&	typeof o1 is 'function'									||
#				o0 instanceof Date		&&	o1 instanceof Date										||
#				o0 instanceof RegExp	&&	o1 instanceof RegExp									||
#				o0 instanceof String	&&	o1 instanceof String									||
#				o0 instanceof Number	&&	o1 instanceof Number
##return o0.toString() is o1.toString()
##return o0.toString().replace /~/g, "|"  is o1.toString().replace / /g, ""
#				return o0.toString().replace(/\ /g, "") is o1.toString().replace /\ /g, ""
#
#			# at last checking prototypes as good as we can
#			return false if !(o0 instanceof Object && o1 instanceof Object)
#			return false if o0.isPrototypeOf(o1) || o1.isPrototypeOf(o0)
#			return false if o0.constructor isnt o1.constructor
#			return false if o0.prototype isnt o1.prototype
#
#			#IMPROVED: seems like "no brainer???"
#			return false if Object.keys(o0).length isnt Object.keys(o1).length
#
#
#			# check for infinitive linking loops
#			return false if leftChain.indexOf(o0) >= 0 || rightChain.indexOf(o1) >= 0
#
#			# quick checking of one object being a subset of another
#			#OPTIM: cache the structure of arguments[0]
#			for k of o1
#				return false if o1.hasOwnProperty(k) isnt o0.hasOwnProperty(k)
#				return false if typeof o1[k] isnt typeof o0[k]
#
#			for k of o0
#				return false if o1.hasOwnProperty(k) isnt o0.hasOwnProperty(k)
#				return false if typeof o1[k] isnt typeof o0[k]
#
#				switch typeof o0[k]
#					when 'object', 'function'
##CASE: NON-PRIMITIVE
#						leftChain.push o0
#						rightChain.push o1
#
#						return false if !compareTwo o0[k], o1[k]
#
#						leftChain.pop()
#						rightChain.pop()
#					else
##CASE: PRIMITIVE
#						return false if o0[k] isnt o1[k]
#
#			true												#END: compareTwo
#
#		for j in [1..arguments.length-1]
#			leftChain = []
#			rightChain = []
#
#			return false if !compareTwo arguments[0], arguments[j]
#
#		true#/EQUALS_OBJECTS_THAT_ARE_CHAINED_TO_OBJECT_PROTOTYPE
#	I: (o) ->
#		if typeof o is "number"
#			o
#		else
#			parseInt o, 10
#	IS_EMPTY: (o) ->
#		for k of @KEYS o
#			return false
#		true
#
	CNT:CNT
	CNT_OWN:CNT_OWN
	CNT_ENUM:CNT_ENUM
	CNT_ENUM_OWN:CNT_ENUM_OWN

	duck: duck

	INTERSECTS_ENUM: (o0, o1) ->
		for k of o0
			return true if k of o1
		false

	KEYS:KEYS
	KEYS_OWN:KEYS_OWN
	KEYS_ENUM:KEYS_ENUM
	KEYS_ENUM_OWN:KEYS_ENUM_OWN

	LOG: LOG
	LOGIgnore: LOGIgnore

#
#	N: (o) ->
#		if typeof o is "number"
#			o
#		else if R.RE.TEST_PLUS_MINUS_FLOAT.test o
#			parseFloat o, 10
#		else
#			throw o
#	SUB_SUP_PROP_VALUES_EQUALS: (sub, sup) ->
#		for k of sub
#			return false unless sup[k]?
#			return false unless R.O.EQUALS sub[k], sup[k]
#		true



	UTRun: ->
		@log "O.UTRun"
#if ut
		new O_UT().run()
#endif








#class O_UT extends UT
#	run: ->
#		@T "LOG", ->
#			@log "pre"
