// Generated by CoffeeScript 2.3.0
//if node
var A, Base, O, UT, fs, util;

fs = require('fs');

A = require('./A');

Base = require('./Base');

O = require('./O');

UT = require('./UT');

util = require('./Util');

//TODO: move this into UT.coffee

//#if ut
//class UTUT extends UT
//	run: ->
//		@s "bag", ->
//			@t "set", ->
//				@bag()
//				@bag.color = "red"
//				@bag()
//			@t "get", ->
//				@bag()
//				@eq @bag.color, "red"
//				@bag.clear()
//				@eq @bag.color, undefined
//				@bag()
//			@t "clear invalid", ->
//				try
//					@bag.clear = "this should fail"
//					@fail "it's illegal to assign 'clear' to bag"
//				catch ex
//					@pass()

//		@s "sync nesting test", ->
//#			@log "SYNC"
//#			t = 0
//#			@log "div 0"
//#			t = t / t
//#			O.DUMP this
//#			@log "hello"
//			@s "a", (ut) =>
//#				@log "section log"
//#				@logError "section logError"
//#				@logCatch "section logCatch"

//				@s "b1", (ut) ->
//					@t "b1c1", (ut) ->
//#						@log "test log"
//#						@logError "test logError"
//#						@logCatch "test logCatch"
//					@t "b1c2", (ut) ->
//				@s "b2", (ut) ->
//					@s "b2c1", (ut) ->
//						@t "b2c1d1", (ut) ->

//		@s "async nesting test", (ut) ->
//			@s "a", (ut) ->
//				@s "b1", (ut) ->
//					@a "b1c1", (ut) ->
//						setTimeout (=> ut.resolve()), 3000
//#						@log "setTimeout"
//#						@log "asynch log"
//#						@logError "asynch logError"
//#						@logCatch "asynch logCatch"
//					@a "b1c2", (ut) ->
//						ut.resolve()
//				@s "b2", (ut) ->
//					@s "b2c1", (ut) ->
//						@a "b2c1d1", (ut) ->
//							ut.resolve()
//#endif
module.exports = {
  UTRun: function() {
    return new UTUT().run();
  }
};

//endif