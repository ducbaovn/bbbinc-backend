exports.newList = (req, res)->
	params = req.allParams()
	# res.header("Access-Control-Allow-Origin", "*")
	User.findOne nickname: 'bbbfund', (err, bbbfund)->
		if err
			sails.log.info "[bbbfund/PropertyController.new] ERROR: Could not find user bbbfund... #{err}"
			return res.badRequest {code: 1000, error: "Could not process"}
		params.user = bbbfund.id
		UserPropertyService.newList params, (err, list)->
			if err
				sails.log.info err.log
				return res.badRequest {code: err.code, error: err.error}
			return res.send list

exports.yearlyChart = (req, res)->
	params = req.allParams()
	# res.header("Access-Control-Allow-Origin", "*")
	User.findOne nickname: 'bbbfund', (err, bbbfund)->
		if err
			sails.log.info "[bbbfund/PropertyController.yearlyChart] ERROR: Could not find user bbbfund... #{err}"
			return res.badRequest {code: 1000, error: "Could not process"}
		params.user = bbbfund.id
		UserPropertyService.yearlyChart params, (err, result)->
			if err
				sails.log.info err.log
				return res.badRequest {code: err.code, error: err.error}
			return res.send result