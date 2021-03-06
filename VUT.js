// Generated by CoffeeScript 2.3.0
//if node
//elseif rn
//import Expo, { FileSystem, SQLite } from 'expo'
//endif
var UT, V, VUT, trace;

trace = require('./trace');

UT = require('./UT');

V = require('./V');

// THIS REQUIRED A separate FILE FROM UT.coffee because of a perceived cyclical dependency problem

//if ut
VUT = class VUT extends UT {
  constructor() {
    super("VUT");
  }

  run() {
    this.t("TYPE", function() {
      this.eq(V.TYPE(45), "number");
      this.eq(V.TYPE(new Number(45)), "Number");
      this.eq(V.TYPE("literal string"), "string");
      this.eq(V.TYPE(new String("string class")), "String");
      this.eq(V.TYPE(null), "Null");
      this.eq(V.TYPE(void 0), "undefined");
      this.eq(V.TYPE(function() {}), "function");
      this.eq(V.TYPE(new Date()), "Date");
      this.eq(V.TYPE(new Uint32Array()), "Uint32Array");
      this.eq(V.TYPE([]), "Array");
      this.eq(V.TYPE(true), "boolean");
      return this.eq(V.TYPE(new Boolean(false)), "Boolean");
    });
    return this.t("DUMP", function() {
      if (trace.UT_TEST_LOG_ENABLED || 1) {
        this.log(V.DUMP("literal string"));
        this.log(V.DUMP(new String("string object")));
        this.log(V.DUMP({
          a: "a"
        }));
        this.log(V.DUMP(45));
        this.log(V.DUMP(true));
        this.log(V.DUMP(void 0));
        this.log(V.DUMP(null));
        this.log(V.DUMP(VUT));
        this.log(V.DUMP(function() {}));
        this.log(V.DUMP([]));
        this.log(V.DUMP(new Date()));
        return this.log(V.DUMP(new Uint16Array()));
      }
    });
  }

};

//endif
module.exports = {
  //if ut
  s_ut: function() {
    return new VUT().run();
  }
};

//endif
