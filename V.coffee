trace = require './trace'

DUMP = (v) ->
	if Object::toString.call(v) is '[object String]'
		if v.length is 0
			"\"\""
		else
			v
	else if Object::toString.call(v) is '[object Number]'
		v
	else if Object::toString.call(v) is '[object Boolean]'
		v
	else if Object::toString.call(v) is '[object Function]'
		"FN"
	else
		"#{pv} <#{typeof pv}>"


module.exports =
	DUMP: DUMP