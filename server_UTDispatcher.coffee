fork = require('child_process').fork

A = require './A'
API = require './API'
Base = require './Base'
O = require './O'
trace = require './trace'
UT = require './UT'
util = require './Util'



argsNode = process.argv.slice 2


class Server_UTDispatcher extends Base
	constructor: ->
		super()
#		O.LOG @c

	listen: ->
		@log "listen"																				if trace.SOCKET_LISTEN

		argsNode.forEach (item) ->
			console.log item

		setTimeout =>
				child = fork './server_UT.js', ["peter", "alvin"], stdio:'pipe'
				@log "forked", child
			,
				1000

server_UTDispatcher = new Server_UTDispatcher()
server_UTDispatcher.listen()
return
















PROD=0


TRACE_RECEIVED = false
TRACE_SENT = false

TRACE_RECEIVED = true
TRACE_SENT = true



PORT_CMS=if PROD then 3333 else 3344

PORT_WEB_SOCKET=if PROD then 3355 else 3888

BUILD = "#{if PROD then "PROD" else "DEV"} 18-05-15.1 (0.0.95)"


uptimeBeg = Date.now()


NN = (n) -> if (""+n).length is 1 then "0#{n}" else n

LG = (file, s, v) ->
	date = new Date()
	vPart=""
	if v
		vPart = ""
		if ""+v isnt "[object Object]"
			vPart += " " + v
		else if v
			vPart += " " + JSON.stringify v
	console.log "#{NN date.getMinutes()}:#{NN date.getSeconds()} #{BUILD} #{s}#{vPart}"

FILE = if PROD then "cms" else "dev"
lg = (s, o) -> LG FILE, s, o
logError = (s, ex) -> LG FILE, "ERROR: #{s}", ex
logcatch = (s, ex) -> LG FILE, "CATCH: #{s}", ex

EQ = (v1, v2) -> console.log "COMP: #{v1} vs. #{v2} (#{typeof v1}) vs (#{typeof v2}) #{if v1 is v2 then "YES-MATCH" else "NO-MATCH"}"









wsMap = Object.create null


peter = 0
setInterval (->
#	lg "hello"

	for pn,ws of wsMap
#		lg "MAP: user=#{pn}"

#		ws.send JSON.stringify
#			target: "flexbase"
#			cmd: "wisper"
		if FO
			FO.peter = peter++
			#			lg "MAP: user=#{pn} FO.peter=#{FO.peter}"
			try
				ws.send JSON.stringify
					target: "flexbase"
					cmd: "s-fb-object-push"
					fo: FO
			catch ex
				logcatch "test push", ex
), 30000

FO = null








logBase = (s, o) -> LG FILE, s, o


proxyMap = {}		#NOT ACCURATE

Flexbase = (ws) ->
	log: (s, o) =>			logBase "Flexbase", s, o
	logError: (s, o) =>		logBase "Flexbase", "ERROR: #{s}", o
	logCatch: (s, o) =>		logBase "Flexbase", "CATCH: #{s}", o

	create: (o, bSend) ->
		new Promise (resolve, reject) =>
			reject "__cn not set" unless o.__cn

			o.dateCreated ?= new Date()			# VERIFY in dump... it's getting corrupted?  it's some other object

			c = apiFactory()
			c.conn.query "call objectInsert(?,?,?,?)", [
				1,
				1,
				"ws"
				JSON.stringify o
			], (err, rsets) =>
				if err
					@logCatch "create", err
					reject err
				else
					o.__id = parseInt rsets[0][0].id, 10
					proxyMap[ o.__id ] = o
					#					@log "create #{JSON.stringify(o)}"
					if bSend
						ws.send JSON.stringify
							target: "flexbase"
							cmd: "c-fb-object-insert-ack"
							fo: o
					c.d()
					resolve o
	get: (__id) ->
		new Promise (resolve, reject) =>
			if _=proxyMap[ __id ]
#				@log "get #{__id} **** HIT ****"
				resolve _
			else
				@log "get #{__id}"
				throw "NOT-IMPL"





# CRWCCC...  create read write create create create....
lg "websocket listening #{PORT_WEB_SOCKET}"
express = require 'express'
app = express()
expressWs = require('express-ws')(app)
app.use (req, res, next) ->
#	lg 'middleware'
	req.testing = 'testing'
	next()
app.get '/', (req, res, next) ->
#	lg 'get route', req.testing
	res.end()

peter__id = null
app.ws '/', (ws, req) ->
	lg "match /"
	ws.on 'message', (json) ->
		lg "received", json														if TRACE_RECEIVED
		po = JSON.parse json

		sendAck = (errorMsgOpt, rvpo) ->
			_ =
				target: "flexbase"
				cmd: "#{po.cmd}-ack"
				guid: po.guid
				tsCBeg: po.tsCBeg

			for pn,pv of rvpo
				_[pn] = pv

			lg "sent", _														if TRACE_SENT

			ws.send JSON.stringify _

		#		lg "po.cmd=#{po.cmd}"
		switch po.cmd
			when "test"
#				lg "IN TEST2"
				flexbase = new Flexbase ws
				flexbase.create
					__cn: "SmileSpeak.SmileUser"		#TODO: make first parameter
					appEngagedMetric: 0
					activityList: []
					friendList: []
					tagList: ""
					first: "Deanna"
					last: "Boskovich"
					phoneNumber: "704-293-4893"
				,
					false
				.then (user) =>
#					lg "test", user
					sendAck null,
						user: user
				.catch (ex) =>
					sendAck ex
			when "c-fb-hi"
				lg "welcome #{po.cn}!"
				wsMap[po.cn] = ws
				sendAck null,
					serverBuild: BUILD
					serverUpMinutes: Math.floor(( Date.now() - uptimeBeg ) / 1000 / 60)
			when "c-fb-register"
#				lg "c-fb-register", po
				if po.username is "remoteportal" and po.password is "1234"
#					lg "INSIDE"
					flexbase = new Flexbase ws
					flexbase.create
						__cn: "SmileSpeak.SmileUser"
						appEngagedMetric: 0
						activityList: []
						friendList: []
						tagList: ""
						first: "Peter"
						last: "Alvin"
						phoneNumber: "704-804-4786"
					,
						false
					.then (user) =>
#						lg "after register/create", user
						peter__id = user.__id
						sendAck null,
							user: user
					.catch (ex) =>
						sendAck ex
				else
					sendAck "email already registered"
			when "c-fb-login"
#				lg "c-fb-login", po
				if po.username is "remoteportal" and po.password is "1234"
#					lg "INSIDE"
					flexbase = new Flexbase ws
					flexbase.get peter__id
					.then (user) =>
						sendAck null,
							user: user
					.catch (ex) =>
						sendAck ex
				else
					sendAck "account not found"
			when "c-fb-object-insert"
				throw "!insert" unless po.fo.__id < 0
				c = contextFactory null, null, 1, "c-fb-object-insert", null, null, false
				if po.fo.fname is 'Deanna'
#					lg "FOUND DEANNA; caching FO"
					FO = po.fo
				c.conn.query 'call objectInsert(?,?,?,?)', [
					1,
					1,
					'hello'
					JSON.stringify po.fo
				], (err, rsets) ->
					if err
						c.ex err
					else
						po.fo.__orig = po.fo.__id
						po.fo.__id = parseInt rsets[0][0].id, 10
						#						c.log "c-fb-object-insert: success: #{po.fo.__orig} => #{po.fo.__id}", po.fo
						sendAck null,
							__orig: po.fo.__orig
							__id: po.fo.__id

						if po.fo.__cn is "SmileSpeak.Delivery"
							lg "SMILE DELIV!"

							flexbase = new Flexbase ws
							flexbase.get po.fo.idTo
							.then (_to) =>
								lg "delivery of #{po.fo.idRecording} from #{po.fo.idFrom} to #{po.fo.idTo}", po.fo
							.catch (ex) =>
								sendAck ex


						c.d()
#CONVENTION: po - Payload Object
			when "c-fb-object-update"
				c = contextFactory null, null, 1, "c-fb-object-update", null, null, false
				throw "!update" unless po.fo.__id isnt 0
				c.conn.query "call objectDataUpdate(?,?)", [
					po.fo.__id,
					JSON.stringify po.fo
				], (err, rsets) ->
					if err
						c.ex err
					else
#						c.log "c-fb-object-update-ack: success: #{po.fo.__id}", po.fo
						sendAck null,
							__id: po.fo.__id
						c.d()
			when "c-fb-invoke"
				myObj =
					CS_server3: ->
						console.log "CS_server3 called on server"

				#				target: "flexbase"
				#				cmd: "c-fb-invoke"
				#				guid: guid
				#				fn: fn
				#				args: args
				c = contextFactory null, null, 1, "c-fb-invoke", null, null, false
				#				c.log "c-fb-invoke2", po
				if po.fn is "server3"
