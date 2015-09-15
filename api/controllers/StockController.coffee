async = require('async')

module.exports =

	listMarket: (req, res)->
		# res.header("Access-Control-Allow-Credentials", true)
		# res.header("Access-Control-Allow-Origin", "*")
		params = req.allParams()
		StockService.listMarket params, (err, list)->
			if err
				sails.log.info err.error
				return res.badRequest(err)
			sails.log.info '[StockController.listMarket] SUCCESS: Send list market'
			return res.send list
	list: (req, res)->
		# res.header("Access-Control-Allow-Origin", "*")
		params = req.allParams()
		StockService.list params, (err, list)->
			if err
				sails.log.info err.error
				return res.badRequest(err)
			sails.log.info '[StockController.list] SUCCESS: Send Stock list'
			return res.send list

	refresh: (req, res)->
		DataService.reqData (err, reqData)->
			if err
				return res.badRequest err: err
			DataService.getStockData reqData, (err, data)->
				if err
					return res.badRequest err: err
				StockIndexService.autoUpdate data.index, (err)->
					if err
						return res.badRequest err: err
					StockInfoService.autoUpdate data.stock, (err)->
						if err
							return res.badRequest err: err
					StockUserService.autoUpdate (err)->
						if err
							return res.badRequest err: err
						UserPropertyService.autoUpdate (err, lastDay)->
							if err
								return res.badRequest err: err
							UserIndexService.autoUpdate (err)->
								if err
									return res.badRequest err: err
								return res.send success: 'Refresh success'