#if node
fs = require 'fs'
NODE_util = require 'util'
#elseif rn
#import Expo, { FileSystem } from 'expo'
#endif


N = require './N'
O = require './O'
trace = require './trace'


stringifySafe = (o) ->
	if o isnt null and typeof o is 'object'
		s = ""

		for pn of o
			s += "#{pn}=${o[pn]} "

		s
	else
		o


fs_directoryEnsure = (directory, cb) ->
#		console.log "fs_directoryEnsure: #{directory}"

		fs.access directory, fs.constants.W_OK, (err) =>
			if err
				if err.code is "ENOENT"
#					@log "mkdir: #{directory}"
					fs.mkdir directory, (err) =>
						if err
#							@logError "mkdir", err
							cb err
						else
							cb()
				else
#					@logError "access", err
					O.DUMP err
					cb err
			else
#				@log "already exists"
				cb()


fs_directoryDeleteRecursive = (directory) ->
#	console.log "fs_directoryDeleteRecursive: #{directory}"

	if fs.existsSync directory
		fs.readdirSync(directory).forEach (file, index) ->
			curPath = directory + '/' + file
			if fs.lstatSync(curPath).isDirectory()
				fs_directoryDeleteRecursive curPath
			else
				console.log "fs_directoryDeleteRecursive: unlink: #{curPath}"
				fs.unlinkSync curPath
		fs.rmdirSync directory


logBase = (fnn, s, v, opt) ->
	vPart = ""

	s ?= "**********"

	try
		if v?
			if ("" + v) is "[object Object]"
				if opt
					vPart = ""
					O.DUMP v		#NOT-DEBUG
				else
					vPart = " " + JSON.stringify v
			else
				vPart = v
		else
			vPart = ""

		return console.log "#{MMSS()} [#{fnn}] #{s} #{vPart}"
	catch ex
		return console.log "#{MMSS()} [#{fnn}] #{s}: LOG EXCEPTION: #{ex}"


GUIDNew = ->		# uuidv4
	'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
		r = Math.random() * 16 | 0
		v = if c == 'x' then r else r & 0x3 | 0x8
		v.toString 16
# console.log uuidv4()


latestGet = (clo, fq) ->
	version = 0
	while clo["version#{version+1}"]
		version++
#	logBase "util", "version=#{version}"
	if latest = clo["version#{version}"]
		latest
	else
		logBase "util", "[#{fq}] Can't find version", clo, true
		null






MMSS = -> "#{N.ZEROPAD (date=new Date).getMinutes(), 2}:#{N.ZEROPAD date.getSeconds(), 2}"


#util =
#
#	log: (s, o) ->			logBase "Util", s, o
#	logError: (s, o) ->		logBase "Util", "ERROR: #{s}", o
#	logCatch: (s, o) ->		logBase "Util", "CATCH: #{s}", o
#
#
#	dumpSafe: (v) ->
#		@log "dumpSafe"
#
#		if v and typeof v is 'object'
#			for pn, pv of v
#				@log "#{pn}=#{pv}"
#		else
#			@log v
#		return
#
#
#	dumpSafeRecursive: (v) ->
##		@log "dumpSafeRecursive"
#
#		if v and typeof v is 'object'
#			for pn, pv of v
#				if pv and typeof pv is 'object'
##					util.dumpSafeRecursive pv			#TODO: stops prematurely
#					@log "DSR: #{pn} OBJ"
#				else
#					@log "DSR: #{pn}=#{pv}"
#		else
#			@log "DSR: #{v}"
#		return




module.exports =
	fs_directoryEnsure: fs_directoryEnsure
	fs_directoryEnsurePromise: (directory) -> NODE_util.promisify(fs_directoryEnsure) directory
	fs_directoryDeleteRecursive: fs_directoryDeleteRecursive
	GUIDNew: GUIDNew
	latestGet: latestGet
	logBase: logBase