# how call
#					myObj.CS_server3()
					myObj["CS_server3"]()
					#					c.log "after calling CS_server3"

					ws.send JSON.stringify
						target: "flexbase"
						cmd: "c-fb-invoke-ack"
						guid: po.guid
				else
					ws.send JSON.stringify
						target: "flexbase"
						cmd: "c-fb-invoke-ack"
						guid: po.guid
						error: "METHOD NOT FOUND"
				c.d()
			else
				logError _="unknown server command: '#{po.cmd}'", po
				sendAck error: _

#	lg 'socket', req.testing
app.listen PORT_WEB_SOCKET























app = require('express')()

#NEW
expressWs = require('express-ws')(app)

Client = require 'mariasql'

bodyParser = require 'body-parser'
app.use bodyParser.json()									# support json encoded bodies
app.use bodyParser.urlencoded extended:true					# support encoded bodies

cookieParser = require 'cookie-parser'
app.use cookieParser()

nodemailer = require "nodemailer"
twilio = require "twilio"


app2 = require('express')()
http2 = require('http').Server app2

app2.get '/', (req, res) ->
# res.send '<h1>Hello world</h1>'
	res.sendFile __dirname + '/chat.html'










server = app.listen PORT_CMS, ->
	console.log "==================================================================="
	console.log "SkillsPlanet API and CMS #{BUILD} running on port #{PORT_CMS} (chat #{PORT_WEB_SOCKET})"



clientMap = {}


msgInsert = (userInfoFromID, userInfoToID, msg) ->
	c = contextFactory null, null, 1, "msgInsert"
	c.conn.query 'call msgInsert(?,?,?)', [
		userInfoFromID
		userInfoToID
		msg
	], (err, rsets) ->
		if err
			c.ex err
		else
			lg "msgInsert success"
			c.d()



rnd = (min, max) -> Math.floor(Math.random() * (max - min + 1)) + min


# mType
T_API=0
T_CMS=1
reqCounter = [0, 0]

# mSendType
ST_EMAIL=0
ST_TEXT=1
sendCounter = [0, 0]

qqq = {}

setInterval ( =>
#	lg "reset sendCounters"
	sendCounter[0] = sendCounter[1] = 0
), 60 * 60000

throttle = (mSendType, thunk) ->
	sendCounter[mSendType]++
	if sendCounter[mSendType] < 3
		true
	else
		logError "sendCounter[#{mSendType}]"
		false


sql =
	Fsql: ->
		new Client
			host: '127.0.0.1'
			user: 'SkillsUser'
			password: '0728'
			db: 'sp'

top = ""




contextFactory = (req, res, mType, verb, userInfoID, nameFirst, bLog=true) ->
	reqCounter[mType]++

	flash = ""

	date = new Date()
	if verb isnt "q_pop" and bLog
		console.log "#{NN date.getMinutes()}:#{NN date.getSeconds()} #{if mType then "cms" else "api"} ##{reqCounter[mType]} #{verb}"

	userInfoID ?= 0
	nameFirst ?= "WHO ARE YOU?"

	if req
		if req.cookies.userInfoID	# hit or miss
# console.log "found cookie"
			userInfoID = 1 * req.cookies.userInfoID
			nameFirst = req.cookies.nameFirst
		# console.log "FOUND COOKIES: userInfoID=#{userInfoID} #{nameFirst}"

		if req.body?.userInfoID		# hit or miss
			userInfoID = 1 * req.body.userInfoID
		# console.log "FOUND POST BODY: userInfoID=#{userInfoID}"

		pins = []
		if req.cookies.pinned
			pins = JSON.parse req.cookies.pinned

	top = """
<!--
<div class="main">
    <div class="a"><a href="#">Home</a></div>
    <div class="c"><a href="#">Contact</a></div>
</div>
<hr>
-->


<div class='mastbar'>
<span class='maintitle'>SkillsPlanet CMS</span>
<span class="mainmenu">
<!--<a href='/cms'>HOME</a>-->
<a href='/indent' title='show skills like a Gantt chart'>INDENT</a>
<a href='/h' title='show skills parent to children'>HIER</a>
<a href='/chk' title='integrity check'>CHK</a>
<a href='/raw' title='show skills in table as added'>RAW</a>
<a href='/addform' title='add new skill'>ADD</a>
</span>
&nbsp;&nbsp;&nbsp;&nbsp;

<span class="dbmenu">
<a href='/a' title='aim (intention for skill)'>a</a>
<a href='/at' title='auditTrail'>at</a>
<a href='/att' title='auditTrailType'>att</a>
<a href='/eh' title='emailHold'>eh</a>
<a href='/f' title='facet'>f</a>
<a href='/r' title='reward'>r</a>
<a href='/rt' title='rewardTrail'>rt</a>
<a href='/rk' title='rewardKey'>rk</a>
<a href='/rkt' title='rewardKeyTrail'>rkt</a>
<a href='/s' title='skill'>s</a>
<a href='/sl' title='skillLevel'>sl</a>
<a href='/st' title='skillTrail'>st</a>

<a href='/stag' title='skillTag'>sTAG</a>
<a href='/staga' title='skillTagArea'>sTAGa</a>
<a href='/s2stag' title='skill2skillTag'>s2sTAG</a>

<a href='/stt' title='skillTrailType'>stt</a>
<a href='/t' title='trivial'>t</a>
<a href='/ui' title='userInfo'>ui</a>
<a href='/ui2p' title='userInfo2password'>ui2p</a>
<a href='/ui2s' title='userInfo2skill'>ui2s</a>
<a href='/us' title='userState'>us</a>
</span>
&nbsp;&nbsp;&nbsp;&nbsp;

<span class='name'>#{nameFirst}</span>

<span class="mainmenu">
<a href='/logoff'>log off</a>
</span>

<span class='filterForm'><form action='/raw'><input type='text' name='term' placeholder='filter'><input type='submit' value='Filter'></form></span>
</div>"""

	Object.defineProperties {},
		_conn:
			value: null
			writable: true
		audit:
			enumerable: true
			value: (auditTrailTypeID, data) ->
				@log "AUDIT[#{auditTrailTypeID}] API##{reqCounter[1]} #{data}"
				@conn.query 'call auditTrailInsert(?,?,?,?)', [
					auditTrailTypeID
					if @userInfoID > 0 then @userInfoID else null
					null	#H:skillID	#HARDCODE
					data
				], (err, rsets) =>
					if err
						@logError "auditTrailInsert", err
		beg:
			enumerable: true
			value: ->
				if @userInfoID > 0
					@bPage = true

					@w beg
					@w top

					bWroteBar = false
					# if pins.length
					for o in pins
						unless bWroteBar
							bWroteBar = true
							@w "<div class='pinbar'>"
						@log "o", o
						@w "<span class='pin'><a style='background-color: #888; color: #fff;' href='/indent/#{o.skillID}/#{o.depth}'>#{if o.tag then o.tag else o.skillID}#{if o.depth is 100 then "" else "/#{o.depth}"}</a> <a style='background-color:#aaa; font-size:80%' href='/pinun/#{o.skillID}/#{o.depth}'>x</a></span>"

					if bWroteBar
						@w "</div>"
						@br()
						@br()

					# can't do asynchronous here without doing a callback or promise on each beg() for asynchronous
					#console.log "@content=#{@content}"
					#@conn.query 'call userGetIdentity()', (err, rsets) ->
					#	if err
					#		c.ex err
					#	else
					#		console.dir rsets
					#		recentsBuild c, rsets

					if @content
						@w @content

					if flash
						@h1 flash
					# @res.write "<br><i>click (skillID) that follows a skill to add a child</i><br><br>"
					@userInfoID		# truthy (authenticated)
				else
					@audit 3, "IP=#{req.headers['x-forwarded-for'] || req.connection.remoteAddress} UA=#{@req.get "User-Agent"}"
					@w "503 Server Error"		# intentionally confuse the end user
					@res.end()
					0				# falsy (not authenticated)
		bOpen:												#REDUNDANT?
			enumerable: true
			value: false
			writable: true
		bPage:
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
		emailSend:
			enumerable: true
			value: (to, subject, html) ->
				if throttle 0, "#{to}:#{subject}"
					transporter = nodemailer.createTransport
						host: "premium31.web-hosting.com"
						port: 465
						secure: true
						auth:
							user: "peter@skillsplanet.com"
							pass: "0728Mail"
					transporter.sendMail {
						from: '"Skills Planet" <peter@skillsplanet.com>'		#H: better account
						to: to
						subject: subject
						html: html
					}, (err, info) =>
						if err
							@logError "emailSend", err
						else
							@log "Message #{info.messageId} sent: #{info.response}"
		skillMap:
			enumerable: true
			value: null
			writable: true
		br:
			value: -> @w "<br>"
		childMap:
			enumerable: true
			value: null
			writable: true
		content:
			enumerable: true
			value: ''
			writable: true
		d:  												#DESTRUCTOR
			enumerable: true
			value: ->
				if @_conn
					@_conn.end()
					@bOpen = false
				if @bPage
					@res.write end
				@res?.end()
		logError:
			enumerable: true
			value: (s, e) ->
				try
					console.log "#{@logPre()} - ERROR - #{s} e=#{e} stringify=#{JSON.stringify e}"
					if PROD
						@textSend "+17048044786", "ERR: #{s}"
				catch ex
					console.log "(ERR)CATCH: #{ex}"
		logCatch:		# NOT text
			enumerable: true
			value: (s) ->
				try
					console.log "#{@logPre()} - ERROR - #{s}"
