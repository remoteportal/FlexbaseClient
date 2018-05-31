#if node
#elseif rn
#import Expo, { FileSystem, SQLite } from 'expo'
#endif

trace = require './trace'
UT = require './UT'
V = require './V'




# THIS REQUIRED A separate FILE FROM UT.coffee because of a perceived cyclical dependency problem



#if ut
class VUT extends UT
	constructor: ->
		super "VUT"

	run: ->
		@t "TYPE", ->
			@eq V.TYPE(45), "number"
			@eq V.TYPE(new Number 45), "Number"
			@eq V.TYPE("literal string"), "string"
			@eq V.TYPE(new String "string class"), "String"
			@eq V.TYPE(null), "Null"
			@eq V.TYPE(undefined), "undefined"
			@eq V.TYPE(->), "function"
			@eq V.TYPE(new Date()), "Date"
			@eq V.TYPE(new Uint32Array()), "Uint32Array"
			@eq V.TYPE([]), "Array"
			@eq V.TYPE(true), "boolean"
			@eq V.TYPE(new Boolean(false)), "Boolean"


		@t "DUMP", ->
			if trace.UT_TEST_LOG_ENABLED or 1
				@log V.DUMP "literal string"
				@log V.DUMP new String "string object"
				@log V.DUMP a:"a"
				@log V.DUMP 45
				@log V.DUMP true
				@log V.DUMP undefined
				@log V.DUMP null
				@log V.DUMP VUT
				@log V.DUMP ->
				@log V.DUMP []
				@log V.DUMP new Date()
				@log V.DUMP new Uint16Array()
#endif




module.exports =
#if ut
	s_ut: -> new VUT().run()
#endif