// Generated by CoffeeScript 2.3.0
var A, API, Base, O, Server_UT, UT, argsNode, server_UT, trace, util;

A = require('./A');

API = require('./API');

Base = require('./Base');

O = require('./O');

trace = require('./trace');

UT = require('./UT');

util = require('./Util');

argsNode = process.argv.slice(2);

Server_UT = class Server_UT extends Base {
  constructor() {
    super();
  }

  listen() {
    if (trace.SOCKET_LISTEN) {
      this.log("listen");
    }
    return argsNode.forEach(function(item) {
      return console.log(item);
    });
  }

};

server_UT = new Server_UT();

server_UT.listen();