# NO! textSend
				catch ex
					console.log "(ERRNOT)CATCH: #{ex}"
		ex:
			enumerable: true
			value: (err, title, o) ->
				console.log "#{@logPre()} - EXCEPTION #{title}"
				console.dir err
				if o
					console.dir o
				if PROD
					@audit 6, "#{title}: #{JSON.stringify err}"
					@textSend "+17048044786", "EX: #{title} #{err}"
					@log "afer textSend"

				if @bPage
					@res.write "EXCEPTION!"

					if typeof myVar == 'string'
						@res.write err
					else
						@res.write JSON.stringify err

				@d()
		log:
			enumerable: true
			value: (s, o) ->
				objPart=""
				if o
					objPart=" o=#{o} stringify=#{JSON.stringify o}"
				console.log "#{@logPre()} - #{s}#{objPart}"
		logPre:
			enumerable: true
			value: (s) ->
				date = new Date()
				userPart = if @userInfoID then " - UID=#{@userInfoID}" else ""
				"logPre #{NN date.getMinutes()}:#{NN date.getSeconds()} -> #{BUILD}#{userPart}"
		nameFirst:
			enumerable: true
			value: nameFirst				# hit or miss
			writable: true
		pin:
			enumerable: true
			value: (skillID, depth, tag) ->
				myDate = new Date()
				myDate.setFullYear(myDate.getFullYear() + 5)

				pins.push skillID:skillID, depth:depth, tag:tag
				@log "PINNED", pins
				flash = "pin: #{tag}"

				@res.cookie 'pinned', JSON.stringify(pins), {expire: myDate}
		pinun:
			enumerable: true
			value: (skillID, depth) ->
# msg = "pin not found in cookies"
				pins = pins.filter (o) =>
# @log "COMP: #{o.skillID} vs. #{skillID} (#{typeof o.skillID}) vs (#{typeof skillID})"
# @log "COMP: #{o.skillID} vs. #{skillID} (#{typeof o.skillID}) vs (#{typeof skillID})"
					if o.skillID is skillID and o.depth is depth
						flash = "unpinned: #{o.tag}/#{o.depth}"
						false
					else
						true
				myDate = new Date()
				myDate.setFullYear(myDate.getFullYear() + 5)
				@res.cookie 'pinned', JSON.stringify(pins), {expire: myDate}

		recentSkillIDMap:
			enumerable: true
			value: Object.create null
			writable: true
		req:
			enumerable: true
			value: req
		res:
			enumerable: true
			value: res
		send:
			enumerable: true
			value: (v) ->
# @log "send: TYPE: #{typeof v}"
				if typeof v is "object"
					@res.write JSON.stringify v
				else
					@res.write v
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
		userInfoID:
			enumerable: true
			value: userInfoID
			writable: true
		w:
			enumerable: true
			value: (s) ->
				@res.write s
		wbr:
			enumerable: true
			value: (s) ->
				@res.write "#{s}<br>"
#
		h1:
			value: (s) -> if s then @w "<h1>#{s}</h1><br>"
		t:
			value: (arb) -> @w "<table#{if arb then " #{arb}" else ""}>"
		st:
			value: -> @w "</table>"
		tr:
			value: (arb) -> @w "<tr#{if arb then " #{arb}" else ""}>"
		str:
			value: -> @w "</tr>"
		td:
			value: (s, arb) ->
				if s
					@w "<td#{if arb then " #{arb}" else ""}>#{s}</t>"
				else
					@w "<td#{if arb then " #{arb}" else ""}>"
		std:
			value: -> @w "</td>"

		hid:
			value: (name) ->
				@w "<input name='#{name}' type='hidden' value='#{@req.params[name] ? @req.body[name]}'>"



app.get '/', (req, res) ->
	res.send 'Hello Michelle!!!'

###
 POST /skills Email= Password=
 POST /append UserID= SkillID=
 POST /delete UserID= SkillID=
 POST /search UserID= Term=
###

app.post '/emailHold', (req, res) ->
	c = contextFactory req, res, 0, "emailHold"
	c.conn.query 'call emailHold(?)', [
		req.body.email
	], (err, rsets) ->
		if err
			c.ex err, "emailHold: #{req.body.email}"
		else
			c.log "emailHold: #{req.body.email} => #{rsets[0][0].emailHoldID}"
			c.send emailHoldID: 1 * rsets[0][0].emailHoldID
			c.d()
app.post '/userUpdate', (req, res) ->
	c = contextFactory req, res, 0, "userUpdate"
	c.log "userUpdate: PRE", req.body
	#c.log "v2=#{emailHoldID}"
	#c.log "t2=#{typeof emailHoldID}"
	c.conn.query 'call userUpdate(?,?,?,?,?)', [
		req.body.nameFirst
		req.body.nameLast
		req.body.emailHoldID
		req.body.password
		req.body.userInfoID
	], (err, rsets) ->
		if err
			c.ex err, "userUpdate", req.body
		else
			c.send rsets[0][0]
			c.log "userUpdate: #{JSON.stringify req.body} =>", rsets[0][0]
			c.d()
app.post '/userLogIn', (req, res) ->
	c = contextFactory req, res, 0, "userLogIn"
	c.conn.query "call userLogIn(?,?)", [req.body.email, req.body.password], (err, rsets) ->
		if err
			c.send userInfoID: 0
			c.ex err
		else
			if rsets[0].info.numRows > 0
				ro =
					userInfoID: 1 * rsets[0][0].userInfoID
					nameFirst: rsets[0][0].nameFirst
					nameLast: rsets[0][0].nameLast
					email: rsets[0][0].email
					BUILD: BUILD
			else
				ro =
					userInfoID: 0
			c.log "userLogIn: #{req.body.email} / #{req.body.password} =>", ro
			c.send ro
			c.d()
# http://skillsplanet.com:3344/skillSearch/basic
app.get '/skillSearch/:term', (req, res) ->
	c = contextFactory req, res, 0, "skillSearch"
	c.conn.query "call skillSearch(?)", [req.params.term], (err, rsets) ->
		if err
			c.ex err
		else
			c.log "skillSearch: #{req.params.term}"
			c.send skillsList: rsets[0]
			c.d()
# http://skillsplanet.com:3344/emailSend
app.get '/emailSend', (req, res) ->
	c = contextFactory req, res, 0, "emailSend"
	c.write "sending test mail"
	c.emailSend "peter@skillsplanet.com", "hey there, good lucking!", "reply if you get this!"
	c.d()
## skillsplanet.com:3344/skillSelectAll
#app.get '/skillSelectAll', (req, res) ->
#	c = contextFactory req, res
#	c.log "skillSelectAll"
#	c.conn.query "call skillSelectAll", (err, rsets) ->
#		if err
#			c.ex err
#		else
#			c.send skillsList: rsets[0]
#			c.d()
app.post '/skillUserSelect', (req, res) ->
	c = contextFactory req, res, 0, "skillUserSelect"
	c.log "skillUserSelect"
	c.conn.query "call SkillUserSelect(?)", [req.body.userInfoID], (err, rsets) ->
		if err
			c.ex err
		else
			c.send
				userInfoID: req.body.userInfoID
				skillsList: rsets[0]
			c.d()
# skillsplanet.com:3344/stuffSelect
app.get '/stuffSelect', (req, res) ->
	c = contextFactory req, res, 0, "stuffSelect"
	# c.log "stuffSelect"
	c.conn.query "call stuffSelect()", (err, rsets) ->
		if err
			c.ex err
		else
			c.send rsets
			c.d()
app.post "/userPasswordSend", (req, res) ->
	c = contextFactory req, res, 0, "userPasswordSend"
	pinDDDD = rnd 1000, 9999
	email = req.body.email.trim()
	c.conn.query "call userPasswordSend(?,?)", [email, pinDDDD], (err, rsets) ->
		if err
			c.ex err
		else
			if rsets?.info?.numRows is '0'
				c.send
					mCode: 1
					msg: "account not found"
				c.log "userPasswordSend #{email}: account not found"
			else
				rs = rsets[0][0]

				c.emailSend email, "SkillsPlanet Temporary Password", "#{rs.nameFirst}, here is your temporary password: <strong>#{pinDDDD}</strong> that is valid for <i>two</i> hours."

				c.send
					mCode: 0
					msg: "password has been sent"

				c.log "userPasswordSend: #{pinDDDD} to #{email}"
			c.d()
app.post '/userRegister', (req, res) ->
	c = contextFactory req, res, 0, "userRegister"
	c.textSend "+17048044786", "#{req.body.userInfo.nameFirst} #{req.body.userInfo.nameLast} registered!"
	c.textSend "+17042934893", "#{req.body.userInfo.nameFirst} #{req.body.userInfo.nameLast} registered!"
	c.conn.query "call userRegister(?,?,?,?)", [req.body.userInfo.nameFirst, req.body.userInfo.nameLast, req.body.userInfo.emailHoldID, req.body.userInfo.password], (err, rsets) ->
		if err
			c.ex err
		else
			c.send userInfoID: 1 * rsets[0][0].userInfoID
			c.userInfoID = 1 * rsets[0][0].userInfoID
			c.log "userRegister: #{JSON.stringify req.body.userInfo} =>", rsets[0][0]
			c.d()
