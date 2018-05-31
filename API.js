// Generated by CoffeeScript 2.3.0
var BUILD, Base, MariaSQL, NN, O, sql, trace, util;

MariaSQL = require('mariasql');

Base = require('./Base');

O = require('./O');

trace = require('./trace');

util = require('./Util');

NN = function(n) {
  if (("" + n).length === 1) {
    return `0${n}`;
  } else {
    return n;
  }
};

BUILD = "BUILD";

sql = {
  Fsql: function() {
    // https://github.com/mscdex/node-mariasql
    //		SHOW PROCEDURE STATUS;
    //		SHOW FUNCTION STATUS;
    return new MariaSQL({
      host: '127.0.0.1',
      user: 'ut',
      password: '',
      db: 'ut',
      multiStatements: true
    });
  }
};

module.exports = {
  apiFactory: function() {
    return Object.defineProperties({}, {
      _conn: {
        value: null,
        writable: true
      },
      //		audit:
      //			enumerable: true
      //			value: (auditTrailTypeID, data) ->
      //				@log "AUDIT[#{auditTrailTypeID}] API##{reqCounter[1]} #{data}"
      //				@conn.query 'call auditTrailInsert(?,?,?,?)', [
      //					auditTrailTypeID
      //					if @userInfoID > 0 then @userInfoID else null
      //					null	#H:skillID	#HARDCODE
      //					data
      //				], (err, rsets) =>
      //					if err
      //						@logError "auditTrailInsert", err
      bOpen: {
        enumerable: true,
        value: false,
        writable: true
      },
      conn: {
        enumerable: true,
        get: function() {
          if (this._conn) {
            if (!this.bOpen) {
              this._conn = sql.Fsql();
            }
            return this._conn;
          } else {
            this.bOpen = true;
            return this._conn = sql.Fsql();
          }
        }
      },
      d: {
        enumerable: true,
        value: function() {
          if (this._conn) {
            this._conn.end();
            return this.bOpen = false;
          }
        }
      },
      logCatch: {
        enumerable: true,
        value: function(s, o, opt) {
          return util.logBase("apiFactory", `CATCH: ${s}`, o, opt);
        }
      },
      logError: {
        enumerable: true,
        value: function(s, o, opt) {
          return util.logBase("apiFactory", `ERROR: ${s}`, o, opt);
        }
      },
      //# NO! textSend
      //				catch ex
      //					console.log "(ERRNOT)CATCH: #{ex}"
      //		ex:
      //			enumerable: true
      //			value: (err, title, o) ->
      //				console.log "#{@logPre()} - EXCEPTION #{title}"
      //				console.dir err
      //				if o
      //					console.dir o
      //				if PROD
      //					@audit 6, "#{title}: #{JSON.stringify err}"
      //					@textSend "+17048044786", "EX: #{title} #{err}"
      //					@log "afer textSend"

      //				if @bPage
      //					@res.write "EXCEPTION!"

      //					if typeof myVar == 'string'
      //						@res.write err
      //					else
      //						@res.write JSON.stringify err

      //				@d()
      log: {
        enumerable: true,
        value: function(s, o, opt) {
          return util.logBase("apiFactory", s, o, opt);
        }
      },
      query: {
        enumerable: true,
        value: function(stmts, a) {
          return new Promise((resolve, reject) => {
            if (trace.SQL) {
              this.log(stmts);
            }
            if (a != null) {
              return this.conn.query(stmts, a, (err, rsets) => {
                if (err) {
                  this.log("==========================================");
                  console.log(stmts);
                  this.logCatch("query", "err=" + err);
                  return reject(err);
                } else {
                  //							@log "success: #{stmts}"
                  return resolve(rsets);
                }
              });
            } else {
              return this.conn.query(stmts, (err, rsets) => {
                if (err) {
                  this.log("==========================================");
                  console.log(stmts);
                  this.logCatch("query", "err=" + err);
                  return reject(err);
                } else {
                  //							@log "success: #{stmts}"
                  return resolve(rsets);
                }
              }); //H: clusterfuck
            }
          });
        }
      },
      textSend: {
        enumerable: true,
        value: function(to, body) {
          var client;
          this.log(`textSend ${to}`);
          if (throttle(1, `${to}:${body}`)) {
            this.log("okay xxx");
            client = new twilio("AC1c756bb1848dea85e2db9c6e9b3ecb47", "ab7dd3f8f602406661d18e1cc4131036");
            this.log("okay xxx2");
            //client.messages.create(
            //	body: 'Hello, Dave, from SkillsPlanet.com!'	#'I love you and want to hold you in bed every morning!'	#Hello from SkillsPlanet'
            //	to: '+16302345545'	#+17042934893'	#to: '+17048044786'
            //	from: '+17049466359'
            return client.messages.create({
              body: body,
              to: to,
              from: '+17049466359'
            }).then((message) => {
              return this.log(`twilio: sid=${message.sid}`);
            }).catch((ex) => {
              return this.logCatch(`twilio catch: ${ex //NOT: logCatch !!!
}`);
            });
          }
        }
      }
    });
  }
};
