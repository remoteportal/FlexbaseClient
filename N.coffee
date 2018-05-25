trace = require './trace'

module.exports =



	#VARIABLES
#	eD = document.documentElement



	#INTERFACE
#	ASCIIHEX: (n) ->
##if n <= -3 or n >= 18
##	throw n
#		if n > 15
#			C.A_I_TO_LC_ASCII_HEX[15]
#		else if n < 0
#			C.A_I_TO_LC_ASCII_HEX[0]
#		else
#			C.A_I_TO_LC_ASCII_HEX[Math.round n]


	CONSTRAIN: (min, n, max) -> Math.max min, Math.min(n, max)


	PLURAL: (n) -> if n is 0 or n >= 2 then "s" else ""


	ROUND: (f, decCnt) -> Math.round(f*Math.pow 10, decCnt) / Math.pow(10,decCnt)						#SO: 16319855


# N.RND -> 0,1
# N.RND x -> 0-x
# N.RND x,y -> x-y
	RND: (min = 1, max) ->
		unless max
			max = min
			min = 0
		Math.floor Math.random() * (max-min+1) + min


#	SCROLL_LEFT: (n) ->
#		if n?
#			eD.scrollLeft = n
#		else
#			(window.pageXOffset || eD.scrollLeft) - (eD.clientLeft || 0)
#
#
#	SCROLL_TOP: (n) ->
#		if n?
#			eD.scrollTop = n
#			return
#		else
#			return (window.pageYOffset || eD.scrollTop) - (eD.clientTop || 0)


	SIGN: (n) ->
		if isNaN n
			NAN
		else if n is 0
			0
		else if n > 0
			1
		else
			-1


	PERIOD: (n) ->
		if n > 0
			s = ""
			for j in [1..n]
				s += "."
			s
		else
			R.AT n is 0
			""

	WORD: (n) ->
		if n is null
			""
		else if n < 11
			C.A_NUMBERS_ENGLISH[n]
		else
			R.V.COMMAIZE n


	ZEROPAD: (n, len) -> ("000000000" + n).slice -len