app.post '/userSkillAdd', (req, res) ->
	c = contextFactory req, res, 0, "userSkillAdd"
	c.conn.query "call userSkillAdd(?,?,?,?,?)", [req.body.userInfoID, req.body.skillID, req.body.facetID, req.body.aimID, req.body.skillLevelID], (err, rsets) ->
		if err
			c.ex err
		else
			c.send userInfoID: req.body.userInfoID
			c.log "userSkillAdd: skillID=#{req.body.skillID} skillLevelID=#{req.body.skillLevelID}"
			c.d()
app.post '/userSkillRemove', (req, res) ->
	c = contextFactory req, res, 0, "userSkillRemove"
	c.conn.query "call userSkillRemove(?,?)", [req.body.userInfoID, req.body.skillID], (err, rsets) ->
		if err
			c.ex err
		else
			c.send msg: "success"
			c.log "userSkillRemove: skillID=#{req.body.skillID}"
			c.d()
# http://skillsplanet.com:3344/usersSelectSkillID/13
app.get '/usersSelectSkillID/:skillID', (req, res) ->
	c = contextFactory req, res, 0, "userSelectSkillID"
	c.conn.query "call usersSelectSkillID(?)", [req.params.skillID], (err, rsets) ->
		if err
			c.ex err
		else
			c.send rsets[0]
			c.log "usersSelectSkillID: #{req.params.skillID}"
			c.d()
# http://skillsplanet.com:3344/msgSelect/1/5
app.get '/msgSelect/:userInfoFromID/:userInfoToID', (req, res) ->
	c = contextFactory req, res, 0, "msgSelect"
	c.conn.query "call msgSelect(?,?)", [req.params.userInfoFromID, req.params.userInfoToID], (err, rsets) ->
		if err
			c.ex err
		else
			c.send rsets[0]
			c.log "msgSelect: #{req.params.userInfoFromID} #{req.params.userInfoToID}"
			c.d()
# http://skillsplanet.com:3344/msgInbox/1
app.get '/msgInbox/:userInfoID', (req, res) ->
	c = contextFactory req, res, 0, "msgInbox"
	c.conn.query "call msgInbox(?)", [req.params.userInfoID], (err, rsets) ->
		if err
			c.ex err
		else
			c.send rsets[0]
			c.log "msgInbox: #{req.params.userInfoID}"
			c.d()
down = (c) ->
# c.log "down", c.req.body
	unless bodyList = qqq[_=c.req.body.userInfoFromID]
		bodyList = qqq[_] = []

	c.send bodyList
	# c.log "q_pop: bodyList.len=#{bodyList.length}"
	#H: guarantee of delivery???
	qqq[_].length = 0
	c.d()
app.post '/q_start', (req, res) ->	#USED?
	c = contextFactory req, res, 0, "q_start"
	c.log "q_start", req.body
	(qqq[req.body.userInfoToID] ?= []).push req.body
	down c
app.post '/q_push', (req, res) ->
	c = contextFactory req, res, 0, "q_push"
	c.log "q_push", req.body
	(qqq[req.body.userInfoToID] ?= []).push req.body
	down c
app.post '/q_pop', (req, res) ->
	c = contextFactory req, res, 0, "q_pop"
	down c







# RUN SERGEANT
# skillsplanet.com:3344/rs_barkSelect
app.get '/rs_barkSelect', (req, res) ->
	c = contextFactory req, res, 0, "rs_barkSelect"
	c.conn.query "call rs_barkSelect()", (err, rsets) ->
		if err
			c.ex err
		else
			c.send rsets
			c.d()




















beg = """
<html>
	<head>
		<!-- <link href='http://skillsplanet.com' rel='stylesheet' type="text/css"> -->
		<style>
			/* http://meyerweb.com/eric/tools/css/reset/
			   v2.0 | 20110126
			   License: none (public domain)
			*/

			html, body, div, span, applet, object, iframe,
			h1, h2, h3, h4, h5, h6, p, blockquote, pre,
			a, abbr, acronym, address, big, cite, code,
			del, dfn, em, img, ins, kbd, q, s, samp,
			small, strike, strong, sub, sup, tt, var,
			b, u, i, center,
			dl, dt, dd, ol, ul, li,
			fieldset, form, label, legend,
			table, caption, tbody, tfoot, thead, tr, th, td,
			article, aside, canvas, details, embed,
			figure, figcaption, footer, header, hgroup,
			menu, nav, output, ruby, section, summary,
			time, mark, audio, video {
				margin: 0;
				padding: 0;
				border: 0;
				font-size: 100%;
				font: inherit;
				vertical-align: baseline;
			}
			/* HTML5 display-role reset for older browsers */
			article, aside, details, figcaption, figure,
			footer, header, hgroup, menu, nav, section {
				display: block;
			}
			body {
				line-height: 1;
			}
			ol, ul {
				list-style: none;
			}
			blockquote, q {
				quotes: none;
			}
			blockquote:before, blockquote:after,
			q:before, q:after {
				content: none;
			}
			table {
				border-collapse: collapse;
				border-spacing: 0;
			}




			body {
				background-color: #{if PROD then "#eef" else "pink"};
				color: #000099;
				font-family: sans-serif;
			}

			a:link, a:visited {
				color: #004;
				text-decoration: none;
			}

			a:active, a:hover {
				color: #00F;
				text-decoration: underline;
			}

			form {
			   display: inline;
			   margin: 0;
			   padding: 0;
			}

			input {
				border-radius: 2px;
			}

			.copyright {
				font-size: 50%;
			}

			.filterForm___NOT_USED {
				background-color: plum;
				border-radius: 2px;
				margin-left: 4px;
				padding: 2px 8px; 8px; 8px;
			}
			.filterForm {
				margin-left: auto;
			}

/*
			.link-tips {
				background-color: #ddd;
				display: inline-block;
				color: #666;
			}
*/

			.flash {
				background-color: green;
				color: white;
				font-size: 200%;
			}

			.bigfield {
				font-size: 220%;
			}

			.biggerfield {
				font-size: 120%;
			}

			.biggerfield2 {
				font-size: 110%;
			}

			.bigtitle {
				font-size: 175%;
			}

			.help {
				background-color: #ddd;
				border-radius: 6px;
				color: #666;
				display: inline-block;
				padding: 8px 8px; 8px; 8px;
			}

			.help-field {
				font-weight: bold;
				padding-right: 2px;
			}

			.help-field-length {
				color: #888;
			}

			.maintitle {
				color: #fff;
				display: inline-block;	/* DNW for vertical align middle */
				vertical-align: bottom;	/* DNW for vertical align middle */
			}

			.mastbar {
				background-color: #000;
				display: flex;
			}

			.name {
				color: #fff;
			}

			.null {
				color: #ccc;
				font-style: italic;
			}

			.skillID:link, .skillID:visited, .skillID:hover, .skillID:active {
				color: #666;
				font-size: 60%;
				text-decoration: none;
			}

			table.dump tr td {
				background-color: white;
				border: 2px solid #{if PROD then "#eef" else "pink"};
			}

			li {
				padding-bottom: 1em;
				/* border-bottom: 1px solid #{if PROD then "#eef" else "pink"}; */
			}

			a.recent:link, a.recent:visited {
				background-color:yellow;
			}

			a.visible0:link, a.visible0:visited, a.visible0:hover, a.visible0:active {
				color: #666;
			}

			a.visible1:link, a.visible1:visited, a.visible1:hover, a.visible1:active {
				color: #000;
			}

			span.mainmenu a:link, span.mainmenu a:visited {
				background-color: #bbb;
				border-radius: 2px;
				color: #000;
				padding: 0 2px;
				text-decoration: none;
			}

			span.dbmenu a:link, span.dbmenu a:visited {
				background-color: white;
				border-radius: 2px;
				color: #888;
				padding: 0 2px;
				text-decoration: none;
			}

			.skillTag {
				background-color: orange;
				border-radius: 7px;
				color: #fff;
				display: inline-block;
				margin: 0 10px 0 20px;
				padding: 0 4px;
			}

			.linkType {
				border-radius: 7px;
				color: #fff;
				display: inline-block;
				margin: 0 10px 0 20px;
				padding: 0 4px;
			}

			.pinbar {
				background-color: #ccc;
				display: flex;
			}

			.pin {
				background-color: #666;
				border-radius: 2px;
				margin-right: 1em;

				color: pink;

				a:link, a:visited {		//DNW//H
					color: #fff;
					text-decoration: none;
				}

				a:active, a:hover {
					color: #f00;
					text-decoration: none;
				}
			}


			/* works but not flex
			.main { display: flex; }
			.a, .b, .c { background: #efefef; border: 1px solid #999; }
			.b { flex: 1; text-align: center; }
			.c { position: absolute; right: 0; } */

			/*SO: 22429853
			.main { display: flex; }
			.a, .c { background: #efefef; border: 1px solid #999; }
			.b { flex: 1; text-align: center; }
			.c {margin-left: auto;}*/
		</style>
	</head>
	<body>
"""

