#if node
#elseif rn
#import Expo, { FileSystem, SQLite } from 'expo'
#endif

trace = require './trace'
UT = require './UT'
V = require './V'



#if ut
class ProofUT extends UT
	constructor: ->
		super()

	run: ->
		#H: 16:07 [UT] ================== #3 ProofUT/LOG/ooooo      where does LOG come from???
		@t "type investigation", {SO:2051893}, ->
			@eq typeof "string", "string"
			@eq typeof String("string"), "string"
			@eq typeof new String("string"), "object"
#endif




module.exports =
#if ut
	s_ut: -> new ProofUT().run()
#endif























##################################
return




console.log "A", "B", "C"
fff = (x) -> 2*x
console.log fff 5, fff 6			#WRONG







trace = require './trace'


#		list = []
#		list.unshift "a"
#		list.unshift "b"
#		@log list.pop()
#		list.unshift "c"
#		@log list.pop()
#		@log list.pop()
#		@log list.pop()



# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# https://stackoverflow.com/questions/36878850/octal-literals-are-not-allowed-in-strict-mode
@log `"hello\\033[0;31mthere"`






#MOVE: TO PROOF
#array1 = [
#	'a'
#	'b'
#	'c'
#]
#array1.forEach (element) ->
#	console.log element




#MOVE: proof
console.log ClientFBUT.this_is_static
console.log ClientFBUT.static_method()
console.log ClientFBUT.this_is_static







#class ClientFBUT extends UT
#	@this_is_static: 3
#	@static_method: ->
#		@this_is_static++
##		@log "@this_is_static=#{@this_is_static}"
