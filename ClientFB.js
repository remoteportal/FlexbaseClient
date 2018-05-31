// Generated by CoffeeScript 2.3.0
//if node
var Base, Classes, ClientFB, ClientFBUT, ClientSync, N, O, Store, UT, WebSocket, _resolve, cn, trace, util;

WebSocket = require('ws');

//A = require './A'
Base = require('./Base');

Classes = require('./Classes');

ClientSync = require('./ClientSync');

O = require('./O');

N = require('./N');

Store = require('./Store');

trace = require('./trace');

UT = require('./UT');

util = require('./Util');

//endif

// needs to be transactional: if you object 10 objects then do o.__save() they hae to be done as a transaction!

// Limitations
// - object notify list is very very difficult to manage and expensive to run
// - Flexbase objects can only be properties of other objects or in an array of a property.  Any deeper than that are FB breaks.  Not true... FB objects can store objects as long as THOSE objects are "simple"... don't have pointers to other objects
// - Perhaps unneccessary server to client sycn'ing when the client really doens't want it.
// - With proxy objects: number of objects is at least doubled (more for property arrays)

// NOTES
// - because not writing out configMap keys, currently doesn't support orphan __id's

// MVP 1
// - just Deanna able to send smiles back and forth

// Links
// https://node.green

// TODO
// - slow down timer: wait until response
// - pull objects from server
// - encrypt on disk
// - don't write object unless dirty
// - __state not consistent
// - save object timeout
// - find Fox recording
// - push to client and add record to end of array
// - classes: add methods
// - download only changed properties????
// - if file type is file then generate GUID
// - combine client and server code for code sharing
// - only list of __ properties to write to disk / upload
// - make sure don't begin NEW file write when one is already in progress!
// - remote: disconnected: semantics???????????  what do???
// - remote: shared code between client/server ("LadyBug like")
// - behavior: real class-based objects
// - https://jwt.io?
// - queue up saves if save already in progress
// - verify not uploading any negative __id's
// - if CLOUD is set to false then phone freezes on "Downloading JavaScript bundle 100.00%"
// - testing database use same moniker as object prefix
// - during object create SAVE current property state and queue
// - tsCBegQ, tsCBeg, tsSBeg, tsSEnd, tsCEnd
// - Why are we uploading wrapped objects in create?
// - __save must create snapshot at point of save
// - send metrics in the "connected" event
// - __save shouldn't strip
// - change type to proxyFriend
// - one master trace file per component
// - saveList, upList
// - what if app exits and saveList isn't empty??????
// - Flexbase multi-instance for unit testing
// - try WebSocket again from Flexbase.coffee

//if ut
//flexbaseAuth = require './flexbaseAuth'		#H
//TestClient = require './TestClient'

//TRIED to move to FlexbaseCoffee.coffee
//33:02 DEV 18-04-20.2 (0.0.95) [0] connect ::ffff:73.53.168.153

//curl ifconfig.me
//73.53.168.153

//http://www.skillsplanet.com:3366
_resolve = null;

ClientFBUT = class ClientFBUT extends UT {
  run(testHub1) {
    this.testHub = testHub1;
    return this.s("HELP", function() {});
  }

};

