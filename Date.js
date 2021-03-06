// Generated by CoffeeScript 2.3.0
//if node
var MMSS, N, NODE_util, O, dateTimeHyphenated, fs, trace;

fs = require('fs');

NODE_util = require('util');

//elseif rn
//import Expo, { FileSystem } from 'expo'
//endif
N = require('./N');

O = require('./O');

trace = require('./trace');

// PROJECT AGNOSTIC!!!
dateTimeHyphenated = function() {
  var dd, mm, today, yyyy;
  today = new Date;
  dd = today.getDate();
  mm = today.getMonth() + 1;
  yyyy = today.getFullYear();
  if (dd < 10) {
    dd = '0' + dd;
  }
  if (mm < 10) {
    mm = '0' + mm;
  }
  return `${yyyy}-${mm}-${dd} ${N.ZEROPAD(today.getHours(), 2)}-${N.ZEROPAD(today.getMinutes(), 2)}-${N.ZEROPAD(today.getSeconds(), 2)}`;
};

MMSS = function() {
  var date;
  return `${N.ZEROPAD((date = new Date).getMinutes(), 2)}:${N.ZEROPAD(date.getSeconds(), 2)}`;
};

module.exports = {
  dateTimeHyphenated: dateTimeHyphenated,
  MMSS: MMSS
};
