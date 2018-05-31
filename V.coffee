###
V - Value functions					*** PROJECT AGNOSTIC ***


WHAT: Node module


DESCRIPTION



FEATURES
-


NOTES
- "A primitive (primitive value, primitive data type) is data that is not an object and has no methods. In JavaScript, there are 6 primitive data types: string, number, boolean, null, undefined, symbol"


TODOs
- throw error if find new datatype


KNOWN BUGS:
-
###



trace = require './trace'


# [object Function]
RE_ISOLATE_TYPE = /\[object ([^\]]*)\]/

	
	


# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects
DUMP = (v) ->
	try
#		type = Object::toString.call v
#		# [object Function]
#		re = /\[object ([^\]]*)\]/
#		match = re.exec type
#		if match
#			console.log "match=#{match[1]}"
#		else
#			console.error "V.DUMP: unable to isolate type from: \"#{type}\""
#			process.exit 1

		if v?
			type = TYPE v

#			console.log "V.DUMP: DEBUG: {v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE=#{type} JSON=#{JSON.stringify v}"

			switch type
				when "Boolean", "boolean", "Number", "number"
					v
				when "function"
					"FN"
#					v
				when "Promise"
					#TODO: dump attributes
					"#{v} <Promise>"
				when "String", "string"
					if v.length is 0
						"\"\""
					else
						v
				when "Uint8Array"
					"#{v} <#{type}> #{JSON.stringify v}"
				else
					"#{v} <#{type}> UNKNOWN"
		else
#			console.log "V.DUMP: DEBUG: {v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE=#{type} JSON=#{JSON.stringify v}"
#			"null or undefined"
			"null"		#H #WARNING
	catch ex
		console.error "V.DUMP exception: #{ex}"


KV = (k, v) -> "#{k} = #{v} <#{TYPE v}>"		#TODO: distinquish between primative and non-primative


PAIR = (v) -> "#{v} <#{TYPE v}>"		#TODO: distinquish between primative and non-primative


typeMap = {}
TYPE = (v) ->
	if _=typeMap[v]
		_
	else
		type = Object::toString.call v

		match = RE_ISOLATE_TYPE.exec type
		if match and match.length >= 2
	#		console.log "match=#{match[1]}"

			# primative vs. non-primative types
			if typeof v is "object"
				type = match[1]
			else
				type = typeof v

			typeMap[v] = type
		else
			console.error "V.TYPE: Unable to isolate type substring from: \"#{type}\""
			process.exit 1		#TODO: call util.exit()



module.exports =
	DUMP: DUMP
	EQ: (v1, v2) -> console.log "COMP: #{v1} vs. #{v2} (#{typeof v1}) vs (#{typeof v2}) #{if v1 is v2 then "YES-MATCH" else "NO-MATCH"}"	#USED?
	KV: KV
	PAIR: PAIR
	TYPE: TYPE