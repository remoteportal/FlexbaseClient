###
Base - Superclass of all classes					*** PROJECT AGNOSTIC ***


EXTENDS: Object


DESCRIPTION



FEATURES
-


NOTES
-


TODOs
- make log functions non-enumerable?


abbreviated versions:
@l
@lc
@le

@j = JSON
@d = deep
@s = silent

@log "tom", "-j", o
@log "tom, @j, o
@log "tom", @j o,

@log "these: @a, @b"
@log "@: a,b,c,d"		dumps all of them


r=reject, rj=reject, s=success, f=failure
resolve		ff		r			s
reject		rj		rj			f

KNOWN BUGS:
-
###











#if node
#fs = require 'fs'
#A = require './A'
O = require './O'
trace = require './trace'
util = require './Util'


CAP = (s) ->
	if s.length
		s.charAt(0).toUpperCase() + s.slice(1)
	else
		""


module.exports = class Base
	constructor: ->
#		@log "Base: #{@constructor.name}"
		@__CLASS_NAME = @constructor.name
#		@__CLASS_NAME2 = "222"
		@["@who"] = "class #{@__CLASS_NAME}"

#		for pn in ["","Assert","Catch","Error","Fatal","Info","Silent","Transient","Warning"]
##			console.log "*** #{pn}"
##			this[pn] = (s, v, opt) =>		util.logBase @__CLASS_NAME, "#{pn}: #{s}", v, opt
##			this[pn] = do (pn) -> (s, v, opt) =>		util.logBase @__CLASS_NAME, "#{pn}: #{s}", v, opt
#			this["log#{CAP pn}"] = do (pn) => =>
#				console.log "LEN=" + arguments.length
#				O.LOG arguments
#				a = Array.prototype.slice.call arguments
#				O.LOG a
#				switch a.length
#					when 0
#						console.log "when 0"
#						util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME]
#					when 1
#						console.log "when 1"
#						util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, "#{pn.toUpperCase()}: #{a[0]}"]
#					else
#						console.log "when N"
#						util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, "#{pn.toUpperCase()}: #{a[0]}", a[1]...]
#				util.abort()
##		O.LOG this
#
##		@logTransient()
#		@logTransient "tr"
#		@logTransient "tr", {a:"b"}
#		@logTransient "tr", {a:"b"}, "c"
#		util.abort()

	
	#DUP
#	log: (s, o, opt) =>				util.logBase @__CLASS_NAME2 ? @__CLASS_NAME, s, o, opt
	log: (s, o, opt) =>
#		O.LOG arguments
#		util.logBase @__CLASS_NAME2 ? @__CLASS_NAME, s+"!", o, opt
#		console.log "HERE"
#H: elipses... master this!
#H: CoffeeScript: "splat"
#H: JS: "rest parameters"
#		a = ["#1", @__CLASS_NAME2 ? @__CLASS_NAME, arguments..., "last"]
#		O.LOG a
		util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, arguments...]		#REVISIT


	logAssert: (s, o, opt) =>		util.logBase @__CLASS_NAME, "ASSERT: #{s}", o, opt

	logCatch: (s, o, opt) =>		util.logBase @__CLASS_NAME, "CATCH: #{s}", o, opt

	logError: (s, o, opt) =>		util.logBase @__CLASS_NAME, "ERROR: #{s}", o, opt

	logFatal: (s, o, opt) =>
		util.logBase @__CLASS_NAME, "FATAL: #{s}:", o, opt
#if node
		process.exit 1
#endif

	logInfo: (s, o, opt) =>			util.logBase @__CLASS_NAME, "INFO: #{s}", o, opt

	logSilent: (s, o, opt) =>		util.logBase @__CLASS_NAME, "SILENT: #{s}", o, bVisible:false	#H: needs to merge options	#R: SILENT

	logTransient: (s, o, opt) =>	util.logBase @__CLASS_NAME, "TRANSIENT: #{s}", o, opt

	logWarning: (s, o, opt) =>
		if trace.WARNINGS
			util.logBase @__CLASS_NAME, "WARNING: #{s}", o, opt
#endif