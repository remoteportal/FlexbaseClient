#if node
#fs = require 'fs'
#A = require './A'
#O = require './O'
trace = require './trace'
util = require './Util'



module.exports = class Base
	constructor: (@name) ->
#		console.log "base=#{@name}"
#		@log "Base: #{@constructor.name}"
		@name = @constructor.name 	#+ "(Base)"

	
	#DUP
	log: (s, o, opt) =>				util.logBase @name, s, o, opt
		
	logError: (s, o, opt) =>		util.logBase @name, "ERROR: #{s}", o, opt
	
	logFatal: (s, o, opt) =>
		util.logBase @name, "FATAL: #{s}:", o, opt
#if node
		process.exit 1
#endif
	
	logCatch: (s, o, opt) =>		util.logBase @name, "CATCH: #{s}", o, opt

	logWarning: (s, o, opt) =>
		if trace.WARNINGS
			util.logBase @name, "WARNING: #{s}", o, opt
#endif