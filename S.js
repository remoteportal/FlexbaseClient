// Generated by CoffeeScript 2.3.0
var trace;

trace = require('./trace');

// PROJECT AGNOSTIC!!!
module.exports = {
  enumCheck: function(target, css) {
    return `,${css},`.contains(`,${target},`);
  }
};