end = """
		<p></p>
		<br>
		<center class='copyright'>build #{BUILD} &copy SkillsPlanet.com</center>
	</body>
</html>"""


N = (s) ->
	if s is "null"
		""
	else if s and s.length > 0
		s
	else
		""

URL = (s) ->
	if s is "null"
		""
	else if s
		"<a href='http://#{s}'>#{s}</a>"
	else
		""

# skillID, visible, tag, skill, description
plus = (c, r) ->
# <a href='/surf/#{r.skillID}'>@</a>
	"<a #{if 0 and c.recentSkillIDMap[r.skillID] then "class='recent'" else ""} class='visible#{r.visible}' href='/skill/#{r.skillID}' title='skill: #{N r.skill}'>#{r.tag}</a><a href='/addform/#{r.skillID}' title='description: #{N r.description}' class='skillID'>(#{r.skillID})</a>"

raw = (req, res, filter, msg) ->
	if filter
		filterUC = filter.toUpperCase().trim()

	if (c = contextFactory req, res, 1, "raw").beg()
		c.log "raw: term=#{filter}"
		c.h1 msg
		c.conn.query "call skillSelectAllEditor", (err, rsets) ->
			if err
				c.ex err
			else
				c.w "<table class='dump'>"
				c.w "<tr><td>PID</td><td>skillID</td><td>hits</td><td>tag</td><td>skill</td><td>description</td><td>best URL</td><td>WikiPedia URL</td><td>our internal notes</td></tr>"
				for r in rsets[0]
					pre = post = ""
					bShow = false

					if filter
						if r.tag.toUpperCase().indexOf(filterUC) >= 0 or r.skillID is filterUC
							pre = "<span style='color:red;'>"
							post = "</span>"
							bShow = true
					else
						bShow = true

					if bShow
# <a href='/skill/#{r.skillID}'>#{pre + tag + post}</a>
						c.w "<tr><td style='color: #888'>#{r.parentID}</td><td style='font-weight: bold; background-color: #eee;'>#{r.skillID}</td><td>#{if r.CNT > 0 then r.CNT else ""}</td><td>#{plus c, r}</td><td>#{N r.skill}</td><td>#{N r.description}</td><td>#{URL r.bestURL}</td><td>#{URL r.wikiPediaURL}</td><td>#{N r.notes}</td></tr>"
				c.st()
				c.d()
#BAD-PATTERN: how pass callbacks?
skillSelectAllEditor = (c, fail, succ) ->
	c.log "skillSelectAllEditor"
	c.conn.query "call skillSelectAllEditor", (err, rsets) ->
		if err
			fail err
		else
			childMap = Object.create null
			skillMap = Object.create null
			for r in rsets[0]
				if !childMap[1 * r.parentID]
					childMap[1 * r.parentID] = [1 * r.skillID]
				else
					childMap[1 * r.parentID].push 1 * r.skillID
				skillMap[1 * r.skillID] = r
			# c.log "calling succ"
			c.skillMap = skillMap
			c.childMap = childMap
			succ skillMap, childMap
h = (req, res, filter, msg) ->
	if (c = contextFactory req, res, 1, "h").beg()
		if filter
			filterUC = filter.toUpperCase()
		c.h1 msg
		skillSelectAllEditor c, ((err) -> c.ex err), ->
			c.w "<table border='0'>"
			for skillID,skillRS of c.skillMap
				if (childList=c.childMap[skillID])?.length > 0
					c.w "<tr><td>#{plus c, skillRS}</td><td>"
					# c.log "LOOP: #{skillRS.skill}(#{skillRS.skillID}) childList.length=#{childList.length}", childList
					for childID in childList
						childRS = c.skillMap[childID]
						c.w "#{plus c, childRS} "
					c.w "</td></tr>"
			c.st()
			c.d()
indent = (c, req, res, filter, msg, skillID, depth) ->
# c.log "h: term=#{filter}"

	if c.beg()
		if filter
			filterUC = filter.toUpperCase()
		c.h1 msg
		skillSelectAllEditor c, ((err) -> c.ex err), ->
			drill = (level, parent) ->
				if level
					for i in [1..level]
						c.w "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
				# <span style='font-size:50%; color:#999;'>#{level}</span>
				c.w "#{plus c, parent}<br>"

				if level+1 < depth
					if childIDList = c.childMap[parent.skillID]
# c.log "L#{level} #{parent.tag}: count=#{childIDList.length}<br>"

						childIDList.sort (a,b) ->
							if c.skillMap[a].tag < c.skillMap[b].tag
								-1
							else
								1

						for childID in childIDList
							drill level+1, c.skillMap[childID]
			drill 0, c.skillMap[skillID]
			c.d()
form = (c, parentID, r) ->
	skillID = ""
	parentIDPart = if parentID then "value='#{parentID}'" else ""
	# c.log "YOU: #{parentIDPart}"
	checkedPart = "checked=checked"
	tag = ''
	skill = ''
	description = ''
	bestURL = ''
	wikiPediaURL = ''
	notes = ''
	# c.log "form", r
	verbPhrase = if r then 'skill/' + r.skillID else 'add'
	if r
		parentID = r.parentID
		unless r.visible is "1"
			checkedPart = ""
		parentIDPart = if r then "value='#{r.parentID}'" else ""
		tag = if r then "value='#{N r.tag}'" else ""
		skill = if r then "value='#{N r.skill}'" else ""
		description = if r then N(r.description) else ''
		bestURL = if r then "value='#{N r.bestURL}'" else ""
		wikiPediaURL = if r then "value='#{N r.wikiPediaURL}'" else ""
		notes = if r.notes != null then r.notes else ''
		c.w "<br><span class='bigtitle'>Edit skillID #{r.skillID}</span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"

		c.w "<form method='POST' action='/add'>"
		c.w "<input name='parentID' type='hidden' value='#{r.skillID}'>"
		c.w "<input name='visible' type='hidden' value='on'>"
		c.w "<input name='tag' size='15' maxlength='48' type='text' placeholder='tag'>"
		c.w "<input name='skill' type='hidden' value=''>"
		c.w "<input name='description' type='hidden' value=''>"
		c.w "<input type='submit' value='INSTANT CHILD ADD'>"
		c.w "</form>"

		c.w "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pin w/depth: "
		for n in [1..9]
			c.w " <a href='/pin/#{r.skillID}/#{n}/#{r.tag}'>#{n}</a>"

		c.br()
	else
		c.w "<br>Add<br>"
	c.w "<form method='POST' action='/#{verbPhrase}'>"
	c.w "<input name='parentID' tabindex='1' #{parentIDPart} size='5' type='text' placeholder='PID' #{if parentID then "" else "autofocus='true'"}>(pid)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
	c.w "<input name='visible' tabindex='2' type='CHECKBOX' #{checkedPart}> selectible by user"
	c.br()
	c.w "<input name='tag' tabindex='3' #{N tag} class='bigfield' size='32' maxlength='48' type='text' placeholder='tag (non-plural!)' required='true' #{if parentID then "autofocus='true'" else ""}>"
	c.br()
	c.w "<input name='skill' tabindex='4' #{N skill} class='biggerfield' size='60' size='96' maxlength='64' type='text' placeholder='skill phrase (only if different from tag)'>"
	c.br()
	c.w "<textarea cols='60' tabindex='5' name='description' class='biggerfield2' maxlength='1024' placeholder='skill sentence (if different from above)'>#{N description}</textarea><br>"
	#c.w "<input name='bestURL' tabindex='6' #{N bestURL} placeholder='non-WikiPedia URL' size='64' maxlength='256' type='text'><br>"
	#c.w "<input name='wikiPediaURL' tabindex='7' #{N wikiPediaURL} placeholder='WikiPedia URL' size='64' maxlength='256' type='text'><br>"
	c.w "<textarea cols='60' tabindex='8' rows='4' name='notes' maxlength='1024' placeholder='Internal company notes to each other'>#{notes}</textarea>"
	c.br()
	c.w "<input type='submit' tabindex='9' value='#{if r != null then "SUBMIT EDIT" else "SUBMIT ADD"}'>"
	c.w "</form>"


