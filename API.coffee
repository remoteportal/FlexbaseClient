MariaSQL = require 'mariasql'

Base = require './Base'
O = require './O'
trace = require './trace'
util = require './Util'






NN = (n) -> if (""+n).length is 1 then "0#{n}" else n
BUILD = "BUILD"

sql =
	Fsql: ->
# https://github.com/mscdex/node-mariasql
#		SHOW PROCEDURE STATUS;
#		SHOW FUNCTION STATUS;
		new MariaSQL
			host: '127.0.0.1'
			user: 'ut'
			password: ''
			db: 'ut'
			multiStatements: true


module.exports =
	apiFactory: ->
		Object.defineProperties {},
			_conn:
				value: null
				writable: true
	#		audit:
	#			enumerable: true
	#			value: (auditTrailTypeID, data) ->
	#				@log "AUDIT[#{auditTrailTypeID}] API##{reqCounter[1]} #{data}"
	#				@conn.query 'call auditTrailInsert(?,?,?,?)', [
	#					auditTrailTypeID
	#					if @userInfoID > 0 then @userInfoID else null
	#					null	#H:skillID	#HARDCODE
	#					data
	#				], (err, rsets) =>
	#					if err
	#						@logError "auditTrailInsert", err
			bOpen:												#REDUNDANT?
				enumerable: true
				value: false
				writable: true
			conn:   											#JUST-IN-TIME   #ON-THE-FLY
				enumerable: true
				get: ->
					if @_conn
						unless @bOpen
							@_conn = sql.Fsql()
						@_conn
					else
						@bOpen = true
						@_conn = sql.Fsql()
			d:  												#DESTRUCTOR
				enumerable: true
				value: ->
					if @_conn
						@_conn.end()
						@bOpen = false
			logCatch:
				enumerable: true
				value: (s, o, opt) ->
					util.logBase "apiFactory", "CATCH: #{s}", o, opt
			logError:
				enumerable: true
				value: (s, o, opt) ->
					util.logBase "apiFactory", "ERROR: #{s}", o, opt
	## NO! textSend
	#				catch ex
	#					console.log "(ERRNOT)CATCH: #{ex}"
	#		ex:
	#			enumerable: true
	#			value: (err, title, o) ->
	#				console.log "#{@logPre()} - EXCEPTION #{title}"
	#				console.dir err
	#				if o
	#					console.dir o
	#				if PROD
	#					@audit 6, "#{title}: #{JSON.stringify err}"
	#					@textSend "+17048044786", "EX: #{title} #{err}"
	#					@log "afer textSend"
	#
	#				if @bPage
	#					@res.write "EXCEPTION!"
	#
	#					if typeof myVar == 'string'
	#						@res.write err
	#					else
	#						@res.write JSON.stringify err
	#
	#				@d()
			log:
				enumerable: true
				value: (s, o, opt) ->
					util.logBase "apiFactory", s, o, opt
			query:
				enumerable: true
				value: (stmts, a) ->
					new Promise (resolve, reject) =>
						@log stmts																		if trace.SQL
	
						if a?		#H: clusterfuck
							@conn.query stmts, a, (err, rsets) =>
								if err
									@log "=========================================="
									console.log stmts
									@logCatch "query", "err="+err
									reject err
								else
		#							@log "success: #{stmts}"
									resolve rsets
						else
							@conn.query stmts, (err, rsets) =>
								if err
									@log "=========================================="
									console.log stmts
									@logCatch "query", "err="+err
									reject err
								else
		#							@log "success: #{stmts}"
									resolve rsets
			textSend:
				enumerable: true
				value: (to, body) ->
					@log "textSend #{to}"
					if throttle 1, "#{to}:#{body}"
						@log "okay xxx"
						client = new twilio "AC1c756bb1848dea85e2db9c6e9b3ecb47", "ab7dd3f8f602406661d18e1cc4131036"
						@log "okay xxx2"
						#client.messages.create(
						#	body: 'Hello, Dave, from SkillsPlanet.com!'	#'I love you and want to hold you in bed every morning!'	#Hello from SkillsPlanet'
						#	to: '+16302345545'	#+17042934893'	#to: '+17048044786'
						#	from: '+17049466359'
						client.messages.create
							body: body
							to: to
							from: '+17049466359'
						.then (message) =>
							@log "twilio: sid=#{message.sid}"
						.catch (ex) =>
							@logCatch "twilio catch: #{ex}"		#NOT: logCatch !!!
	
