###
___________.__                ___.                                     _____    __________  .___
\_   _____/|  |   ____ ___  __\_ |__ _____    ______ ____             /  _  \   \______   \ |   |
 |    __)  |  | _/ __ \\  \/  /| __ \\__  \  /  ___// __ \           /  /_\  \   |     ___/ |   |
 |     \   |  |_\  ___/ >    < | \_\ \/ __ \_\___ \\  ___/          /    |    \  |    |     |   |
 \___  /   |____/\___  >__/\_ \|___  (____  / ____ >\___ >          \____|__  /  |____|     |___|


Copyright (C) 2016 Flexbase corporation - All Rights Reserved

Web Service:            Flexbase DBaaS (DataBase as a Service)
Language Binding:       JavaScript

Does NOT provide ANY user interface properties, events or methods (see Kernel API for that)
	except (__theme, __renderDetailLevel, __renderImage, __renderTitle)

RESTful connection points
http://api.flexbase.com
http://sandbox.flexbase.com

Callbacks use NodeJS function call back convention with 'err' as first parameter.

HOW DO THAT?
    http://worldofgolfresort.com/amenities/


createProperty
    mirrorLocally: true








## Top-Level Objects ##

JS Class            Flexbase Class                          Description
==================  ======================================  ===========================================
Comment             sys.object.Comment                      single instance of comment on arbitrary object
CommentCollection   sys.object.CommentCollection            arbitrary number of comments about an object
ErrorCollection     sys.ErrorCollection                     exhaustive list of errors
Flexbase            sys.Flexbase                            creates a user
Object              sys.Object                              base class of all Flexbase objects
SearchCriteria      sys.object.SearchCriteria               name/value pairs
SearchResult        sys.object.SearchResult                 particular search result
SearchResultCollection sys.object.SearchResultCollection    ordered search results
User                sys.User                                manages all user's objects






Comment
    Properties:
	message:string                                          contains markup
	messageType                                             { TEXT, IMAGE, etc. }
    user:User



CommentCollection
    Properties:
	commentCollection:[Comment]
    completeness

    Methods:
    commentAdd(Comment, callback)                           comment on someone's object
	getNextTenComments(method)                              { CHRONOLOGICAL,POPULAR }



ErrorCollection                                             REF: www-numi.fnal.gov/offline_software/srt_public_context/WebDocs/Errors/unix_system_errors.html
	Properties:
    EEXIST                                                  entity already exists
    EIO                                                     I/O or network communication error
    ENOENT                                                  no such entity (objectID, etc.)
    EPERM                                                   operation not permitted
    ESUSPENDED                                              user is suspended



(multiple users can be instantiated for unit testing)
Flexbase
    Properties:
    userCollection[User]

    Methods:
    userAuthenticate(username:string, password:string, bSaveCredentials, callback(User))
    userAuthenticateSavedCredentials(callback(User))
    userAuthenticateDeleteCredentials()
    userReserve(username:string, userAgent:string, callback(User))            reserve username for 3 minutes (used by "new user" use case); accountStandingState=RESERVED
        (^^^ restricted from public API)




Object                                                      NOTE: inherited by all objects
    Properties:
    __cacheMode:sys.object.cacheMode                        allowed to cache locally or not?
    __commentCollection:sys.object.CommentCollection
    __conflictResolutionMode:sys.object.conflictResolutionMode {LATEST_WINS, OWNER_WINS}
    __conflictResolutionState:sys.object.conflictResolutionState<READ_ONLY> {CLEAN, CONFLICTED}
    __country:world.Country                                 global country for geolocation
    __dateCreated:date<READ_ONLY>                           creation date
    __dateModified:date<READ_ONLY>                          last modified date
    __deployMode:sys.object.deployMode                      {IMMEDIATE, ONE_HOUR, AT_LOGOFF, AT_MIDNIGHT}
    __dragState:HELP                            FlexPage    HELP
    __element:Element(DOM)                      FlexPage    underlying DOM Element
    __extends:sys.className                                 object inheritance
    __className:sys.className                               my class
    __copyright:sys.object.Copyright                        the granular copyright of this particular object
    __countUserBookmarked:int<READ_ONLY>                    how many users have bookmarked me
    __countUserClicked:int<READ_ONLY>                       how many times users have clicked on me
    __countUserFollowing:int<READ_ONLY>                     how many users are following me
    __countUserViews:int<READ_ONLY>                         how many users have viewed me on a page
    __encryptionMode:sys.object.EncryptionMode              {PLAIN_TEXT(public), SSL, etc. }
    __freshState:<sys.object.FreshState>                    {FS_CREATED_NO_OBJECTID, SAVING, SAVE_ERROR, SAVED_YES_OBJECTID, STALE}
    __id:DOMString                              FlexPage    underlying DOM id
    __isIrrevocable:bool                                    can owner revoke at any time or not?
    __isPublic:bool                                         write to HTTP server for general accessibility
    __linkObjectID:int<READ_ONLY>                           object I'm wrapping (linked to)
    __loadedState:sys.object.LoadedState<READ_ONLY>         {ONLY_OBJECTID, DOWNLOADING_LINKS, ONLY_LINKS, DOWNLOADING_FULL, FULL}
    __mount:str_or_array_of_strs_HELP                       always read as mount[0] or mount.length even if shortcut "~" without brackets
    __objectID:int<READ_ONLY>                               permanent object identifier
    __ownerID:sys.userID                                    owner (person or group) of this object
    __parentID:int                                          ancestor parent of this object
    __postalCode:sys.postalCode                             global postal code for geolocation search
    __purityAge:sys.object.PurityAge                        how old (13 to 21 years old) a user must be to view this object
    __renderDetailLevel:sys.object.renderDetailLevel        {TINY, SMALL, MEDIUM, LARGE, FULL}
    __renderImage:bool                                      render the image of the object, if applies
	__renderTitle:bool                                      render the title of the object, if applies
    __selectState:HELP                          FlexPage    HELP
    __spokenLanguage:sys.spokenLanguage                     e.g., English, French, etc.
    __stick:bool                                            stick to edge of screen instead of scrolling off
    __theme:sys.Theme                                       e.g., "high contrast", "Dr. Who", etc.
    __userTagList:sys.object.TagList                        this user's tags on this object
    __versionMode:sys.object.VersionMode                    {DISABLED, OWNERS_ONLY_ENABLED, EVERYONE_ENABLED}
    __versionNumber<READ_ONLY>                              e.g., 1, 2, 3, ...
    __worldPath                                             e.g., "/world/people/Tom_Hanks"
    __worldTagList:sys.object.TagList<READ_ONLY>            collective user base tags on this object

    Events: **HELP: MOVE to FlexPage.coffee
    ___onClipboardCopy(bInternal)				FlexPage
    ___onClipboardCut(bInternal)				FlexPage
	___onClipboardPaste(HELP:MIMETYPE)			FlexPage
    ___onLockState(bLocked, UOID-HELP)			FlexPage
    ___onStick                                  FlexPage    call ___stickProxyCreate()
    ___onUnStick                                FlexPage    HELP
    ___onUpdated(sys.object.Delta)                          updated, perhaps by another user

    Methods:
    ___animate(snabbtObject)
    ___childrenLoad(callback(object))                       download children objects (if any)
    ___clone(callback(object))                              object with new objectID
    ___commentsGet(callback(CommentCollection))             get user's comments about this object
    ___delete(bPermanent,callback)                          delete object
    ___follow(user, callback(sys.Link))                     AKA link object
    ___getNext(pnCollection, cnt)                           for large collections
    ___like(callback)                                       'like' an object
    ___permissionsGet(callback:ObjectPermissions)           e.g., read/write, etc.
    ___pop(pn) => v                                         pop from queue
    ___push(pn, v)                                          push onto queue
    ___publishToWorldRepository(path)                       petition to add to worldbase.io repository
    ___purityAgeVote(sys.object.PurityAge)                  give input for how old user must be to view this object
    ___redo(callback(object))                               undo the last undo
    ___render(bServer)                                      HELP
    ___report(sys.object.reportState, callback)             {CLEAN, ABUSIVE, COPYRIGHT_INFRINGEMENT, HATEFUL, etc.}
    ___save(callback)                                       store object on server
    ___stickProxyCreate                                     inside ___onStick(), call to create new DOM element to use instead of scrolled off element so that stuck element can be a different size region that then orignal region (to making panel smaller, larger, etc.)
    ___undo(callback(object, sys.object.Delta))             undo single revision
    ___versionGet(versionNumber:int)                        create snapshot object
    ___versionHistoryGet(callback(sys.object.RevisionHistory)) query for version history object
    ___versionRevert(versionNumber:int)                     revert to previous version



NOTE: if it's viewable then it's also: annotatable, tagable, SQL selectable
NOTE: some of these apply to property-level permissions, also
HELP: almost every one of these is moderateable via simple workflow approval/rejection process
HELP: should it be possible to create an object the creator can now longer control? (omit self?)
If object.__ownerID is THEM, then can do _anything_ with the object
    If not, these are exampled to see if user is on the list for desired action
public object MUST have _6_propertyRead=true to see
    AND _6_$pn null or in list
What value do you set for "public?"
ObjectPermissions
    Properties:                     OBJ___      PN___
P       cacheClient                 obj         pn          only users allowed to cache in their browser/on device
P       commentAdd                  obj                     add a comment like on Facebook and later edit your own
        commentEdit                 obj                     edit a comment by another user
        commentDelete               obj                     delete user comments
P       compose                     obj         pn          can build other objects from this object
P       export                      obj         pn          export via JSON, XML, CSV, etc.
P       linkChangeSkin              obj                     can a object that links this object skin anyway they want to?
P       linkToMe                    obj                     link to me ("Share")
        userLogonLogoffEvent        obj                     user object only
        methodAdd                   obj         n/a         ladybug scripting
        methodEdit                  obj         pn          ladybug scripting
        methodDelete                obj         pn          ladybug scripting
        permissionsGrantToUser      obj         ?           further permissions to another user
        permissionsRevokeFromUser   obj         ?
        propertyAdd                 obj         n/a
        propertyDelete              obj         pn
P       propertyRead                obj         pn
        propertyWrite               obj         pn
        publicMeta                  obj         ?           all public (P
P       queryREST:au                obj         pn          if disabled then can only retrieve using server-side agent
P       queryServerAgent:au         obj         pn          can a server-side agent retrieve this object
P       searchable                  obj         pn          show up in search results
        systemPropertyEdit          obj         pn          e.g., __parentID, __postalCode, etc.
P       tag                         obj                     world at large can add tags for classification and searching
^ "publicMeta"




SearchCriteria
    Properties:
    propertyNameString:propertyValueString
    ...



SearchResult:
    Properties:
	points:int
    objectID:int



SearchResultCollection
    resultsCollection:[SearchResult]


User
    Properties:
    accountStandingState:sys.accountStandingState           { RESERVED, ACTIVE, ACTIVE_PAID, SUSPENDED }
    isLoggedOn:bool
    syncState:sys.clientRepositorySyncState                 { OFFLINE, LOGGING_ON, ONLINE, SYNCHRONIZING }
    userNamesBlocked:[string]                               users this user has blocked

    Events:
    onObjectUpdated(object)                                 some object has been updated

    Methods:
    add(password:string, email:string)                      call after userReserve; accountStandingState=RESERVED->ACTIVE
    chat(username) -> ChatConversation  HELP
    deleteAccountNoUndo()
    follow(objectID, callback(sys.Link))                    AKA link object
    get(objectID, detail, bForce, cb) -> Object             detail{TL_OBJECTID, TL_LINKS, TL_FULL}
    logoff()                                                sign-off of system
    search(ownerID, SearchCriteria), callback(SearchResultCollection)) ownerID=0 for global object repository
	synchronizeAll()                                        re-download all objects
    userBlock(bBlock,username)                              utterly hide other user
    userChatMute(bMute,minutes:int)                         mute chat messages  HELP





## Examples ##

flexbase = new Flexbase(true)
flexbase.userAuthenticateSavedCredentials (err, user) ->
    log "Welcome back #{user.username}"



localStorage
autoLogonUserName=remoteportal
server=dev








## Facebook Social Network ##

FBFeed
FBFeedPost


"sys.FBFeed":
	__cn: "sys.Class"
	postCollection:
		__cn: "sys.Property"
		isArray: true
		arrayPN: "name"
		arrayCN: "sys.FBFeedPost"
        pnSort: "sys.FBFeedPost.dateCreated"    #H
        $perm$arrayPush: *      # anyone can post comment
"sys.FBFeedPost":
	__cn: "sys.Class"
	dateCreated:
		__cn: "sys.Property"
	item:
		__cn: "sys.Property"
		typeName: "sys.Object"          # anything
        _z_comment: "can be anything: string, recipe, etc."
	author:
		__cn: "sys.Property"
		typeName: "sys.User"











## TODO ##
HELP: can't easily distinguish between Flexbase classes and types
deprecated properties: warn on ___save() that property is deprecated



http://localhost:63342/Both/objects/370.json


J:\Cloud\Dropbox\Flexbase\Both>node server\serverwriter.js

http://localhost:63342/Both/static.htm

http://localhost:63342/Both/index.htm?u=remoteportal&server=dev
http://localhost:63342/Both/index.htm?u=dave&server=dev

http://localhost:63342/Both/index.htm?u=dave&server=live            FireFox


http://www.pulsebase.com?u=remoteportal
http://www.pulsebase.com?u=dave


http://html.flexbase.com:3344/object/1/81


http://www.pulsebase.com:3344/object/1/81

http://localhost:3344/objects/dump
http://localhost:3344/objects/81
http://localhost:3344/object/9/81
http://localhost:3344/object/370/81         who's online
###


### define function variable before block to avoid code being appended to closing part of JSDoc comment ###
#cube = null

###*
 * Function to calculate cube of input
 * @param {number} Number to operate on
 * @return {number} Cube of input
 ###






#CONFIG
if _ = window.getURLParameter "server"
	localStorage.server = _
SERVER = if localStorage.server is "dev" then "http://localhost:3344" else "http://www.pulsebase.com:3344"



R=window.R;DEV=1

netmodule = require "net"
lm = require './logModule'
log = (args...) -> a = Array.from args; a.unshift "flexbase:"; lm.log.apply this, a
logerr = (args...) -> a = Array.from args; a.unshift "flexbase:"; lm.logerr.apply this, a

#SLAVE
FRAME_PUSH = (err, o, omerge) ->
	err = new lm.FlexException()   unless err
	o.file = "Flexbase" #DIFF
	o[k]=v	for k,v of omerge	if omerge
	err.pushFrame o
	err





ERR =   #MIRRORED: config.coffee
	ACCES: 13       # "permission denied"
	EXIST: 17       # "entity already exists"
	IO: 5           # "I/O or network communication error"
	NOENT: 2        # "no such entity (objectID, etc.)"
	PERM: 1         # "operation not permitted"
	SUSPENDED: 1000 # "user is suspended"



# FRESHSTATE
FS =
	CREATED_NO_OBJECTID: 0
	SAVING: 1
	SAVE_ERROR: 2
	SAVED_YES_OBJECTID: 3
	STALE: 4

#LOADEDSTATE
LS =
	ONLY_OBJECTID: 0
	DOWNLOADING_LINKS: 1
	ONLY_LINKS: 2
	DOWNLOADING_FULL: 3
	FULL: 4



# http://soft.vub.ac.be/~tvcutsem/proxies
###
properties:
inherited:
inheritedCovered:
permissions:
objectMeta
propertiesMeta
collisions
system
objectID
versionNumber
###


callSNNext = 0
callMap = new Map()

objectUpdateCB = null
objectUpdate2CB = null


user =
	p:
		accept_language: ["fr", "en"]
		write_language: "fr"

types =
	"sys.languageString":
		get: (target, pn) ->
			for lc in target.kernel.user.p.accept_language
				if v = target.p[pn+'$'+lc]
					return v
			target.p[pn]
		set: (target, pn, v) ->
			if _=target.kernel.user.p.write_language
				target.p[pn+'$'+_] = v
			else
				target.p[pn] = v
	"sys.email":
		desc: "Internet electronic mail address"
		jsType: "string"
		re: /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/


clsTarget =
	collisions:
		none: true
	p:
		greeting:
			__cn: "sys.Property"
			typeName: "sys.languageString"
		email:
			__cn: "sys.Property"
			typeName: "sys.email"
	pmeta:
		pi:
			bReadOnly: true
	flex:
		__objectID: 123
	kernel:
		user: user
		alang: ["fr"]

target =
	collisions:
		none: true
	p:
		pi: 3.14159
		greeting$en: "Hello"
		greeting$fr: "Bonjour"
	pmeta:
		pi:
			bReadOnly: true
	flex:
		__objectID: 123
	kernel:
		user: user

handler =
	get: (target, pn, receiver) ->
		if (dollar = pn.indexOf '$') >= 0
			if pn is '$'
				return target.flex.__objectID
			else if dollar is 0
				pn = pn[1..]
				target.flex[pn]
		else
			if target.kernel.cls
				if po = target.kernel.cls[pn]   #RENAME: classMap?
					tn = po.typeName
					ty = types[tn]
					if "get" of ty
						return ty.get target, pn
			target.p[pn]
	set: (target, pn, v, receiver) ->
		if target.kernel.cls
			if po = target.kernel.cls[pn]
				tn = po.typeName
				ty = types[tn]
				if "set" of ty
					return ty.set target, pn, v
				else if "re" of ty
					if ty.re.test v
						target.p[pn] = v
					else
						throw "type validation: pn=#{pn}: attempted=#{v}: re=#{ty.re}"
		target.p[pn] = v


if 1
	face = new Proxy target, handler
	target.kernel.cls = cls = new Proxy clsTarget, handler
	lc = (pn) -> log pn, cls[pn]
	ll = (pn, expect) ->
		v = face[pn]

		# log "ll", pn, v

		if v isnt expect
			logerr "#{pn}: got=#{v} expected=#{expect}"
	ll "pi", 3.14159
	ll "$", 123
	ll "$__objectID", 123
	face.alvin = 777
	ll "alvin", 777
	ll "greeting", "Bonjour"
	# lc "greeting"
	face.greeting = "Salut"
	ll "greeting", "Salut"
	face.email = "p@p.com"
	try
		face.email = 3
	catch ex
# log "correct:", ex
	ll "email", "p@p.com"
# console.dir target

# new Proxy(target, handler)
#dest[k] = new Proxy d2, {
#	#get: (target, name) ->
#	#	true
#	#set: (obj, pn, v) ->
#	#	obj[pn] = v
#}
#n = dest[k].peter
#dest[k].alvin = "charles"



# log "Flexbase.coffee says hello"
x = eval "2 + 2"





#TODO: refactor other areas to this style
FlexbaseObject = Object.defineProperties {},
# TWO UNDERSCORES: SYSTEM PUBLIC PROPERTIES
	"__freshState":
		value: FS.CREATED_NO_OBJECTID
		writable: true
	"__id":
		get: -> "#{if @__cn is "sys.User" then "#{@userName} " else ""}#{if @__objectID then @__objectID else "PRE-ID"}"
	"__id2":
		get: -> "#{if @__fromID then "#{@__fromID} -> " else ""}#{@__id}"
	"__id3":
		get: ->
			if @__freshState is FS.CREATED_NO_OBJECTID
				"[FS_CREATED_NO_OBJECTID]"
			else
				if @__freshState is FS.SAVED_YES_OBJECTID
					freshStatePart = ""
				else
					freshStatePart = " FS=#{@__freshState}"

				"[#{@__id2}#{freshStatePart}]"
	"__loadedState":
		value: LS.ONLY_OBJECTID
		writable: true

# THREE UNDERSCORES: SYSTEM PUBLIC METHODS
	"___assert":
		value: (b, message) ->
			@___logerr "ASSERT: #{message}" unless b
	"___childrenLoad":
		value: (cb) ->
			log "___childrenLoad"
			cb {message:"NOT-IMPL"}
	"___log":
		value: (args...) ->
			s = ""
			for arg in args
				s += "#{if typeof arg is "object" then JSON.stringify(arg) else arg} "
			log @___logMsgCreate s
	"___logerr":
		value: (args...) ->
			s = ""
			for arg in args
				if typeof arg is "object"
					if "stack" of arg
						arg.logerr()
					else
						console.dir arg
						s += JSON.stringify(arg) + " "
				else
					s += arg + " "
			logerr @___logMsgCreate s
	"___logMsgCreate":
		value: (s) -> "#{@__id3} #{if @____lastMethod then @____lastMethod else ""}: #{s}"
	"___on":
		value: (eventName, cb) ->
# @___log "on: #{eventName}"
			@_x_cb = cb
	"___save":
# call Flexbase.Object.onSave
		value: (cb) ->
			@____lastMethod = "___save"
			@__freshState = FS.SAVING
			# @___log "__save", this
			net = new netmodule.Net()
			o = Object.create null
			for k,v of this
				unless k in ["__freshState", "____lastMethod", "__who"]
					o[k] = v
			#TEMP#TEST#T#H
			net.post "#{SERVER}/object/#{@____owner.__objectID}", o, (err, JSONResponse) =>  #HC: userInfoID
				if err
					@__freshState = FS.SAVE_ERROR
					cb? FRAME_PUSH(err, method:"___save")
				else
# log "JSONResponse=#{JSONResponse}"

					res = JSON.parse JSONResponse

					if res[0]
						@__freshState = FS.SAVE_ERROR
						cb? FRAME_PUSH(err, res[0], method:"___save"), null
					else
						o = res[1]
						#TODO: save should download entire new object for "kill two birds" if updated by another user, meanwhile
						@_____objectIDSet o.__objectID
						# @___log "saved"
						cb? null
	"__who":
		enumerable: true
		value: "FlexbaseObject"

# FOUR UNDERSCORES: SYSTEM PRIVATE PROPERTIES

# FIVE UNDERSCORES: SYSTEM PRIVATE METHODS
	"_____objectIDSet":
		value: (__objectID) ->
# log "_____objectIDSet: #{__objectID}"

#			if "__objectID" of this
#				log "ALREADY SET"

			Object.defineProperty this, "__objectID",
				enumerable: true
				value: __objectID

			@__freshState = FS.SAVED_YES_OBJECTID




###*
 * Function to calculate cube of input
 * @param {number} Number to operate on
 * @return {number} Cube of input
 ###
Flexbase = (bProduction=true, cbOnload) ->
#SO: 2384227
#URL: www.w3.org/TR/offline-webapps
# log "SERVER=#{SERVER} onLine=#{navigator.onLine}"

	fbase = {}          #H: what is this?

	#window.onerror = (message, source, lineno, colno, eo) -> console.log "I DON'T SEE THIS for the cases below"

	fileref = document.createElement "script"
	fileref.setAttribute "type", "text/javascript"
	fileref.setAttribute "src", "#{SERVER}/socket.io/socket.io.js"
	try
		document.getElementsByTagName("head")[0].appendChild fileref
	catch ex
#H#CHROME: can't catch: [server not running] Flexbase.js:338 GET http://localhost:3344/socket.io/socket.io.js net::ERR_CONNECTION_REFUSED
#H#CHROME: can't catch: [if bad domain name] Flexbase.js:193 GET http://www.pulse______base.com:3344/socket.io/socket.io.js net::ERR_CONNECTION_TIMED_OUT
		console.log "CAUGHT"
		cbOnload? FRAME_PUSH(method:"Flexbase",msg:"unable to download socket.io"), null

	head = document.getElementsByTagName("head")[0]
	head.addEventListener "load", ((event) =>
		if event.target.nodeName is "SCRIPT"
			src = event.target.getAttribute "src"
			# log "Script loaded: " + event.target.getAttribute("src")
			if src.indexOf("socket.io") > 0
				cbOnload? null, fbase
#if 1
#	flexbase.userReserve "catherine", "some user agent", (user) ->
#		log "user.accountStandingState=#{user.accountStandingState}"
	), true

	# document.addEventListener "DOMContentLoaded", -> true

	fbase.userAuthenticate = (userName, password, bSaveCredentials, cb) ->
		user = new User fbase
		user.authenticate userName, password, bSaveCredentials, (err, user) -> cb err, user

	fbase.userReserve = (userName, userAgent, cb) ->
		log "userReserve: #{userName}, #{userAgent}"
		@socket.emit "user.reserve",
			userName: userName
			userAgent: userAgent
		user = new User()
		user.accountStandingState = 666
		cb user

	Object.defineProperty fbase, "userAuthenticateDeleteCredentials",
		value: -> localStorage.removeItem "autoLogonUserName"

	Object.defineProperty fbase, "userAuthenticateSavedCredentials",
		value: (cb) ->
			if localStorage.autoLogonUserName
# log "userAuthenticateSavedCredentials"
				@userAuthenticate localStorage.autoLogonUserName, "PW-HELP", true, cb

	fbase





User = (flexbase) ->    # => true if async
	_z_userName = _z_password = _z_bSaveCredentials = _z_cb = null

	classMap = {}
	objectMap = {}      #H: use ES6 Map
	user_objectID = null    #CHALLENGE: need to set to null

	user = Object.create FlexbaseObject
	user.authenticationCnt = 0



	authenticate = (userName, password, bSaveCredentials, cb) ->
		user.____lastMethod = "authenticate"
		net = new netmodule.Net()
		net.post "#{SERVER}/authenticate", {userName:userName,password:password}, (err, JSONResponse) =>
			if err
#OLD
#user.___logerr "", err
##LEARNED#IE: err was XHR object with was probably sealed in IE so couldn't add a new property
##logerr "tyoeof err=#{typeof err}"
##logerr "authenticate: userName=#{userName}"
#err.traceBack ?= []
##console.log "typeof=#{typeof err.traceBack}"
##unless err.traceBack
##	log "setting: err.traceBack = []"
##	err.traceBack = []
##BIZARRE: even though set to [] it's still undefined!
##console.log "typeof=#{typeof err.traceBack}"
##TODO
#err.traceBack.push "net.post: #{SERVER}/authenticate: userName=#{userName}"
#flexbase.userAuthenticateDeleteCredentials()
#cb err, null

#NEW
				flexbase.userAuthenticateDeleteCredentials()
				cb FRAME_PUSH(err,method:"authenticate"), null
			else
				res = JSON.parse JSONResponse

				if res[0]
					user.___logerr "", res[0]
					cb res[0], null
				else
# user.___log "authenticationCnt=#{user.authenticationCnt}"

					if user.authenticationCnt++ is 0
# user.___log "setting properties"

						for k,v of res[1]
# user.___log "#{k}=#{v}"
							Object.defineProperty user, k, enumerable:true,value:v
						user._____objectIDSet (user_objectID=parseInt res[1].__objectID, 10)
						Object.defineProperty user, "userName", enumerable:true,value:userName

					if bSaveCredentials
# user.___log "setting autoLogonUserName=#{userName}"
						localStorage.autoLogonUserName = userName

					user.socket.emit "login", userName
					user.socket.on 'loginACK', (pair) ->
# user.___log "loginACK", pair

						if pair[0]
							cb pair[0], null
						else
							user.socket.on 'disconnect', ->
								log "@@@@@@@@ disconnected"
								if 0
									authenticate _z_userName, _z_password, _z_bSaveCredentials, _z_cb

							# user.___log "userName=#{userName} ##{user.authenticationCnt}: SUCCESS"
							cb null, user

	# user.get: NOTE: can't be in defineProperties, below, because it accesses private objectMap
	getInternal = (user, objectID, detail, bForce, bRecursive, cb, bIsPublic) ->
# console.log typeof bRecursive
# console.log typeof cb
		throw 0 unless arguments.length is 6

		if bRecursive
			throw 0
			#statsObj = {}
			#getRecursive user, objectID, statsObj, cb
			return

		#TODO: upgrade detail if necessary!
		unless bForce
			if o = objectMap[objectID]
# user.___log "objectMap hit"
				cb null, o, false
				return false
			else if json = localStorage[objectID]
				try
					o = JSON.parse json
# user.___log "localStorage[#{objectID}]: hit (#{json.length} jbytes)"
				catch ex
					user.___logerr "get: objectID=#{objectID}: unable to parse: #{json}"
					return false
				cb null, bless(o), false
				return false

		net = new netmodule.Net()
		if bIsPublic
#NOTE: it's hard to tell direct file access from REST API

			net.get "#{SERVER}/objects/#{objectID}", (err, JSONResponse) =>
				if err
					cb FRAME_PUSH(err, method:"get"), null
				else
# log "JSONResponse=#{JSONResponse}"

					res = JSON.parse JSONResponse

					if res[0]
						cb res[0], null
					else
						@ls_seto "objectsFollowed", res[1]
						cb null, res[1]


		# log "ASYNC: #{objectID}"
		#CORS: https://blog.jetbrains.com/webstorm/2013/06/cors-control-in-jetbrains-chrome-extension/
		net.get "#{SERVER}/object/#{objectID}/#{user_objectID}", (err, JSONResponse) ->
			if err
				user.___logerr "get callback error", err
				cb FRAME_PUSH(err), null, true
			else
# console.dir JSONResponse

				res = JSON.parse JSONResponse

				if res[0]
					user.___logerr "WTF:HERE", res
					res[0].WTF = "HERE"
					cb res[0], null, true
				else
					cb null, bless(res[1]), true
		true


	getRecursive = (user, objectID, statsObj, cb) ->
		log "BEG: getRecursive"

		downloading = 0
		cnt = 0
		rv = null

		fn = (objectID) ->
			cnt++
			# log "fn #{objectID}"
			async = getInternal user, objectID, -1, false, false, (err, o, async) ->
				if async
					downloading--

				if err
					user.___logerr "getRecursive: getInternal: downloading=#{downloading}"
					downloading = -1000 #HACK: call once
					cb err, null
				else
# user.___log "getRecursive: getInternal: downloading=#{downloading}"

					unless rv
						rv = 0

					for k,v of o
						if typeof v is "object"
							if "____link" of v
# log "1"
								fn v.____link
					# log "2"

					if downloading is 0
# log "END: getRecursive: #{cnt}"
						if cnt is 1
							linkUp()
							cb null, rv

			if async
				downloading++
				throw 0
			cnt--
		fn objectID


	bless = (oIN) ->
#RECENT #TODO: trashing... we may have JUST parsed this from string, and now converting back to string
		localStorage[oIN.__objectID] = JSON.stringify oIN

		if o = objectMap[oIN.__objectID]
#for FIRING LADYBUG EVENTS!!!  <<got it!>>

#TODO: finish?
			odesc =
				added: []
				modified: []
				unmodified: []
				removed: []

			#TODO: clone???
			#TODO: arrays
			#TODO: ignore __* properties
			for k,v of oIN
				if k of o
#TODO: what is property orders different?  false negatives!
					if JSON.stringify(oIN[k]) is JSON.stringify(o[k])
						odesc.unmodified.push k, o[k]
					else
						log "MOD: #{k}: old=#{o[k]} new=#{oIN[k]}"
						odesc.modified.push k, [o[k], oIN[k]]
				else
					odesc.added.push k, oIN[k]
				o[k] = v

			for k,v of o
				if !(k of oIN)
					odesc.removed.push k, o[k]
					delete o[k]

#for k,v of oIN
#	o[k] = v
		else
			o = Object.create FlexbaseObject

			for k,v of oIN
				o[k] = v

			o._____objectIDSet o.__objectID

			Object.defineProperties o,
				"____owner":
					value: user

			objectMap[o.__objectID] = o

		#proxy = new Proxy o, handler
		proxy = o

		# console.dir JSONResponse
		objectUpdate2CB? odesc, proxy

		if proxy._x_cb
			proxy._x_cb odesc, proxy

		proxy


	classGetByName = (className, cb) ->
		if _ = classMap[className]
			cb null, _
		else
			getInternal user, className, -1, false, false, (err, o) ->    #HC
				if err
					logerr "classGetByName", err
					cb err, null
				else
					log "classGetByName: __objectID=#{o.__objectID}"
					classMap[className] = o
					cb null, o


	objectValidate = (o, className, cb) ->
		classGetByName className, (err, cls) ->
			if err
				cb message:"can't find className \"#{className}\"", null
# console.dir classMap
			else
# user.___log "objectValidate", cls


				a = null
				# check if changing permissions
				perm = o
				# permission added: #H: how determine unless have shadow?
				# may have to do on-the-fly on property set
				# what is the prefix of these?
				# permission removed
				# permission changed
				#for pn,pno of cls

				#				cacheClient                 obj         pn            only users allowed to cache in their browser/on device
				#				commentAdd                  obj                       add a comment like on Facebook
				#				commentEdit                 obj                       edit a comment by another user
				#				commentDelete               obj                       delete user comments
				#				compose                     obj         pn            can build other objects from this object
				#				export                      obj         pn            export via JSON, XML, CSV, etc.
				#				linkChangeSkin              obj                       can a object that links this object skin anyway they want to?
				#				linkToMe                    obj                       link to me ("Share")
				#				userLogonLogoffEvent        obj                       user object only
				#				methodAdd                   obj         n/a           ladybug scripting
				#				methodEdit                  obj         pn            ladybug scripting
				#				methodDelete                obj         pn            ladybug scripting
				#				permissionsGrantToUser      obj         ?             further permissions to another user
				#				permissionsRevokeFromUser   obj         ?
				#						propertyAdd                 obj         n/a
				#				propertyDelete              obj         pn
				#				propertyRead                obj         pn
				#				propertyWrite               obj         pn
				#				queryREST:au                obj         pn            if disabled then can only retrieve using server-side agent
				#				queryServerAgent:au         obj         pn            can a server-side agent retrieve this object
				#				searchable                  obj         pn            show up in search results
				#				systemPropertyEdit          obj         pn            e.g., __parentID, __postalCode, etc.
				#				tag                         obj                       world at large can add tags for classification and searching




				# check main properties
				for pn,pno of cls
					v = o[pn]

					er = (vt, message) ->
						a = [] unless a
						a.push [className, pn, v, vt, message]
					#if pn is "__concreteType" or !(pn.startsWith "__")
					if typeof pno is "object"
# user.___log "validate pn=#{pn}"

						if "required" of pno and !(pn of o)
							er "required", "missing"

						if "typeName" of pno
							if pno.typeName is "sys.string"
#TODO #REVISIT: need one more level indirection to types collection

								if typeof v isnt "string"
									er "typeName", "got=#{typeof v} expected=#{pno.typeName}"
							else
								user.___logerr "typeName=#{pno.typeName}"

				if a
					cb a
				else
					cb null


	linkUp = ->
		log "linkUp"
		for objectID,o of objectMap
# log "linkUp: #{objectID}"
# log JSON.stringify(o)
			for k,v of o
				if typeof v is "object" and "____link" of v
					if _=objectMap[v.____link]
# log "LINK: #{v.____link}: yes"
						o[k] = _
						o2 = o
					else
						user.___logerr "LINK: #{v.____link}: NO"
		return


	# http://www.2ality.com/2012/08/property-definition-assignment.html
	# 1. If you want to create a new property, use definition.
	# 2. If you want to change the value of a property, use assignment.
	Object.defineProperties user,
		"authenticate":
			value: (userName, password, bSaveCredentials, cb) ->
				_z_userName = userName
				_z_password = password
				_z_bSaveCredentials = bSaveCredentials
				_z_cb = cb
				authenticate _z_userName, _z_password, _z_bSaveCredentials, _z_cb
		"createObject":
			value: (parentID, className, oPre, cb) ->
				user.____lastMethod = "createObject"
				# user.___log "parentID=#{parentID} className=#{className}"

				objectValidate oPre, className, (err) ->
					if err
						cb FRAME_PUSH(err, method:"createObject"), null
					else
						o = Object.defineProperties Object.create(FlexbaseObject),
							"__cn":
								enumerable: true
								value: className
							"____owner":
								value: user
							"__parentID":
								enumerable: true
								value: parentID

						if oPre
							for k,v of oPre
								o[k] = oPre[k]

						o.___save (err) ->
							if err
# return obj so perhaps can fine-tune and call ___save again to re-try?
								cb FRAME_PUSH(err, {method:"createObject", parentID:parentID, className:className, oPre:oPre}), o
							else
								cb null, o
		"flexbase":
			value: flexbase
# follow is actually a little different from linking: multiple links but one follow
#TODO: bAutoDownloadObject (in addition to just objectID)
		"follow":
			value: (objectID, bFollow) ->
		"get":
			value: (objectID, detail, bForce, cb) ->
				throw 0 unless arguments.length is 4
				user.____lastMethod = "get"
				getInternal user, objectID, detail, bForce, false, cb
		"logoff":
			value: (cb) ->
				user.____lastMethod = "logoff"
				@socket.close()
				# @___log "iterate all objects and set @__freshState to ~disconnected"
				net = new netmodule.Net()
				net.post "#{SERVER}/logoff", null, (err) =>
					if err
						cb FRAME_PUSH(err, method:"logoff")
					else
						@___log "logged off"
						cb null
		"ls_get": value:(k) -> localStorage[@__objectID+k]
		"ls_geto": value:(k) ->
			if v = @ls_get k
				JSON.parse v
			else
				null
		"ls_set": value:(k, s) -> localStorage[@__objectID+k] = s
		"ls_seto": value:(k, o) -> @ls_set k, JSON.stringify o
		"objectsFollowedDownload":
			value: (cb) ->
				user.____lastMethod = "objectsFollowedDownload"
				if @queue = @ls_geto "objectsFollowed"
					if (id = @queue.pop()) > 0
						getInternal user, id, null, true, (err, o) ->
							if err
								cb FRAME_PUSH(err, method:"objectsFollowedDownload")
							else
# log "getInternal: __objectID=#{o.__objectID}"
								cb null
		"objectsFollowed":
			value: (cb) ->
				user.____lastMethod = "objectsFollowed"
				net = new netmodule.Net()
				net.get "#{SERVER}/objects/#{@__objectID}", (err, JSONResponse) =>
					if err
						cb FRAME_PUSH(err, method:"objectsFollowed")
					else
# log "JSONResponse=#{JSONResponse}"

						res = JSON.parse JSONResponse

						if res[0]
							cb FRAME_PUSH(err, res[0], method:"objectsFollowed"), null
						else
							@ls_seto "objectsFollowed", res[1]
							cb null, res[1]
		"onUserCall":
			value: (_) ->
# user.___log "setting onUserCall"
				@userCallCB = _
		"on":
			value: (eventName, cb) ->
				switch eventName
					when "objectUpdate"
						objectUpdateCB = cb
					when "objectUpdate2"
						objectUpdate2CB = cb
					else
						cb message:"unknown eventName \"#{eventName}\"", null
		"onUserFire":
			value: (_) ->
# user.___log "setting onUserFire"
				@userFireCB = _
		"serverCall":
			value: (packet, cb) ->
				user.____lastMethod = "serverCall"
				packet.__callSN = callSNNext++
				callMap.set packet.__callSN,
					date: Date.now()
					cb: cb
				@socket.emit "serverCall", packet
		"socket":
			value: window.io SERVER
		"sync":
			value: (cb) ->
				user.____lastMethod = "sync"

				statsObj =
					ls: 0
					memory: 0
					APIsucc: 0
					APIfail: 0

				getRecursive user, 3, statsObj, (err, o) ->       #HC
					if err
						cb FRAME_PUSH(err, res[0], statsObj:statsObj), null
					else
# user.___log "sync: getRecursive:", o
# user.___log "3: #{JSON.stringify objectMap[3]}"
# log "fill classes"
						for k,v of objectMap[3]
							if typeof v is "object" and !classMap[k]
# log "class #{k}"
								classMap[k] = v
						cb null, statsObj
		"userCall":
			value: (userTo_objectID, packet, cb) ->
				user.____lastMethod = "userCall"
				packet.__callSN = callSNNext++
				packet.__to = "to"
				callMap.set packet.__callSN,
					date: Date.now()
					cb: cb
				@userFire userTo_objectID, packet
		"userFire":
			value: (userTo_objectID, packet) ->
				user.____lastMethod = "userFire"
				packet.__userTo_objectID = userTo_objectID
				@socket.emit "userFire", packet
	# user.___log "userFire", packet
	user.socket.on "serverCallACK", (pair) ->
		if _ = callMap.get pair[1].__callSN
			callMap.delete pair[1].__callSN

			if pair[0]
#TODO: FRAME_PUSH?
				_.cb pair[0], pair[1]
			else
				_.cb null, pair[1]
		else
			user.___logerr "__callSN=#{pair[1].__callSN}"
	user.socket.on "userFireACK", (pair) ->
		if pair[0]
			user.___logerr "userFireACK:", pair[0]
		else
			packet = pair[1]

			if packet.__callSN?
				switch packet.__to
					when "to"
						if user.userCallCB
							user.userCallCB packet

							# configure return trip for "return packet":
							packet.__to = "from"
							[packet.__userTo_objectID, packet.__userFrom_objectID] = [packet.__userFrom_objectID, packet.__userTo_objectID]
							user.socket.emit "userFire", packet
						else
							user.___logerr "userCall request received: @userCallCB not set"
					when "from"
						if _ = callMap.get packet.__callSN
							callMap.delete packet.__callSN
							if packet.__err
								err = packet.__err
								delete packet.__err
								_.cb FRAME_PUSH(err, event:"userFireACK",statsObj:statsObj), packet
							else
								_.cb null, packet
						else
							user.___logerr "__callSN=#{packet.__callSN}"
					else
						user.___logerr "__to=#{packet.__to}"
			else if packet.cmd is "objectUpdate"
# user.___log "objectUpdate", packet

				notify = (err, o) ->
					if err
						throw err
					else
# console.dir JSONResponse
						objectUpdate2CB? err, o
						if o._x_cb
							o._x_cb err, o

				for odesc in packet.list
					objectUpdateCB? err, odesc

					net = new netmodule.Net()
					if odesc.isPublic
#TODO: somehow move this into user.get itself (but it already knows it's public)
						net.get "/Both/objects/#{odesc.objectID}.json", (err, JSONResponse) ->
							if err
								user.___logerr "get callback error", err
							else
# console.dir JSONResponse
								notify err, bless(JSON.parse(JSONResponse))
					else
						user.get odesc.objectID, true, true, (err, o) ->
							notify err, o
			else
# user.___log "***** userFireACK", packet

				if user.userFireCB
					user.userFireCB packet
				else
					user.___logerr "userFireACK: @userFireCB not set"

	user





R.flexbase =
	FS: FS
	User: User
	Flexbase: Flexbase












