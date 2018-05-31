#if node
WebSocket = require 'ws'

#A = require './A'
Base = require './Base'
Classes = require './Classes'
O = require './O'
Store = require './Store'
trace = require './trace'
UT = require './UT'
util = require './Util'
#endif


# TODO





class ClientUT extends UT
	run: (@testHub) ->
		@s "negative", ->
			@a "non-existent server", {timeout:2000}, (ut) ->
				@client = new Client "www.onlyup.com"
				@client.listen true
				.then (connectedCnt) =>
					@log "client connected: connectedCnt=#{connectedCnt}"
					@client.send c_to_s:"hi"
#				.then (fo) =>
#					@log "read", fo
#					@log fo.pi()
#					@eq fo.pi(), 3.1415926
#					ut.resolve()
				.catch (ex) =>
#					O.LOG ex
					if ex is "Invalid URL"
						@log "correct"
						@client.listen false
						ut.resolve()
					else
						@logCatch @context, ex
						ut.reject ex
#endif





class Client extends Base
	constructor: (@URL) ->
		super()
#		@_who = "class Client"
		@bAlive = @bNoConnectionDisplayed = false
		@onCloseErrorMap = {}
#		@log "Client"																				if trace.CONSTRUCTORS
#		throw new Error "THIS FORCES STACKTRACE"



	attempt: ->
		#TODO: #H: leave @ off of @bAlive and notice no error displayed... fix the root cause of this!
#		@log "attempt: bAlive=#{@bAlive}"

		if @bAlive
			@log "[#{@attemptCnt}] attempt: ws=#{@ws} mOnline=#{@mOnline}"								if trace.SOCKET_NOISE

			unless @ws
				@attemptCnt++

				@log "[#{@attemptCnt}] attempting to connect to WebSocket #{@URL}"						if trace.SOCKET_NOISE
				@mOnline = 1

				# https://github.com/websockets/ws
				try
					@ws = new WebSocket @URL
				catch ex
	#				@log "type=#{typeof ex.message}"
					if ex.message.includes "Invalid URL"
	#					@logFatal "bad url: #{@URL}"
						@listen_reject "Invalid URL"
						clearInterval @thread
						return
					else
						@logCatch "new WebSocket", ex
						clearInterval @thread
						@listen_reject ex
						@logFatal "INVESTIGATE", ex
						return

				@ws.onopen = =>
					@connectedCnt++

					@log "Internet connected: connectedCnt=#{@connectedCnt}"							if trace.INTERNET
					@bConnected = true
					@attemptCnt = 0
					@mOnline = 2
					@listen_resolve @connectedCnt


				@ws.onmessage = (e) =>
#					@log "msg", e.data

				#							o = JSON.parse e.data
				#							if o.target is "flexbase"
				#								@log "FB: onmessage: #{e.data}"
				#							if @ws_onmessage o
				#								@mOnline = 3
					o = JSON.parse e.data
					@onReceive o

				@ws.onerror = (ex) =>
	#								@logFatal "onerror", ex		#LONG
	#								@log "type=#{Object::toString.call ex}"
					@logFatal "onerror: #{ex.message}"		#, ex	#LONG

					if ex.message.includes "Connection refused"				# The operation couldn’t be completed. Connection refused
						unless @bNoConnectionDisplayed
							@log "No Internet connection"
							@mOnline = 4
							#TODO: display to user
							@bNoConnectionDisplayed = true
					else
						@logError "onerror: #{ex.message}", ex
						O.LOG ex
					# util.dumpSafeRecursive(ex);
					# 1001 websocket "stream end encountered"
					# https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent
					# 1000: Normal closure; the connection successfully completed whatever purpose for which it was created.

					@ws = null

				@ws.onclose = (ex) =>
	#				@log "onclose", ex, false		#CIRCULAR
#					@log "onclose"

					if @bConnected
						_ = "onclose: code=#{ex.code} reason=#{ex.reason}"
						unless @onCloseErrorMap[_]
							@onCloseErrorMap[_] = true
#							@log _
						@ws = null


	listen: (@bAlive) ->
		if @bAlive
			new Promise (@listen_resolve, @listen_reject) =>
#				@log "bAlive=#{@bAlive} connect: #{@URL}"

				if @ws
					@listen_reject "already started!"
				else if @URL
					@mOnline = 0
					@uptimeBeg = Date.now()		#H
					@bConnected = false
					@attemptCnt = 0
					@connectedCnt = 0

					@attempt()

					#TODO: clearInterval @thread
					@thread = setInterval =>
						@attempt()
					,
						5000
				else
					@logFatal "URL unset"
		else
#			@log "stopping... bAlive=#{@bAlive}"
			clearInterval @thread
			@ws?.close()
#.catch (ex) => @logCatch "tank of gas", ex


	onReceive: (o) ->
#		@log "onReceive [DEFAULT]", o

	send: (o) ->
#		@log "send", o
		#H #BIZARRE #BACKED_OUT passing the callback breaks receiving good data on the server
#			@ws.send JSON.stringify o, (err) =>
#			@log "sent"
#			if err
#				@logTransient "send:ws.send", err
		@ws.send JSON.stringify o
#		@log "SEND"


#// If the WebSocket is closed before the following send is attempted
#ws.send('something');
#
#// Errors (both immediate and async write errors) can be detected in an optional
#// callback. The callback is also the only way of being notified that data has
#// actually been sent.
#ws.send('something', function ack(error) {
#// If error is not defined, the send has been completed, otherwise the error
#// object will indicate what failed.
#});
#
#// Immediate errors can also be handled with `try...catch`, but **note** that
#// since sends are inherently asynchronous, socket write failures will *not* be
#// captured when this technique is used.
#try { ws.send('something'); }
#catch (e) { /* handle error */ }




#if ut
	@s_ut: (testHub) -> new ClientUT().run testHub
#endif


module.exports = Client
