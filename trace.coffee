ALL_TRISTATE = null

TRACE_DUMP = 0



module.exports =
	# *
	CONSTRUCTORS: 0
	DETAIL: 0
	NOISE: 0		#UNUSED
	WARNINGS: 1




	# TestClient
	TEST_CLIENT: 0


	# TestHub
	TESTHUB: 0


	# Tests
	TESTS: 0


	# UT
	UT_BAG_SET: 0
	UT_BAG_DUMP: 0
	UT_TEST_LOG_ENABLED: 1
	UT_TEST_POST_ONE_LINER: 0
	UT_TEST_PRE_ONE_LINER: 1




	
	#TODO: add name space
	ID_TRANSLATE: 1
	INTERNET: 1		#H
	INTERNET_NOISE: 0		#H
	PROPERTY_DELETE: 1
	RESET: 1
	SAVE_ID: 1
	UPLIST_EMPTY: 1
	UPLOAD: 1


if ALL_TRISTATE?
	for k of module.exports
		module.exports[k] = ALL_TRISTATE


if TRACE_DUMP
	for k, v of module.exports
		console.log "#{k}: #{v}"

return