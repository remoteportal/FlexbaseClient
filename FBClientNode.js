// Generated by CoffeeScript 2.3.0
//if node
var A, Base, Classes, FBClientNode, FBClientNodeUT, O, Store, UT, WebSocket, cn, logBase, trace, util;

WebSocket = require('ws');

A = require('./A');

Base = require('./Base');

Classes = require('./Classes');

O = require('./O');

Store = require('./Store');

trace = require('./trace');

UT = require('./UT');

util = require('./Util');

//endif

//if ut
//flexbaseAuth = require './flexbaseAuth'		#H
//TestClient = require './TestClient'

//TRIED to move to FlexbaseCoffee.coffee
//33:02 DEV 18-04-20.2 (0.0.95) [0] connect ::ffff:73.53.168.153

//curl ifconfig.me
//73.53.168.153

//http://www.skillsplanet.com:3366
FBClientNodeUT = class FBClientNodeUT extends UT {
  run(testHub1) {
    this.testHub = testHub1;
    //		@log "CLOUD3=#{@testHub.c.CLOUD}"
    this.s("HELP", function() {
      return this.a("get", function(ut) {
        this.client = new FBClientNode(this.testHub.c, "/tmp/ut/FBClientNodeUT_get");
        return this.client.start(null).then(() => {
          return this.client.get(1);
        }).then((fo) => {
          this.log("read", fo);
          this.log(fo.pi());
          this.eq(fo.pi(), 3.1415926);
          return ut.resolve();
        }).catch((ex) => {
          //					O.DUMP ex
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
    //		@_s "future", ->
    //			@_a "register + create obj + re-login + get", (ut) ->
    //				@sess.clear()

    //				@testHub.init @testHub.NEW_DB_NEW_CLIENT
    //				.then (db) =>
    //					@log "got fresh db: #{db.about}"
    //					@testHub.clientFBCCreateUserRandomRegister()
    //				.then (fbc) =>
    //					@sess.fbc = fbc
    //					O.DUMP @sess.fbc.user
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
    return this._s("FIFO queue to server", function() {});
  }

};

//endif
logBase = util.logBase;

cn = -1;

FBClientNode = (function() {
  class FBClientNode extends Base {
    constructor(c, directory) { //H: FBClientNode shouldn't know about @c
      super("FBClientNode");
      this.c = c;
      this.directory = directory;
      if (trace.CONSTRUCTORS) {
        this.log(`FBClientNode: ${this.c} ${this.directory}`);
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
            // / NODE_LOCAL
            // / p
            // / activity
            // cn, enumValues, required
            version = 0;
            while (clo[`version${version + 1}`]) {
              version++;
            }
            this.log(`version=${version}`);
            here = "NODE_LOCAL"; //H
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

        //			O.DUMP @c
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
                if (trace.INTERNET_NOISE) { //or true
                  this.log(`[${this.attemptCnt}] ws=${this.ws} PROD=${this.c.PROD} mOnline=${this.mOnline}`);
                }
                if (!this.ws) {
                  this.attemptCnt++;
                  if (trace.INTERNET_NOISE) {
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
    s_ut(testHub) {
      //		@log "CLOUD2=#{testHub.c.CLOUD}"
      return new FBClientNodeUT().run(testHub, "/tmp/ut/tests"); //H
    }

  };

  FBClientNode.prototype.one = "TODO"; //H

  return FBClientNode;

}).call(this);

//endif
module.exports = FBClientNode;
