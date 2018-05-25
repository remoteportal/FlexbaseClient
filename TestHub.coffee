Base = require './Base'
FBClientNode = require './FBClientNode'
O = require './O'
trace = require './trace'
util = require './Util'



class TestHub extends Base
	constructor: (@c) ->
		super "TestHub"
#		O.DUMP @c


	#RV: fbc.user
	clientFBCCreateUserRandomRegister: ->
		new Promise (resolve, reject) =>
			fbc = new FBClientNode @c, @c.directory
			fbc.start @c.URL								#H: eliminate?
			fbc.get @objectIDLookup @FLEXBASE_AUTH			#H: catch-22?  it's not local yet so how get???
			.then (auth) =>
				fbc.auth = auth
				userRandomRegister auth
			.then (user) =>
				fbc.user = user
				resolve fbc
			.catch (ex) =>
				reject ex

	clientFBCUserLogon: (username, password) ->
		new Promise (resolve, reject) =>
			fbc = new FBClientNode @c, @c.directory
			fbc.start @c.URL
			fbc.get @objectIDLookup @FLEXBASE_AUTH
			.then (auth) =>
				fbc.auth = auth
				fbc.logon username, password
			.then (user) =>
				fbc.user = user
				resolve fbc
			.catch (ex) =>
				reject ex

	emailRandom: -> "test#{util.random 1000,9999}@test.com"

	fnameRandom: -> util.randomPick "fname", "Peter,Deanna,Desirina,Morgan,Deanelle,Dustin,Lauren,Dean,Ashley,Derrick,Parker,Daebrionne"

	lnameRandom: -> util.randomPick "lname", "Alvin,Boksovich,Pearce"

	passwordRandom: -> util.random 1000,9999


	resetSync: ->
		util.fs_directoryDeleteRecursive "/tmp/ut"


	startClient: (directory) ->
		new Promise (resolve, reject) =>
#			@log "startClient: #{spaceName}"														if trace.TESTHUB or trace.CONSTRUCTORS

			@c.PORT_WEB_SOCKET = if @c.PROD then 3355 else 3366

			if @c.CLOUD
				@c.URL = "ws://www.skillsplanet.com:#{@c.PORT_WEB_SOCKET}"
			else
				@c.URL = "ws://localhost:#{@c.PORT_WEB_SOCKET}"

			#H #WRONG: the testHub.start should NOT create a client... I think
			@client = new FBClientNode @c, directory
				
			resolve @client
			
			
	tablesCreate: ->
		sql = """
CREATE TABLE `object` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dateInserted` timestamp NOT NULL DEFAULT current_timestamp(),
  `dateUpdated` timestamp NOT NULL DEFAULT current_timestamp(),
  `parentID` int(11) unsigned NOT NULL,
  `ownerID` int(11) unsigned NOT NULL DEFAULT 1,
  `isPublic` bit(1) NOT NULL DEFAULT b'0',
  `data` text NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `parentID__object_objectID` (`parentID`),
  KEY `ownerID__userInfo_userInfoID` (`ownerID`)
) ENGINE=InnoDB AUTO_INCREMENT=225 DEFAULT CHARSET=utf8 COMMENT='the object repository'
"""

	URLGet: ->
		@c.URL

	usernameRandom: -> util.randomPick "username", "remoteportal"

	userRandomRegister: (auth) ->
		auth.register @usernameRandom(), @passwordRandom(), @emailRandom(), @fnameRandom, @lnameRandom()




module.exports = TestHub