tipsWrite = (c) ->
	c.w """
<p></p>
<p></p>
<br>
<br>
<span class='help'>
<strong>Tips</strong>
<br>
<br>
<ul>
<li><span class='help-field'>PID:</span># of parent node (container or skill) for this skill/container to live under.  The top-most node is 1.  <u>Pay attention not create a cyclical loop by setting the parent of a child to a sub-child.  If editing a node freezes, then you've done this: call Pete!</u></li>

<li><span class='help-field'>checkbox:</span>uncheck if this is a 'container of skills' (added for hierarchical organization) instead of a real skill.  (e.g., "Computer Languages")</li>

<li><span class='help-field'>tag:</span>Capitalized (unless normally uncapitalized [e.g., Unix command 'grep']), short as possible, SINGULAR (non-plural), even if a "skill container."  Don't enter a job title ("System Administration" is better than "System Administrator").  <span class="help-field-length">[48 chars]</span></li>

<li><span class='help-field'>skill phrase:</span>if the tag is ambiguous (e.g., Java... programming language or coffee?), use a few words to more accurately describe the skill (e.g., "Java Programming Language").  <span class="help-field-length">[96 chars]</span></li>

<li><span class='help-field'>skill sentence:</span>English sentence to  disambiguate the skill so that the users have confirmation that what they are indeed choosing the skill they desire.   <span class="help-field-length">[1024 chars]</span></li>

<li><span class='help-field'>non-WikiPedia URL:</span>as far as you can tell the  best URL that describes the skill.   <span class="help-field-length">[256 chars]</span></li>

<li><span class='help-field'>WikiPedia URL:</span>the official WikiPedia URL.  <span class="help-field-length">[256 chars]</span></li>

<li><span class='help-field'>Internal notes:</span>anything that would help us manage this skill.  Questions you have to discuss later, etc.   <span class="help-field-length">[1024 chars]</span></li>
</ul>
</span>
"""



app.get '/raw', (req, res) ->
	raw req, res, req.query.term, ''

pair = (c,r,pre) ->
	"<a class='visible#{r["#{pre}_visible"]}' href='/skill/#{r["#{pre}_skillID"]}' title='skill: #{N r["#{pre}_skill"]}'>#{r["#{pre}_tag"]}</a><a href='/addform/#{r["#{pre}_skillID"]}' title='description: #{N r["#{pre}_description"]}' class='skillID'>(#{r["#{pre}_skillID"]})</a>"

app.get '/chk', (req, res) ->
	if (c = contextFactory req, res, 1, "chk").beg()
		c.h1 "Integrity Check"
		c.conn.query "call dupsSelect()", (err, rs) =>
			if err
				c.ex err, "dupsSelect"
			else
				c.t "class='dump'"
				if rs.length > 0
					c.tr()
					c.td "parent of 'A'"
					c.td ""
					c.td "duplicate 'A'"
					c.str()

					c.tr()
					c.td "parent of 'B'"
					c.td ""
					c.td "duplicate 'B'"
					c.str()

					c.tr()
					c.td "&nbsp;"
					c.td "&nbsp;"
					c.td "&nbsp;"
					c.str()
				for r in rs[0]
					c.tr()
					c.td pair c, r, "p1"
					c.td "/"
					c.td pair c, r, "s1"
					c.str()
					c.tr()
					c.td pair c, r, "p2"
					c.td "/"
					c.td pair c, r, "s2"
					c.str()

					c.tr()
					c.td "&nbsp;"
					c.td "&nbsp;"
					c.td "&nbsp;"
					c.str()
				c.st()
				c.d()

app.get '/h', (req, res) ->
	h req, res, req.query.term, ''

app.get '/indent/:skillID?/:depth?', (req, res) ->
	c = contextFactory req, res, 1, "indent"
	indent c, req, res, req.query.term, '', req.params.skillID ? 1, req.params.depth ? 100

app.get '/pin/:skillID/:depth?/:tag?', (req, res) ->
	c = contextFactory req, res, 1, "indent"
	c.pin c.req.params.skillID ? 1, c.req.params.depth ? 100, c.req.params.tag
	indent c, req, res, "", '', req.params.skillID ? 1, req.params.depth ? 100

app.get '/pinun/:skillID/:depth?', (req, res) ->
	c = contextFactory req, res, 1, "pinun"
	c.pinun c.req.params.skillID, c.req.params.depth
	if c.beg()
		c.d()

app.get '/cms/:password?', (req, res) ->
	bCookieWritten = false
	userInfoID = 0
	switch req.params.password
		when "Peter"
			userInfoID = 1
			nameFirst = "Peter"
		when "Michelle"
			userInfoID = 2
			nameFirst = "Michelle"
		when "Dave"
			userInfoID = 3
			nameFirst = "Dave"
		when "Steve"
			userInfoID = 4
			nameFirst = "Steve"
		when "Bryan"
			userInfoID = 5
			nameFirst = "Bryan"
		when "Paul"
			userInfoID = 8
			nameFirst = "Paul"

	c = contextFactory req, res, 1, "cms", userInfoID, nameFirst
	if c.userInfoID > 0
		myDate = new Date()
		myDate.setFullYear(myDate.getFullYear() + 5)
		res.cookie 'userInfoID', c.userInfoID, {expire: myDate}
		res.cookie 'nameFirst', c.nameFirst, {expire: myDate}
		bCookieWritten = true
		c.audit 2, "AUTHENTICATED!"

	if c.beg()
		if bCookieWritten
			c.h1 "YOU HAVE BEEN AUTHENTICATED!  Giving you some cookies!"
		# #{if PROD then "/cms" else "/dev"}
		c.w "Welcome #{c.nameFirst}!"
		c.d()


app.get '/logoff', (req, res) ->
	res.clearCookie "userInfoID"
	res.clearCookie "nameFirst"
	res.clearCookie "UserInfoID"
	res.clearCookie "CMSAuthenticated"
	res.clearCookie "pinned"
	c = contextFactory req, res, 1, "logoff"
	c.beg()
	c.log "logoff"
	c.h1 "CMS cookies deleted"
	c.d()


skillTags = (c, skillID, rs) ->
	for r in rs
		c.w "<span class='skillTag'>#{r.skillTagArea}: #{r.skillTag}</span>"
	c.w "<span class='mainmenu'><a href='/addtag/#{skillID}'>ADD TAG</a></span>"


#parent = (c, r) ->
#	c.t()	#R
#	c.tr()
#	c.td()
#	if r
#		#skillSelectAllEditor c, ((err) -> c.ex err), ->
#		#pathWrite c, r.skillID
#		c.w "parent: "
#		c.w "#{plus c, r}"
#	c.std()
#	c.str()
#	c.st()


app.get '/skill/:skillID', (req, res) ->
	c = contextFactory req, res, 1, "skill"
	after c, req.params.skillID, null

after = (c, skillID, msg) ->
	skillID = 1 * skillID
	c.log "after: skillID=#{skillID}"
	if c.beg()
		c.conn.query 'call skillSelectEditor(?)', [ skillID ], (err, rs) ->
			if err
				c.ex err
			else
				par = rs[1][0]

				# c.log "after", rs[0][0]
				# c.log "after", rs[1][0]

				if msg
					c.w "<div class='flash'>#{msg}</div><br><br>"

				c.t()

				if par
					c.tr()
					c.td null, "bgcolor='#9e9' colspan='2'"
					for r in rs[0].slice(0).reverse()
# c.w "#{r.skillID} #{skillID}"
# c.log "WHUT", r
						if 1 * r.skillID isnt 1 * skillID		# and 1 * r.skillID isnt 1 * par.skillID
							c.w "#{plus c, r}"
							c.w " / "
					c.std
					c.str()

				#					c.tr()
				#					c.td null, "bgcolor=#dfd colspan='2'"
				#					# c.w "parent:"
				#					c.br()
				#					c.br()
				#					c.w "#{plus c, par}"
				#					if r.skill
				#						c.w "&nbsp;&nbsp;&nbsp;&nbsp;(#{par.skill})"
				#					if r.description
				#						c.w "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>#{par.description}</strong>"
				#					c.br()
				#					c.std()
				#					c.str()

				c.tr()
				c.td null, "bgcolor=#ccf"
				form c, null, rs[2][0]
				skillTags c, skillID, rs[7]
				c.br()
				c.br()

				#LINKS
				c.t()
				c.tr()
				c.td null, "bgcolor='yellow' colspan='2'"
				c.w "Website Page Links"
				c.br()
				c.t "class='dump'"
				for r in rs[8]
					c.tr()
					# c.td r.linkID
					c.td linkType r
					c.td r.caption
					c.td "<a href='http://#{r.url}' target='_blank'>#{r.url}</a>"
					c.str()
				c.st()
				c.w "<span class='mainmenu'><a href='/addlink/#{skillID}'>ADD LINK</a></span>"
				#
				c.std
				c.str()
				c.st()

				c.std()
				c.td null, "bgcolor=#ddf"
				if par
					c.w "<span class='mainmenu'><a href='/addform/#{par.skillID}'>ADD SIBLING</a></span>"
				for r in rs[3]
					c.br()
					c.w "#{plus c, r}"
					if 1 * r.skillID is 1 * skillID
						c.w " ME"
				c.std()
				c.str()

				c.tr()
				c.td null, "bgcolor=#dfd colspan='2'"
				c.br();
				c.w "<span class='mainmenu'><a href='/addform/#{skillID}'>ADD CHILD</a></span>"
				for r in rs[4]
					c.br()
					c.w "#{plus c, r}"
				c.td()
				c.str()

				c.tr()
				c.td null, "bgcolor='#9e9' colspan='2'"
				b = false
				for r in rs[5]
					c.w "<hr>" if b
					b = true
					c.w r.trivia
				c.br()
				c.w "<form method='POST' action='/trivia/#{skillID}'>"
				#c.w "<input type='hidden' name='skillID' value='#{skillID}}'>"
				c.w "<textarea cols='80' rows='5' name='trivia' maxlength='1024' placeholder='interesting trivia sentence'></textarea>"
				c.br()
				c.w "<input type='submit' value='SUBMIT NEW TRIVIA'>"
				c.w "</form>"
				c.std
				c.str()

				#				c.tr()
				#				c.td null, "bgcolor='orange' colspan='2'"
				#				c.w "Website Page Links"
				#				c.br()
				#				c.t "class='dump'"
				#				for r in rs[8]
				#					c.tr()
				#					# c.td r.linkID
				#					c.td linkType r
				#					c.td r.caption
				#					c.td "<a href='http://#{r.url}' target='_blank'>#{r.url}</a>"
				#					c.str()
				#				c.st()
				#				c.w "<span class='mainmenu'><a href='/addlink/#{skillID}'>ADD LINK</a></span>"
				#				#
				#				c.std
				#				c.str()


				c.st()
				c.br()
				c.br()
				bulkForm c, skillID
				c.br()
				c.br()

				c.w "Modification History"
				c.br()
				c.br()

				c.t "class='dump'"
				for r in rs[6]
					c.tr()
					c.td r.initials
					c.td r.inserted
					c.td r.skillTrailType
					c.td r.newValues
					c.str()
				c.st()

				# tipsWrite c

				c.d()

