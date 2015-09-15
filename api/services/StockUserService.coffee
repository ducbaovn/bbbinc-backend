async = require('async')
moment = require('moment')

exports.autoUpdate = (done)->
	StockUserCache.find {}
	.populate('stock')
	.exec (err, stocksUser)->
		if err
			return done("[StockUserService.autoUpdate] ERROR: Could not get today StockUser... #{err}")
		if stocksUser[0]?
			async.each stocksUser, (stockUser, cb)->
				stockUser.price = stockUser.stock.price
				stockUser.total = stockUser.qty * stockUser.price
				stockUser.profit = stockUser.total - stockUser.totalBuy + stockUser.payout
				stockUser.save (err)->
					if err
						return cb("[StockUserService.autoUpdate] ERROR: Could not update StockUser... #{err}")
					return cb()
			, (err)->
				if err
					return done(err)
				return done(null)
		else
			StockUser.native (err, collection)->
				if err
					return done("[StockUserService.autoUpdate] ERROR: Could not native StockUser... #{err}")
				collection.aggregate
					$group:
						_id: ''
						max:
							$max: '$date'
				, (err, result)->
					if err
						return done("[StockUserService.autoUpdate] ERROR: Could not get last date in StockUser... #{err}")
					if result[0]
						StockUser.find date: result[0].max, (err, lastStocks)->
							if err
								return done("[StockUserService.autoUpdate] ERROR: Could not get last StockUser... #{err}")
							for stock in lastStocks
								delete stock.id
								delete stock.date
							StockUserCache.create lastStocks, (err, todayStocks)->
								if err
									return done("[StockUserService.autoUpdate] ERROR: Could not create today StockUser... #{err}")
								return done(null)


	# StockUser.find {date: moment().format('YYYY-MM-DD')}
	# .populate('stock')
	# .exec (err, stocksUser)->
	# 	if err
	# 		return done("[StockUserService.autoUpdate] ERROR: Could not get today StockUser... #{err}")
	# 	if stocksUser[0]?
	# 		async.each stocksUser, (stockUser, cb)->
	# 			stockUser.price = stockUser.stock.price
	# 			stockUser.total = stockUser.qty * stockUser.price
	# 			stockUser.profit = stockUser.total - stockUser.totalBuy + stockUser.payout
	# 			stockUser.save (err)->
	# 				if err
	# 					return cb("[StockUserService.autoUpdate] ERROR: Could not update StockUser... #{err}")
	# 				return cb()
	# 		, (err)->
	# 			if err
	# 				return done(err)
	# 			return done(null)
	# 	else
	# 		StockUser.native (err, collection)->
	# 			if err
	# 				return done("[StockUserService.autoUpdate] ERROR: Could not native StockUser... #{err}")
	# 			collection.aggregate
	# 				$group:
	# 					_id: ''
	# 					max:
	# 						$max: '$date'
	# 			, (err, result)->
	# 				if err
	# 					return done("[StockUserService.autoUpdate] ERROR: Could not get last date in StockUser... #{err}")
	# 				if result[0]
	# 					StockUser.find date: result[0].max, (err, yesterdayStocks)->
	# 						if err
	# 							return done("[StockUserService.autoUpdate] ERROR: Could not get last StockUser... #{err}")
	# 						for stock in yesterdayStocks
	# 							delete stock.id
	# 							delete stock.date
	# 						StockUser.create yesterdayStocks, (err, todayStocks)->
	# 							if err
	# 								return done("[StockUserService.autoUpdate] ERROR: Could not create today StockUser... #{err}")
	# 							return done(null)

exports.createDaily = (done)->
	StockUserCache.find {}, (err, stockUsers)->
		if err
			return done("[StockUserService.createDaily] ERROR: Could not get StockUser Cache... #{err}")
		if stockUsers[0]?
			for obj in stockUsers
				delete obj.id
			StockUser.create stockUsers, (err, todayStocks)->
				if err
					return done("[StockUserService.createDaily] ERROR: Could not create today StockUser... #{err}")
				StockUserCache.destroy qty: 0, (err, zeroStocks)->
					if err
						return done("[StockUserService.createDaily] ERROR: Could not remove StockUser... #{err}")
					sails.log.info "remove zero stock: #{zeroStocks}"
					return done(null)
		else
			return done("[StockUserService.createDaily] ERROR: Could not find StockUserCache")

exports.newList = (params, done)->
	query = {}
	if params.id
		query.id = params.id
	if params.user
		query.user = params.user
	if params.stock
		query.stock = params.stock

	sortCond = {}
	if params.sortBy not in ['total']
		params.sortBy = 'total'
	if params.sortOrder not in ['ASC', 'DESC']
		params.sortOrder = 'DESC'
	sortCond[params.sortBy] = params.sortOrder

	StockUserCache.find query
	.populate('stock')
	.sort(sortCond)
	.exec (err, stocks)->
		if err
			return done({code: 1000, error: "Could not get StockUserCache list", log: "[StockUserService.newList] ERROR: Could not get StockUserCache list... #{err}"})
		return done(null, stocks)

exports.list = (params, done)->
	query = {}
	if params.id
		query.id = params.id
	if params.user
		query.user = params.user
	if params.date
		query.date = params.date
	if params.fromDate
		query.date = {'>=': params.fromDate}
	if params.toDate
		query.date['<='] = params.toDate
	if params.stock
		query.stock = params.stock

	params.page = parseInt(params.page) || 1
	params.limit = parseInt(params.limit) || 50
	if params.limit > 0
		query.limit = params.limit
		query.skip = (params.page-1)*params.limit
	
	sortCond = {}
	if params.sortBy not in ['date', 'user']
		params.sortBy = 'date'
	if params.sortOrder not in ['ASC', 'DESC']
		params.sortOrder = 'DESC'
	sortCond[params.sortBy] = params.sortOrder

	StockUser.find query
	.populate('stock')
	.sort(sortCond)
	.exec (err, stocks)->
		if err
			return done({code: 1000, error: "Could not get StockUser list", log: "[StockUserService.list] ERROR: Could not get StockUser list... #{err}"})
		StockUser.count query, (err, total)->
			if err
				return done({code: 1000, error: "Could not count StockUser list", log: "[StockUserService.list] ERROR: Could not count StockUser list... #{err}"})
			return done(null, {result: stocks, total: total})