#if node
trace = require './trace'
V = require './V'
#endif



#import logBase from './Log'


if 0
# probably long
	o = Object.create null
	o["1"]  = true
	o["3"]  = true
	o["5"]  = true

	# probably short
	a = [1, 2, 3, 4]

	# iterate a, check o

	# optimize: some objects are 'everyone'



	o.$ = 3
	o.$a = 33
	o.$$ = 2

	o.a = [1, 2, 3]
	o.a.total = 100
	l = o.a.length






#IS=R.IS



B = (o) -> o is true or o is 1 or o is "1" or o is "true"


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


#V.DUMP = (v) ->
#	if Object::toString.call(v) is '[object String]'
#		if v.length is 0
#			"\"\""
#		else
#			v
#	else if Object::toString.call(v) is '[object Number]'
#		v
#	else if Object::toString.call(v) is '[object Boolean]'
#		v
#	else if Object::toString.call(v) is '[object Function]'
#		"FN"
#	else
#		"#{pv} <#{typeof pv}>"
			
DUMP = (o) ->
	dump = (o, level) ->
#		console.log "DDDDDDDDDDDDDD2: #{JSON.stringify o}"
		for pn,pv of o
			indent = "> ______________________________________________________________".substr(0, level+2)
			try
#				console.log "#{indent}#{pn}: #{pv} (#{typeof pv})"
				if Array.isArray pv
					if pv.length is 0
						console.log "#{indent}#{pn}: []"
					else
						console.log "#{indent}#{pn}: ARRAY:"
						for item,n in pv
							if Object::toString.call(item) is '[object Object]'
								console.log "#{indent}[#{n}]: AO"
								dump pv, level+1
							else
								console.log "#{indent}_[#{n}]: #{V.DUMP pv}"
				else
					if Object::toString.call(pv) is '[object Object]'
						cnt = CNT_OWN pv
						if cnt
							console.log "#{indent}#{pn}: OBJ (#{cnt})"
							dump pv, level+1
						else
							console.log "#{indent}#{pn}: OBJ EMPTY"
					else
						console.log "#{indent}#{pn}: #{V.DUMP pv}"
#				console.log "#{indent}#{pn} (#{typeof pv})"
	#			console.log "#{pn}"
			catch ex
				console.log "#{indent}#{pn}: ***ERR*** #{ex}"
		return
	dump o, 0
	return
	# console.log "OOOOOOOOOOOOOOOOO"
	
#DUMP = (o, bRecursive=true, stringTruncateCnt=65535, levelNbr=0, bTerm=true, maxDepth=16, bMarkup=true) ->
#	indent = ->
#		if bMarkup
#			R.N.PERIOD levelNbr*10
#		else
#			""
#
#	if bTerm
##BR = "_#{maxDepth}<br>"
##BR = "$<br>"
#		BR = "<br>"
#	else
#		BR = " "
#
#	LLL = if bMarkup
#		R.L
#	else
#		ACTION: (s) -> s
#		CLS: (s) -> s
#		ERR: (s) -> s
#		EV: (s) -> s
#		RANGE: (s) -> s
#		TAG: (s) -> s
#		TR: (s) -> s
#		CELL_TYPESTYPE: (s) -> s
#
##	REC = (o, bTerm) ->
##		if levelNbr < maxDepth	#HACK
##		DUMP o, bRecursive, stringTruncateCnt, levelNbr+1, bTerm, maxDepth, bMarkup
##		else
##		BR
#
#	callREC = (o) ->
#		if !o? or IS.PRIM(o) or (Array.isArray(o) and (o.length is 0 or (o.length is 1 and IS.PRIM o[0]))) or (IS.O(o) and CNT_ENUM_OWN(o) is 1 and IS.PRIM(o[Object.keys(o)[0]]))
#			if levelNbr < maxDepth
#				REC o, bTerm							#REC repeats this logic...
#			else
#				"#{o}#{BR}"
#		else
#			"#{BR}#{REC o, true}"
#
#	if o?
#		if Array.isArray o
#			if o.length is 0
#				"[]" + BR
#			else if o.length is 1 and typeof o[0] isnt "object"
#				"[#{REC o[0], false}]" + BR
#			else
#				s = ""
#				s += BR + "#{indent()}[" + BR
#				for item,j in o
#					s += "#{indent()}#{LLL.CLS "#{j}/#{o.length-1}"}"
#					s += callREC item
#				s + "#{indent()}]" + BR
#		else
#			switch typeof o
#				when "symbol"
#					LLL.TYPE("#{o} symbol") + BR
#				when "boolean"
#					"#{LLL.EV o}" + BR
#				when "number"
#					"#{LLL.TAG o}" + BR
#				when "string"
#					"\"#{LLL.RANGE(R.S.TRUNC o, stringTruncateCnt)}\"#{if bMarkup then "<span class='l-str-len'>#{o.length}</span>" else ""}" + BR
#				when "function"
#					"#{LLL.TR o}" + BR
#				when "object"
#					try
#						s = ""
#						for own k,v of o
#							s += "#{indent()}#{LLL.ACTION k}:"
#							s += callREC v
#						s
#					catch eo
#						"UNABLE TO ITERATE OBJECT PROPERTIES: #{eo}"
#				else
#					throw "type \"#{typeof o}\""
#	else if o is undefined
#		LLL.TYPE("undefined") + BR
#	else
#		LLL.ERR("null") + BR






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






module.exports =
#	B:B
#	CHILD_ELEVATE: (o, pn) ->
#		if o[pn]
#			@EXT_RVTMX o, o[pn]
#			delete o[pn]
#		o
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
	DUMP:DUMP



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

	INTERSECTS_ENUM: (o0, o1) ->
		for k of o0
			return true if k of o1
		false

	KEYS:KEYS
	KEYS_OWN:KEYS_OWN
	KEYS_ENUM:KEYS_ENUM
	KEYS_ENUM_OWN:KEYS_ENUM_OWN
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