FN = (s) ->
	if s is "null" or !s or s.length is 0
		null
	else
		s

FNon = (s) ->
	if s is "on"
		1
	else
		0

stripHTTP = (s) ->
	s = (s ? "").trim()
	if s.startsWith "http://"
		s = s[7..]
	else if s.startsWith "https://"
		s = s[8..]
	s.trim()

recentsWrite = (c, fail, succ) ->
	c.conn.query 'call skillRecentSelect', (err, rsets) ->
		if err
			c.ex err
			failure()
		else
			recentsBuild c, rsets
			c.w c.content
			succ()

recentsBuild = (c, rsets) ->
	s = "<br>"
	for r in rsets[1]
		c.recentSkillIDMap[r.skillID] = r	#not complete skill record
		s += "#{plus c, r}(#{r.nameFirst} #{r.skillTrailType}) "
	# c.log "c.content=#{c.content}"
	s += """
<br>
<br>
<div class='help'>
<strong>Tips</strong>
<br>
<br>
<a class='visible1' href='/skill/1' title='CLICK TO EDIT'>tagName</a><a href='/addform/1' title='CLICK ME TO ADD CHILD' class='skillID'>(123)</a>
<br>
click on skill/container name to edit<br>
click on the trailing (id) to add child
</div>
</p>
"""
	c.content = s
# c.log "recentsBuild: s=#{c.content}"


app.post '/bulk', (req, res) ->
	c = contextFactory req, res, 1, "bulk"
	if c.beg()
		c.w "Here's what I got:"
		c.br()

		lines = req.body.lines.split /\r?\n/		#SO:21895354

		for s in lines
			s = s.trim()

			if s.length
				if +s is +s
					c.br()
					c.br()
					c.wbr "PARENTID=#{s}"
				else if s.length > 0
					c.wbr "=> #{s}"
		c.br()

		inserts = 0
		parentID = 2
		insertOne = (j) ->
			c.log "insertOne: j=#{j}"

			if j >= lines.length
				c.wbr "ALL DONE: inserts completed=#{inserts}"
				c.d()
			else
				s = lines[j].trim()

				if s.length
					c.log "insertOne: s=#{s}"

					if +s is +s
						parentID = +s
						c.log "parentID=#{parentID}"
						insertOne j+1
					else
						tag = FN s
						if tag.length > 48
							tag = tag[0..47]
							c.w "TRUNCATED at 48 characters: #{tag}"
						c.log "calling"
						c.conn.query 'call skillInsert(?,?,?,?,?,?,?,?,?)', [
							c.userInfoID
							FN(parentID)
							FNon("on")
							tag
							FN("")
							FN("")
							FN("")
							FN("")
							FN("")
						], (err, rsets) ->
							if err
								c.wbr "EXCEPTION OCCURRED AT SOME POINT DURING BATCH ADD... not sure what inserted and what did not"
								c.ex err
							else
								c.wbr "insert success!"
								inserts++
								insertOne j+1
				else
					insertOne j+1
		insertOne 0
app.post '/add', (req, res) ->
	if FN req.body.tag
		c = contextFactory req, res, 1, "add"
		c.conn.query 'call skillInsert(?,?,?,?,?,?,?,?,?)', [
			c.userInfoID
			FN(req.body.parentID)
			FNon(req.body.visible)
			FN(req.body.tag)
			FN(req.body.skill)
			FN(req.body.description)
			FN(stripHTTP req.body.bestURL)
			FN(stripHTTP req.body.wikiPediaURL)
			FN(req.body.notes)
		], (err, rsets) ->
			if err
				c.ex err
			else
# after c, rsets[0][0].skillID, "added skillID #{rsets[0][0].skillID}"
				after c, req.body.parentID, "added skillID #{rsets[0][0].skillID}"
	else
		res.redirect "addform/#{req.body.parentID}"
app.post '/skill/:skillID', (req, res) ->
	c = contextFactory req, res, 1, "skill"
	c.log "skillUpdate"
	if +req.body.parentID is +req.params.skillID
		if c.beg()
			c.w "Whoa!  DANGER: you set the parentID to your own skillID, which would create an infiniite loop.  Please hit back button and correct!"
			c.d()
	else if FN(req.body.tag) is "Root"
	else
#H: dangerous: can post without authentication!
		c.conn.query 'call skillUpdate(?,?,?,?,?,?,?,?,?,?)', [
			c.userInfoID		#H: where does this come from???
			FN(req.body.parentID)
			FNon(req.body.visible)
			FN(req.body.tag)
			FN(req.body.skill)
			FN(req.body.description)
			FN(stripHTTP req.body.bestURL)
			FN(stripHTTP req.body.wikiPediaURL)
			FN(req.body.notes)
			FN(req.params.skillID)
		], (err, rsets) ->
			if err
				c.ex err
			else
# after c, req.params.skillID, "saved"
				after c, req.body.parentID, "saved"
app.post '/trivia/:skillID', (req, res) ->
	c = contextFactory req, res, 1, "skill"
	c.log "trivia"
	c.conn.query 'call triviaInsert(?,?,?)', [
		c.userInfoID
		FN(req.params.skillID)
		FN(req.body.trivia)
	], (err, rsets) ->
		if err
			c.ex err
		else
			after c, req.params.skillID, "saved"

bulkForm = (c, parentID) ->
	c.t()
	c.tr()
	c.td()

	c.w "<br>Bulk Add<br>"
	c.w "<form method='POST' action='/bulk'>"
	c.w "<textarea cols='80' rows='10' name='lines' placeholder='see example below'>#{if parentID then parentID else ""}</textarea>"
	c.br()
	c.w "<input type='submit' value='SUBMIT BULK ADD'>"
	c.w "</form>"

	c.std()
	c.td()

	c.w """
<p></p>
<p></p>
<br>
<br>
<span class='help'>
<strong>Bulk Example</strong>
<br>
<br>
2<br>
underwater basket weaving<br>
corn husking<br>
<br>
100<br>
C++<br>
Java<br>
<br>
If no parentID is specified they are added to UNCLASSIFIED (parentID=2).
</span>"""

	c.std()
	c.str();
	c.st();

app.get '/addform/:parentID?', (req, res) ->
	if (c = contextFactory req, res, 1, "addform").beg()
# c.log "addform: pid=#{req.params.parentID}"
#TEST c.ex {peter:"alvin"}, "some mssg"
		form c, req.params.parentID, null
		tipsWrite c
		c.br()
		c.br()
		bulkForm c, req.params.parentID
		c.d()

pathWrite = (c, skillID) ->
	c.log "buildPath #{skillID}"
	sID = skillID
	s = ""
	delim = ""
	while sID > 0
		c.log "loop: sID=#{sID}"
		r = c.skillMap[sID]

		if r
			s = plus(c,r) + delim + s
			sID = r.parentID
		else
			c.log "sID=#{sID} null"
			s = "SURF_ERROR"
			sID = 0
		delim = " / "
	c.w "<br><br>#{s}<br><br>"


app.get '/addtag/:skillID', (req, res) ->
	if (c = contextFactory req, res, 1, "addtag").beg()
		c.h1 "Add Tag"
		c.conn.query query="call skillTagSelectAllEditor()", (err, rsets) =>
			if err
				c.ex err, query
			else
				for r in rsets[0]
					c.w "<a href='/addtagsubmit/#{req.params.skillID}/#{r.skillTagID}'><span class='skillTag'>#{r.skillTagArea}: #{r.skillTag}</span> #{r.phrase} // #{r.description}</a>"
					c.br()
				c.d()
app.get '/addtagsubmit/:skillID/:skillTagID', (req, res) ->
	c = contextFactory req, res, 1, "addtagsubmit"
	c.conn.query "call skill2skillTagInsert(?,?,?)", [
		c.userInfoID
		FN(req.params.skillID)
		FN(req.params.skillTagID)
	], (err, rsets) ->
		if err
			c.ex err
		else
			after c, req.params.skillID, "skillTag added"