//endif
ClientFB = class ClientFB extends ClientSync {
  constructor(URL, directory) {
    var FBShared, pn, pv;
    super();
    this.URL = URL;
    this.directory = directory;
    if (trace.CONSTRUCTORS) {
      this.log(`ClientFB: directory=${this.directory}`);
    }
    this.store = Store.factory(this.directory);
    this.config = {
      saveList: [],
      upList: [],
      proxyMap: {},
      targetMap: {},
      newID: -1,
      authenticateID: -1,
      procID: 0,
      rootID: 0,
      transaction: null,
      bOpen: false,
      outQ: [],
      readCnt: 0,
      transactionList: []
    };
    FBShared = require('./FBShared');
    for (pn in FBShared) {
      pv = FBShared[pn];
      //			@log pn
      this[pn] = pv;
    }
    this.config.dateCreated = this.dateFlexCur();
  }

  configWrite() {
    var _, pn, pv, ref;
    //		RETURNS PROMISE
    //		@log "configWrite", @config
    _ = {};
    ref = this.config;
    for (pn in ref) {
      pv = ref[pn];
      //			@log "**** #{pn}"
      //#			unless pn in ["proxyMap","targetMap","newID","procID","rootID","transaction","bOpen","transactionList","outQ"]
      if (pn === "authenticateID" || pn === "username" || pn === "password" || pn === "readCnt" || pn === "rootID") {
        _[pn] = pv;
      }
    }
    //#			else if pn is "proxyMap"
    //#				proxyMap = Object.create null
    //#				for __id of pv
    //#					proxyMap["HELP"] = 0
    //		@log "configWrite2", _
    //		Expo.FileSystem.writeAsStringAsync @path("config"), JSON.stringify _
    return this.store.write("config", _);
  }

  create(v) {
    return new Promise((resolve, reject) => {
      var clo, cn, fo, latest, pn, pv, ref, ref1, ref2, region, targetName;
      if (typeof v === "string") {
        cn = v;
        fo = this.objectNew(cn);
        //				@log "create", fo

        //				@log "I am: #{@__CLASS_NAME}"
        if (this.__CLASS_NAME === "ClientFB") {
          targetName = "NODE_CLIENT";
        } else {
          throw new Error(this.__CLASS_NAME);
        }
        if (clo = Classes[cn]) {
          if ((latest = util.latestGet(clo)) != null) {
            //						@log "latest", latest, true
            if (targetName === "NODE_CLIENT") {
              if (region = latest["NODE_CLIENT"]) {
                //								@log "has NODE_CLIENT"
                if (region.p) {
                  ref = region.p;
                  //									@log "props", region.p
                  for (pn in ref) {
                    pv = ref[pn];
                    //										@log "p: #{pn}"
                    fo[pn] = "HELP";
                  }
                }
                if (region.m) {
                  ref1 = region.m;
                  //									@log "methods", region.p
                  for (pn in ref1) {
                    pv = ref1[pn];
                    fo[pn] = pv;
                  }
                }
              }
              if (region = latest["NODE_SERVER_RPC"]) {
                //								@log "NODE_SERVER_RPC"
                if (region.m) {
                  ref2 = region.m;
                  // create RPC proxy
                  for (pn in ref2) {
                    pv = ref2[pn];
                    (function(pn) {
                      return fo[pn] = (function() {
                        return this.__log(`${pn} PROXY`);
                      }).bind(fo);
                    })(pn);
                  }
                }
              }
              //							@log "DONE DECORATING", fo
              this.addMethodsAndCreateProxy(fo, true);
            } else {
              //				config.targetMap[ o.__id ] = o

              //				@configWrite()
              //				.then =>
              //					wrapped = @addMethodsAndCreateProxy o, true
              //					config.upList.push o
              //					resolve wrapped
              //				.catch (ex) =>
              //					reject ex
              //			.catch (ex) =>
              //			@logCatch "create #{JSON.stringify o}: Can't write 'object#{o.__id}.json'", ex
              //			reject null
              this.logFatal(`target not supported yet: ${targetName}`);
            }
          } else {
            throw "not find latest";
          }
        } else {
          this.logWarning(`${cn} not found`);
        }
        return fo.__save().then(() => {
          return resolve(fo);
        }).catch((ex) => {
          return reject(ex);
        });
      } else {
        throw "NOT-IMPL";
      }
    });
  }

  listen(bAlive) {
    this.bAlive = bAlive;
    // @log "listen: bAlive=#{@bAlive}"
    if (this.bAlive) {
      //PATTERN: super returns promise
      return new Promise((resolve, reject) => {
        var pr;
        pr = super.listen(this.bAlive);
        return pr.then(() => {
          return this.store.init().then(() => {
            return new Promise((resolve, reject) => {
              return this.store.read("config").then((_config) => {
                var pn, pv, ref;
                ref = this.config;
                for (pn in ref) {
                  pv = ref[pn];
                  if (!_config.hasOwnProperty(pn)) {
                    this.log(`adding: ${pn}`);
                    _config[pn] = this.config[pn];
                  }
                }
                _config.readCnt++;
                this.log(`readCnt=${_config.readCnt}`);
// copy back to keep reference
                for (pn in _config) {
                  pv = _config[pn];
                  this.config[pn] = _config[pn];
                }
                return resolve(_config);
              }).catch((ex) => {
                if (ex.code === "ENOENT") {
                  //									@logWarning "Unable to locate; creating one from scratch!"
                  return resolve(this.config);
                } else {
                  this.logCatch("store.read", ex, true);
                  return reject(ex);
                }
              });
            });
          }).then((_config) => {
            //						O.LOG _config
            return this.configWrite();
          }).then(() => {
            //						@log "listen chain completed"
            return resolve();
          }).catch((ex) => {
            this.logCatch("store.init", ex);
            return reject(ex);
          });
        });
      });
    } else {
      return super.listen(false);
    }
  }

  onReceive(o) {
    //		@log "onReceive [DEFAULT]", o
    _resolve(o);
    throw "_resolve deprecated";
  }

  //		@log "_resolve() called"
  sendSync(o) {
    return new Promise((resolve, reject) => {
      _resolve = resolve;
      this.store.write("test", {
        sent: "bbb"
      });
      this.log("sendSync", o);
      return this.ws.send(JSON.stringify(o));
    });
  }

  //if ut
  static s_ut(testHub) {
    return new ClientFBUT().run(testHub);
  }

};

