#if node
fs = require 'fs'
NODE_util = require 'util'
#elseif rn
#import Expo, { FileSystem } from 'expo'
#endif


N = require './N'
O = require './O'
trace = require './trace'


m_logStream = null
m_logEmptyNextCharacter = 'A'


#TODO: log multiple objects before options

#H: try to move these into concrete S, N, O, etc., files???


abort = (msg) ->
#if node
	console.error "#".repeat 60
	if msg
		console.error "NODE ABORTED#{if msg then ": #{msg}" else ""}"
	else
		console.error "ABORTING NOW!!! (log will be truncated...)"
	console.error "#".repeat 60
	process.exit 1
#else
#		throw "ABOPT!!!!!!!!!!!!!!!!!!"
#endif



exitAfterSlightDelay__soThatLogCanFinishWriting = (ms = 500) ->
	setTimeout =>
		console.error "exitAfterSlightDelay__soThatLogCanFinishWriting"
		process.exit 1
	,
		ms


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
					O.LOG err
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



# usage:
# fnn, s, v, bDeep
# fnn, s, v0, v1, ..., vN		where any v can be opts object
logBase = (fnn, s, v, optionsObjectOrO_LOG_flag) ->		#H #MESS
#	console.log "logBase"
#	O.LOG arguments
#	abort()

	opts =
		bVisible: true
		bDeep: true		#RECENT

#	a = arguments.slice()
	# copy array
	a = Array.prototype.slice.call arguments, 1
#	O.LOG a
#	abort()

	# ARGUMENTS SHIFT LEFT!
	# now:
	#	0	1	2
	#	s, v, opt
#	O.LOG a

	if a.length is 3 and typeof optionsObjectOrO_LOG_flag is "boolean"
		opts.bDeep = optionsObjectOrO_LOG_flag
#		console.log "boolean passed as third argument: bDeep=#{opts.bDeep}"
		a.splice 2, 1
#		O.LOG a
#		console.log "len=#{a.length}"
#	abort()

	if a.length > 2
#		console.log "look for options object"
#		O.LOG a
		for i in [0, a.length - 1]
#			O.LOG a[i]
			if typeof a[i] is "object"
				bFoundOpts = false
				for opt in ["bDeep", "bVisible"]
					if opt of a[i]
						# override specific opts
						for pn, pv of a[i]
#							console.log "opt: override: #{pn}=#{a[i][pn]}"
							opts[pn] = a[i][pn]
#	console.log "FUCKING MESS"


# log() draws a "horizontal rule" line of chars if no string passed
#	console.log "s=#{s}"
	unless s
		a.push m_logEmptyNextCharacter.repeat 60
		m_logEmptyNextCharacter = String.fromCharCode(m_logEmptyNextCharacter.charCodeAt(0) + 1)

	vPart = ""
	extra = ""
	try
		if v?
			if v instanceof Error
				extra = ": #{v.stack}"
			else if typeof v is "object"
				unless opts.bDeep
					extra=" #{JSON.stringify v}"
			else
				extra = " #{v}"
	catch ex
		extra = ": LOG_BASE INTERNAL EXCEPTION: #{ex}"

	line = "#{MMSS()} [#{fnn}] #{s}#{extra}"

	if opts.bVisible
		console.log line

		if opts.bDeep and v
#			console.log "*****************"
			O.LOG v
#		O.LOG a...

	if m_logStream?
		m_logStream.write "#{line}\n"



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





module.exports =
	abort: abort
	exit: (msg) ->
		m_logStream.end "\n--EOF but PREMATURE EXIT: #{msg}--"
		m_logStream = null

#if node
		console.error "#".repeat 60
		if msg
			console.error msg
		else
			console.error "told to exit"
		console.error "#".repeat 60
		console.error "Exiting node..."
		exitAfterSlightDelay__soThatLogCanFinishWriting()
#else
#		console.error "#".repeat 60
#		if msg
#			console.error msg
#		else
#			console.error "EXIT NOT POSSIBLE"
#		console.error "#".repeat 60
#endif
	fs_directoryEnsure: fs_directoryEnsure
	fs_directoryEnsurePromise: (directory) -> NODE_util.promisify(fs_directoryEnsure) directory
	fs_directoryDeleteRecursive: fs_directoryDeleteRecursive
	latestGet: latestGet
	logBase: logBase
	streamSet: (_) -> m_logStream = _