linkType = (r) -> "<span style='background-color:#{r.color}' class='linkType'>#{r.linkType}</span>"

app.get '/addlink/:skillID', (req, res) ->
	if (c = contextFactory req, res, 1, "addlink").beg()
		c.h1 "Add Link"
		c.conn.query query="call linkTypeSelectAllEditor()", (err, rsets) =>
			if err
				c.ex err, query
			else
				for r in rsets[0]
					c.w "<a href='/addlinksubmit/#{req.params.skillID}/#{r.linkTypeID}'>#{linkType r}</a>"
					c.br()
				c.d()
app.get '/addlinksubmit/:skillID/:linkTypeID', (req, res) ->
	if (c = contextFactory req, res, 1, "addlinksubmit").beg()
		c.w "<br>Add Link<br>"
		c.w "<form method='POST' action='/addlinksubmit2'>"
		c.hid "skillID"
		c.hid "linkTypeID"
		c.w "<input name='url' size='256' type='text' placeholder='URL'>"
		c.br()
		c.w "<input type='submit' value='SUBMIT'>"
		c.w "</form>"
		c.d()
app.post '/addlinksubmit2', (req, res) ->
	c = contextFactory req, res, 1, "addlinksubmit2"
	c.conn.query "call linkInsert(?,?,?,?)", [
		c.userInfoID
		FN(req.body.skillID)
		FN(req.body.linkTypeID)
		FN(stripHTTP req.body.url)
	], (err, rsets) ->
		if err
			c.ex err
		else
			after c, req.body.skillID, "link added"



##########
hhh = (req, res, tableName, orderBy) ->
	if (c = contextFactory req, res, 1, "hhh").beg()
		c.h1 tableName
		c.conn.query query="select * from #{tableName} order by #{orderBy ? "#{tableName}ID DESC"}", (err, rs) =>
			if err
				c.ex err, query
			else
				c.t "class='dump'"
				if rs.length > 0
					c.tr()
					for cn of rs[0]
						c.td "<strong>#{cn}</strong>"	#DNW: bold
					c.str()
				for r in rs
					c.tr()
					for cn of r
						c.td "#{if r[cn] is null then "<span class='null'>null</span>" else if r[cn] then r[cn] else '&nbsp;'}"
					c.str()
				c.st()
				c.d()
app.get '/a', (req, res) ->				hhh req, res, "aim"
app.get '/at', (req, res) ->			hhh req, res, "auditTrail"
app.get '/att', (req, res) ->			hhh req, res, "auditTrailType"
app.get '/eh', (req, res) ->			hhh req, res, "emailHold"
app.get '/f', (req, res) ->				hhh req, res, "facet"
app.get '/r', (req, res) ->				hhh req, res, "reward"
app.get '/rk', (req, res) ->			hhh req, res, "rewardKey"
app.get '/rkt', (req, res) ->			hhh req, res, "rewardKeyTrail"
app.get '/rt', (req, res) ->			hhh req, res, "rewardTrail"
app.get '/s', (req, res) ->				hhh req, res, "skill"
app.get '/sl', (req, res) ->			hhh req, res, "skillLevel", "skillID ASC, skillLevelID DESC"
app.get '/st', (req, res) ->			hhh req, res, "skillTrail"
app.get '/stag', (req, res) ->			hhh req, res, "skillTag"
app.get '/staga', (req, res) ->			hhh req, res, "skillTagArea"
app.get '/s2stag', (req, res) ->		hhh req, res, "skill2skillTag", "skillID ASC, skillTagID DESC"
app.get '/stt', (req, res) ->			hhh req, res, "skillTrailType"
app.get '/t', (req, res) ->				hhh req, res, "trivia"
app.get '/ui', (req, res) ->			hhh req, res, "userInfo"
app.get '/ui2p', (req, res) ->			hhh req, res, "userInfo2password", "UI2PID DESC"
app.get '/ui2s', (req, res) ->			hhh req, res, "userInfo2skill", "inserted DESC"
app.get '/us', (req, res) ->			hhh req, res, "userState"
##########

#app.get '/surf/:skillID?', (req, res) ->
#	skillID = req.params.skillID ? 1
#	c = contextFactory req, res
#	if c.beg()
#		c.conn.query 'call SkillRecentSelect', (err, rsets) ->
#			if err
#				c.ex err
#			else
#				# console.dir rsets
#				recentsBuild c, rsets
#				c.w c.content
#				skillSelectAllEditor c, ((err) -> c.ex err), ->
#					c.w "worked!"
#					surf c, skillID
#					c.d()

#app.listen PORT_CMS, ->
#	console.log "======================================================================"
#	console.log "SkillsPlanet API and CMS #{BUILD} running on port #{PORT_CMS}"




if 0
#  ####################################
#  ######### MOVED TO aws.js ##########
#  ####################################

# FILE UPLOAD
#express = require('express')
	multer = require 'multer'
	upload = multer(dest: 'uploads/')
	# app = express()
	app.post '/upload', upload.single('avatar'), (req, res, next) ->
		lg "slash upload"
		# req.file is the `avatar` file
		# req.body will hold the text fields, if there were any
		return
	lg "END--near end of file"
	#app.post '/photos/upload', upload.array('photos', 12), (req, res, next) ->
	#	# req.files is array of `photos` files
	#	# req.body will contain the text fields, if there were any
	#	return
	#cpUpload = upload.fields([
	#	{
	#		name: 'avatar'
	#		maxCount: 1
	#	}
	#	{
	#		name: 'gallery'
	#		maxCount: 8
	#	}
	#])
	#app.post '/cool-profile', cpUpload, (req, res, next) ->
	#	# req.files is an object (String -> Array) where fieldname is the key, and the value is array of files
	#	#
	#	# e.g.
	#	#  req.files['avatar'][0] -> File
	#	#  req.files['gallery'] -> Array
	#	#
	#	# req.body will contain the text fields, if there were any

	app.get '/formtest', (req, res) ->
		c = contextFactory req, res, 1, "formtest"
		if c.beg()
			c.w "<form method='POST' action='/upload'><input type='text' name='avatar' value='avatar'><input type='submit' value='POST'></form>"
			c.d()
	app.get '/formtest3399', (req, res) ->
		c = contextFactory req, res, 1, "formtest3399"
		if c.beg()
			c.w "<form method='POST' action='http://www.skillsplanet.com:3399/upload'><input type='text' name='avatar' value='avatar'><input type='submit' value='POST'></form>"
			c.d()
	app.get '/gettest', (req, res) ->
		c = contextFactory req, res, 1, "gettest"
		c.log "gettest: params: ", req.params
		c.d()
	app.post '/posttest', (req, res) ->
		c = contextFactory req, res, 1, "posttest"
		c.log "posttest: body: ", req.body
		c.d()





	# https://developer.apple.com/library/content/documentation/MusicAudio/Conceptual/CoreAudioOverview/CoreAudioEssentials/CoreAudioEssentials.html
	# Use local .env file for env vars when not deployed

	# https://developer.apple.com/library/content/documentation/MusicAudio/Conceptual/CoreAudioOverview/CoreAudioEssentials/CoreAudioEssentials.html
	# Use local .env file for env vars when not deployed
	if process.env.NODE_ENV != 'production'
		require('dotenv').config()
	aws = require 'aws-sdk'
	multer = require('multer')
	multerS3 = require('multer-s3')
	#s3 = new aws.S3
	#	accessKeyId: process.env.AWS_ACCESS_KEY_ID
	#	secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
	#	region: 'us-east-1'
	## console.log("s3: " + JSON.stringify(s3));
	## Initialize multers3 with our s3 config and other options
	## https://www.npmjs.com/package/multer-s3
	#upload = multer
	#	storage: multerS3
	#		s3: s3
	#		bucket: process.env.AWS_BUCKET
	#		acl: 'public-read'
	#		metadata: (req, file, cb) ->
	#			console.log 'metadata'
	#			cb null, fieldName: file.fieldname
	#		key: (req, file, cb) ->
	#			console.log 'key'
	#			cb null, Date.now().toString() + '.caf'


	# Expose the /upload endpoint
	app = require('express')()
	http = require('http').Server app
	nbr = 0

	app.post '/upload', upload.single('avatar'), (req, res, next) =>
		console.log "[#{nbr++}] /upload triggered"
		res.json req.file

		# console.log(`JSON: ${JSON.stringify(o)}`);
		o = req.file
		for pn of o
			console.log "prop: #{pn}: #{o[pn]}"
		console.log ""

		# console.log(`files.length=${req.files.length}`);
		o = req.file.metadata
		for pn of o
			console.log "metadata: #{pn}: #{o[pn]}"
		console.log ""

	port = 3399
	http.listen port, =>
		console.log "Listening on port #{port}"





#lg "websocket listening"
#app.ws '/echo', (ws, req) ->
#	lg "SIGNS OF LIFE"
#	ws.on 'message', (msg) ->
#		ws.send msg

