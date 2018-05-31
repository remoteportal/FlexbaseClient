trace = require './trace'


# PROJECT AGNOSTIC!!!



module.exports =
	enumCheck: (target, css) -> (",#{css},").contains ",#{target},"