//endif
module.exports = ClientFB;

return;

//################################################################
ClientFBUT = class ClientFBUT extends UT {
  run(testHub1) {
    this.testHub = testHub1;
    //		@log "CLOUD3=#{@testHub.c.CLOUD}"
    this._s("negative", function() {
      return this.a("get", function(ut) {
        this.client = new ClientFB(this.testHub.c, "/tmp/ut/FBClientNodeUT_get");
        return this.client.start(null).then(() => {
          return this.client.get(1);
        }).then((fo) => {
          //					@log "read", fo
          //					@log fo.pi()
          this.eq(fo.pi(), 3.1415926);
          return ut.resolve();
        }).catch((ex) => {
          //					O.LOG ex
          if (ex.code === "ENOENT") {
            //						@log "correct"
            return ut.resolve();
          } else {
            this.logCatch(this.context, ex);
            return ut.reject(ex);
          }
        });
      });
    });
    return this.s("positive", function() {
      return this.t("simple", function() {});
    });
  }

};

//		@_s "future", ->
//			@_a "register + create obj + re-login + get", (ut) ->
//				@sess.clear()

//				@testHub.init @testHub.NEW_DB_NEW_CLIENT
//				.then (db) =>
//					@log "got fresh db: #{db.about}"
//					@testHub.clientFBCCreateUserRandomRegister()
//				.then (fbc) =>
//					@sess.fbc = fbc
//					O.LOG @sess.fbc.user
//					@sess.user = fbc.user

//					fbc.create
//						flavor: "chocolate"
//					.then (first) =>
//						@sess.first__id = first.__id
//						@eq first.__id, 2
//						@sess.fbc.localDataCompletelyErase()
//					.then =>
//						@sess.fbc.userLogout()
//					.then =>
//						@testHub.clientFBCUserLogon @sess.user.username, @sess.user.password
//					.then (fbc) =>
//						@sess.fbc = fbc
//						@sess.fbc.get @sess.first__id
//					.then (first) =>
//						@eq first.__id, 2
//						@eq first.flavor, "chocolate"
//						ut.resolve()
//				.catch (ex) =>
//					@logCatch null, ex

//		@_s "FIFO queue to server", ->
//endif
cn = -1;

