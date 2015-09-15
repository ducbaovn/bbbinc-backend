exports.newList = (req, res)->
	params = req.allParams()
	# res.header("Access-Control-Allow-Origin", "*")
	params.user = req.user.id
	UserPropertyService.newList params, (err, list)->
		if err
			sails.log.info err.log
			return res.badRequest {code: err.code, error: err.error}
		return res.send list

exports.yearlyChart = (req, res)->
	params = req.allParams()
	# res.header("Access-Control-Allow-Origin", "*")
	params.user = req.user.id
	UserPropertyService.yearlyChart params, (err, result)->
		if err
			sails.log.info err.log
			return res.badRequest {code: err.code, error: err.error}
		return res.send result