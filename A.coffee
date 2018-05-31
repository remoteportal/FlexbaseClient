trace = require './trace'


# PROJECT AGNOSTIC!!!



if !Array.isArray
	Array.isArray = (arg) -> Object::toString.call(arg) is '[object Array]'

		

module.exports =
	arraysEqual: (a, b) ->
		if a == b
			return true
		if a == null or b == null
			return false
		if a.length != b.length
			return false

		#TODO: If you care about the order of the elements inside the array, you should sort both arrays here.

		i = 0
		while i < a.length
			if a[i] != b[i]
				return false
			++i

		true