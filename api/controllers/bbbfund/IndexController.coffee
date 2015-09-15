exports.newList = (req, res)->
	params = req.allParams()
	# res.header("Access-Control-Allow-Origin", "*")
	User.findOne nickname: 'bbbfund', (err, bbbfund)->
		if err
			sails.log.info "[bbbfund/IndexController.new] ERROR: Could not find user bbbfund... #{err}"
			return res.badRequest {code: 5000, error: "Could not process"}
		params.user = bbbfund.id
		UserIndexService.newList params, (err, list)->
			if err
				sails.log.info err.log
				return res.badRequest {code: err.code, error: err.error}
			
			result = {bbbfund: list[0]}
			StockIndexService.newList params, (err, vnList)->
				if err
					sails.log.info err.log
					return res.badRequest {code: err.code, error: err.error}
				if vnList[0].group == 'VN'
					result.vn = vnList[0]
					result.vn30 = vnList[1]
				else
					result.vn = vnList[1]
					result.vn30 = vnList[0]
				return res.send(result)

exports.chart = (req, res)->
	params = req.allParams()
	# res.header("Access-Control-Allow-Origin", "*")
	User.findOne nickname: 'bbbfund', (err, bbbfund)->
		if err
			sails.log.info "[bbbfund/IndexController.chart] ERROR: Could not find user bbbfund... #{err}"
			return res.badRequest {code: 1000, error: "Could not process"}
		params.user = bbbfund.id
		ChartService.indexLine params, (err, chartData)->
			if err
				sails.log.info err.log
				return res.badRequest({code: err.code, error: err.error})
			return res.send(chartData)