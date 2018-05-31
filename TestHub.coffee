API = require './API'
Base = require './Base'
ClientFB = require './ClientFB'
O = require './O'
ServerFB = require './ServerFB'
trace = require './trace'
util = require './Util'




class TestEnv extends Base
	destroy: ->
		new Promise (resolve, reject) =>
			@log "destroy"
			@server.listen false
			resolve()
	infoFN: ->
		"TestEnv: serverPort=#{@server.port}"


class TestHub extends Base
	constructor: (@c) ->
		super "TestHub"
		@port = 3370			#H #HARDCODE
#		O.LOG @c


	#RV: fbc.user
	clientFBCCreateUserRandomRegister: ->
		new Promise (resolve, reject) =>
			fbc = new ClientFB @c, @c.directory
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
			fbc = new ClientFB @c, @c.directory
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

	info: "TestHub info"

	infoFN: ->
		"TestHub: port=#{@port}"
	
	lnameRandom: -> util.randomPick "lname", "Alvin,Boksovich,Pearce"

	passwordRandom: -> util.random 1000,9999


	portNext: -> @port++


	resetSync: ->
		util.fs_directoryDeleteRecursive "/tmp/ut"


	serverFresh: ->
		new Promise (resolve, reject) =>
#			@log "serverFresh"

			testEnv = new TestEnv()

			#TODO #REFACTOR: move all this into TestEnv?
			@tablesCreate()
			.then =>
				@log "tables created"

				testEnv.port = @portNext()
				testEnv.clientDirectory = "#{@c.directory}/c_#{testEnv.port}"
				testEnv.serverDirectory = "#{@c.directory}/s_#{testEnv.port}"

				class _Server extends ServerFB
					onReceiveSync: (mgr, po) ->
	#					@log "onReceive", po
						mgr.reply answer:"rain"

				testEnv.server = new _Server testEnv.port, testEnv.serverDirectory
				testEnv.server.listen true
			.then =>
#				@log "all set!"
				resolve testEnv
			.catch (ex) =>
				@logCatch "serverFresh", ex
				reject()
	startClient: (directory) ->
		new Promise (resolve, reject) =>
#			@log "startClient: #{spaceName}"														if trace.TESTHUB or trace.CONSTRUCTORS

			@c.PORT_WEB_SOCKET = if @c.PROD then 3355 else 3366

			if @c.CLOUD
				@c.URL = "ws://www.skillsplanet.com:#{@c.PORT_WEB_SOCKET}"
			else
				@c.URL = "ws://localhost:#{@c.PORT_WEB_SOCKET}"

			#H #WRONG: the testHub.start should NOT create a client... I think
#			#TODO: @client = new ClientFB @c, directory
				
			resolve @client
			
			
	tablesCreate: ->
		new Promise (resolve, reject) =>
###
create database ut;

use ut;

create user ut@localhost

GRANT CREATE ROUTINE,ALTER ROUTINE,ALTER,CREATE,DROP,INSERT,EXECUTE,SELECT,UPDATE ON ut.* TO 'ut'@'localhost';
flush privileges;

CREATE ROUTINE --for--> create procedure
ALTER ROUTINE --for--> drop procedure
###


			c = API.apiFactory()
			c.query "use ut;"
			.then (rsets) =>
#				@log "query", rsets, true
				c.query """
DROP TABLE IF EXISTS `object`;

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
) ENGINE=InnoDB AUTO_INCREMENT=225 DEFAULT CHARSET=utf8 COMMENT='the object repository';
"""
			.then (rsets) =>
#				@log "query", rsets, true
				c.query """
drop procedure if exists objectInsert;

CREATE PROCEDURE `objectInsert`(IN `ownerID` INT, IN `parentID` INT, IN `name` VARCHAR(50), IN `data` TEXT)
    MODIFIES SQL DATA
BEGIN
	insert into object (`ownerID`, `parentID`, `name`, `data`) values (ownerID, 333, name, data);
	select LAST_INSERT_ID() as id;
END
"""
			.then (rsets) =>
#				@log "query", rsets, true
				c.query "call objectInsert(0,0,'fred','data4');"
			.then (rsets) =>
#				@log "query", rsets, true
				c.query """
drop procedure if exists objectDataUpdate;

CREATE PROCEDURE `objectDataUpdate`(IN `_id` INT, IN `data2` TEXT)
    MODIFIES SQL DATA
BEGIN
update object set `data`=data2,dateUpdated=current_timestamp() where id=_id;
END
"""
			.then (rsets) =>
#				@log "query", rsets, true
				c.query """
DROP TABLE IF EXISTS `userInfo`;

CREATE TABLE `userInfo` (
`userInfoID` int(11) unsigned NOT NULL AUTO_INCREMENT,
`email` varchar(128) DEFAULT NULL,
`password` varchar(64) DEFAULT NULL,
`nameFirst` varchar(64) DEFAULT NULL,
`nameLast` varchar(64) DEFAULT NULL,
`identityVerificationID` int(11) unsigned DEFAULT NULL,
`userState` tinyint(4) unsigned NOT NULL DEFAULT 1,
`points` mediumint(9) unsigned NOT NULL DEFAULT 50,
`inserted` timestamp NOT NULL DEFAULT current_timestamp(),
PRIMARY KEY (`userInfoID`),
UNIQUE KEY `ux_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;
"""
			.then (rsets) =>
#				@log "query", rsets, true
				c.query """
DROP TABLE IF EXISTS `emailHold`;

CREATE TABLE `emailHold` (
  `emailHoldID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) DEFAULT 1,
  `email` varchar(128) DEFAULT NULL,
  `inserted` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`emailHoldID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
"""
			.then (rsets) =>
#				@log "query", rsets, true
				c.query """
drop procedure if exists emailHold;

CREATE PROCEDURE `emailHold`(IN _email varchar(128))
BEGIN

declare _userInfoID int(11) unsigned;
declare _emailHoldID int(11) unsigned;

set _email = trim(_email);

update emailHold set enabled=0 where inserted < (NOW() - INTERVAL 3 MINUTE);

select userInfoID into _userInfoID from userInfo where email=_email;
if _userInfoID is null then
  select emailHoldID into _emailHoldID from emailHold  where email=_email and enabled=1 LIMIT 1;
  if _emailHoldID is not null then
    select 0 as emailHoldID;
  else
    insert into emailHold (email) values (_email);
    SELECT LAST_INSERT_ID() as emailHoldID;
  end if;
else
  select -_userInfoID as emailHoldID;
end if;

END
"""
#			.then (rsets) =>
#				@log "query", rsets, true
#				c.query """
#"""
#			.then (rsets) =>
#				@log "query", rsets, true
#				c.query """
#"""
			.then (rsets) =>
#				@log "query", rsets, true
				c.d()
#				@log "DONE"
				resolve()
			.catch (ex) =>
				@logFatal "query chain", "ex="+ex
				c.d()
				reject err

	URLGet: ->
		@c.URL

	usernameRandom: -> util.randomPick "username", "remoteportal"

	userRandomRegister: (auth) ->
		auth.register @usernameRandom(), @passwordRandom(), @emailRandom(), @fnameRandom, @lnameRandom()




module.exports = TestHub