ClientFB = (function() {
  class ClientFB extends Base {
    constructor(c, directory) { //H: ClientFB shouldn't know about @c
      super("ClientFB");
      this.c = c;
      this.directory = directory;
      if (trace.CONSTRUCTORS) {
        this.log(`ClientFB: ${this.c} ${this.directory}`);
      }
      if (!this.c) {
        throw "c req";
      }
      if (!this.directory) {
        throw "directory req";
      }
      this.cn = ++cn;
      this.store = Store.factory(this.directory);
      this.bSocketListenerRunning = false;
    }

    ensure(cn) {
      return new Promise((resolve, reject) => {
        return this.log(`ensure: cn=${cn}`);
      });
    }

    //TODO
    get(id) {
      return new Promise((resolve, reject) => {
        return this.store.read(id).then((o) => {
          var clo, here, k, ref, region, v, version;
          this.log("c", Classes);
          //HACK
          o.__cn = "SmileSpeak.App";
          if (clo = Classes[o.__cn]) {
            //						@log "xxx=#{clo.meta.bSingleton}"

            //						ttt = JSON.stringify clo.meta
            //						@log "ttt=#{ttt}"
            this.log("found", clo);
            this.log("found", clo.meta);
            //					@log "j=#{clo.meta.john()}"
            // meta
            // verion0
            // / NODE_CLIENT
            // / p
            // / activity
            // cn, enumValues, required
            version = 0;
            while (clo[`version${version + 1}`]) {
              version++;
            }
            this.log(`version=${version}`);
            here = "NODE_CLIENT"; //H
            region = clo[`version${version}`][here];
            this.log("region", region);
            this.log("region.p", region.p);
            this.log("region.m", region.m);
            ref = region.m;
            for (k in ref) {
              v = ref[k];
              o[k] = v;
            }
            return resolve(o);
          } else {
            return this.logWarning(`not found: ${o.__cn}`);
          }
        }).catch((ex) => {
          this.logWarning("get:", ex);
          return reject(ex);
        });
      });
    }

    sendToServer(fo) {
      return this.log("sendToServer");
    }

    //TODO
    start(URL) {
      this.URL = URL;
      return new Promise((resolve, reject) => {
        //			@log "START: #{@URL}"

        //			O.LOG @c
        return this.store.init().then(() => {
          //				@log "&&&&&&&&&&&&&&&&&&&&& created #{path}: err=#{err}"
          if (this.bSocketListenerRunning) {
            if (this.ws) {
              throw "already started!";
            } else if (this.URL) {
              this.mOnline = 0;
              this.uptimeBeg = Date.now(); //H
              this.bConnected = false;
              this.bNoConnectionDisplayed = false;
              this.attemptCnt = 0;
              this.connectedCnt = 0;
              //TODO: clearInterval @thread
              this.thread = setInterval(() => {
                if (trace.SOCKET_NOISE) { //or true
                  this.log(`[${this.attemptCnt}] ws=${this.ws} PROD=${this.c.PROD} mOnline=${this.mOnline}`);
                }
                if (!this.ws) {
                  this.attemptCnt++;
                  if (trace.SOCKET_NOISE) {
                    this.log(`[${this.attemptCnt}] attempting to connect to WebSocket ${this.URL}`);
                  }
                  this.mOnline = 1;
                  // https://github.com/websockets/ws
                  this.ws = new WebSocket(this.URL);
                  this.ws.onopen = () => {
                    var attemptCnt, bNoConnectionDisplayed;
                    this.connectedCnt++;
                    if (trace.INTERNET) {
                      this.log(`Internet connected!! connectedCnt=${this.connectedCnt}`);
                    }
                    //							@ws_onopen();
                    this.ws.send(JSON.stringify({
                      cmd: "c-fb-hi",
                      connectedCnt: 0,
                      attemptCnt: this.attemptCnt,
                      clientUpMinutes: 0,
                      cn: this.cn
                    }));
                    this.bConnected = true;
                    bNoConnectionDisplayed = false;
                    attemptCnt = 0;
                    return this.mOnline = 2;
                  };
                  this.ws.onmessage = (e) => {
                    var o;
                    this.log("msg", e.data);
                    o = JSON.parse(e.data);
                    if (o.target === "flexbase") {
                      return this.log(`FB: onmessage: ${e.data}`);
                    }
                  };
                  //							if @ws_onmessage o
                  //								@mOnline = 3
                  this.ws.onerror = (ex) => {
                    var bNoConnectionDisplayed;
                    this.log("onerror");
                    if (ex.message.includes("Connection refused")) { // The operation couldn’t be completed. Connection refused
                      if (!bNoConnectionDisplayed) {
                        this.log("No Internet connection");
                        this.mOnline = 4;
                        //TODO: display to user
                        bNoConnectionDisplayed = true;
                      }
                    } else {
                      this.logError(`onerror: ${ex.message}`, ex);
                    }
                    // util.dumpSafeRecursive(ex);
                    // 1001 websocket "stream end encountered"
                    // https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent
                    // 1000: Normal closure; the connection successfully completed whatever purpose for which it was created.
                    return this.ws = null; // RECENT2
                  };
                  return this.ws.onclose = (ex) => {
                    var _;
                    this.log("onclose", ex);
                    if (this.bConnected) {
                      _ = `onclose: code=${ex.code} reason=${ex.reason}`;
                      if (!onCloseErrorMap[_]) {
                        onCloseErrorMap[_] = true;
                        log(_);
                      }
                      //								@ws_onclose()
                      return this.ws = null;
                    }
                  };
                }
              }, 1000);
            }
          }
          this.logWarning("start() exiting because @bSocketListenerRunning=false");
          return resolve();
        }).catch((ex) => {
          return this.logCatch("tank of gas", ex);
        });
      });
    }

    stop() {
      this.log("stop");
      return this.bSocketListenerRunning = false;
    }

    //if ut
    static s_ut(testHub) {
      //		@log "CLOUD2=#{testHub.c.CLOUD}"
      return new ClientFBUT().run(testHub, "/tmp/ut/tests"); //H
    }

  };

  ClientFB.prototype.one = "TODO"; //H

  return ClientFB;

}).call(this);

//endif
module.exports = ClientFB;
