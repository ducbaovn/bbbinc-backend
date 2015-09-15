async = require('async')
moment = require('moment')

exports.autoUpdate = (stockDatas, done)->
	async.each stockDatas, (stockData, cb)->
		Stock.update {code: stockData[0]}, {price: if stockData[10] != '0' then stockData[10] else stockData[1]}, (err, stock)->
			if err || !stock[0]
				return cb("[StockInfoService.autoUpdate] ERROR: Could not update stock... #{err}")
			StockInfoCache.findOne {stock: stock[0].id}
			, (err, stockInfo)->
				if err
					return cb("[StockInfoService.autoUpdate] ERROR: Could not get StockInfo... #{err}")
				if stockInfo
					stockInfo.open = if stockData[1] then stockData[1] else 0
					stockInfo.ceiling = if stockData[2] then stockData[2] else 0
					stockInfo.floor = if stockData[3] then stockData[3] else 0
					stockInfo.bid3 = if stockData[4] then stockData[4] else 0
					stockInfo.bid3Vol = if stockData[5] then stockData[5] else 0
					stockInfo.bid2 = if stockData[6] then stockData[6] else 0
					stockInfo.bid2Vol = if stockData[7] then stockData[7] else 0
					stockInfo.bid1 = if stockData[8] then stockData[8] else 0
					stockInfo.bid1Vol = if stockData[9] then stockData[9] else 0
					stockInfo.deal = if stockData[10] != '0' then stockData[10] else stockData[1]
					stockInfo.dealVol = if stockData[11] then stockData[11] else 0
					stockInfo.change = if stockData[10] != '0' then (stockData[10] - stockData[1]).toFixed(1) else 0
					stockInfo.offer1 = if stockData[12] then stockData[12] else 0
					stockInfo.offer1Vol = if stockData[13] then stockData[13] else 0
					stockInfo.offer2 = if stockData[14] then stockData[14] else 0
					stockInfo.offer2Vol = if stockData[15] then stockData[15] else 0
					stockInfo.offer3 = if stockData[16] then stockData[16] else 0
					stockInfo.offer3Vol = if stockData[17] then stockData[17] else 0
					stockInfo.save (err, ok)->
						if err
							return cb("[StockInfoService.autoUpdate] ERROR: Could not update StockInfo... #{err}")
						return cb()
				else
					# cb('StockInfo does not had today Data')
					StockInfoCache.create
						stock: stock[0].id
						open : if stockData[1] then stockData[1] else 0
						ceiling : if stockData[2] then stockData[2] else 0
						floor : if stockData[3] then stockData[3] else 0
						bid3 : if stockData[4] then stockData[4] else 0
						bid3Vol : if stockData[5] then stockData[5] else 0
						bid2 : if stockData[6] then stockData[6] else 0
						bid2Vol : if stockData[7] then stockData[7] else 0
						bid1 : if stockData[8] then stockData[8] else 0
						bid1Vol : if stockData[9] then stockData[9] else 0
						deal : if stockData[10] != '0' then stockData[10] else stockData[1]
						dealVol : if stockData[11] then stockData[11] else 0
						change : if stockData[10] != '0' then (stockData[10] - stockData[1]).toFixed(1) else 0
						offer1 : if stockData[12] then stockData[12] else 0
						offer1Vol : if stockData[13] then stockData[13] else 0
						offer2 : if stockData[14] then stockData[14] else 0
						offer2Vol : if stockData[15] then stockData[15] else 0
						offer3 : if stockData[16] then stockData[16] else 0
						offer3Vol : if stockData[17] then stockData[17] else 0
					, (err, ok)->
						if err
							return cb("[StockInfoService.autoUpdate] ERROR: Could not create StockInfo... #{JSON.stringify(err)}")
						return cb()						
	, (err)->
		if err
			return done(err)
		return done(null)	


	# async.each stockDatas, (stockData, cb)->
	# 	Stock.update {code: stockData[0]}, {price: if stockData[10] != '0' then stockData[10] else stockData[1]}, (err, stock)->
	# 		if err || !stock[0]
	# 			return cb("[StockInfoService.autoUpdate] ERROR: Could not update stock... #{err}")
	# 		StockInfo.findOne {stock: stock[0].id, date: moment().format('YYYY-MM-DD')}
	# 		, (err, stockInfo)->
	# 			if err
	# 				return cb("[StockInfoService.autoUpdate] ERROR: Could not get StockInfo... #{err}")
	# 			if stockInfo
	# 				stockInfo.open = if stockData[1] then stockData[1] else 0
	# 				stockInfo.ceiling = if stockData[2] then stockData[2] else 0
	# 				stockInfo.floor = if stockData[3] then stockData[3] else 0
	# 				stockInfo.bid3 = if stockData[4] then stockData[4] else 0
	# 				stockInfo.bid3Vol = if stockData[5] then stockData[5] else 0
	# 				stockInfo.bid2 = if stockData[6] then stockData[6] else 0
	# 				stockInfo.bid2Vol = if stockData[7] then stockData[7] else 0
	# 				stockInfo.bid1 = if stockData[8] then stockData[8] else 0
	# 				stockInfo.bid1Vol = if stockData[9] then stockData[9] else 0
	# 				stockInfo.deal = if stockData[10] != '0' then stockData[10] else stockData[1]
	# 				stockInfo.dealVol = if stockData[11] then stockData[11] else 0
	# 				stockInfo.change = if stockData[10] != '0' then (stockData[10] - stockData[1]).toFixed(1) else 0
	# 				stockInfo.offer1 = if stockData[12] then stockData[12] else 0
	# 				stockInfo.offer1Vol = if stockData[13] then stockData[13] else 0
	# 				stockInfo.offer2 = if stockData[14] then stockData[14] else 0
	# 				stockInfo.offer2Vol = if stockData[15] then stockData[15] else 0
	# 				stockInfo.offer3 = if stockData[16] then stockData[16] else 0
	# 				stockInfo.offer3Vol = if stockData[17] then stockData[17] else 0
	# 				stockInfo.save (err, ok)->
	# 					if err
	# 						return cb("[StockInfoService.autoUpdate] ERROR: Could not update StockInfo... #{err}")
	# 					return cb()
	# 			else
	# 				# cb('StockInfo does not had today Data')
	# 				StockInfo.create
	# 					stock: stock[0].id
	# 					open : if stockData[1] then stockData[1] else 0
	# 					ceiling : if stockData[2] then stockData[2] else 0
	# 					floor : if stockData[3] then stockData[3] else 0
	# 					bid3 : if stockData[4] then stockData[4] else 0
	# 					bid3Vol : if stockData[5] then stockData[5] else 0
	# 					bid2 : if stockData[6] then stockData[6] else 0
	# 					bid2Vol : if stockData[7] then stockData[7] else 0
	# 					bid1 : if stockData[8] then stockData[8] else 0
	# 					bid1Vol : if stockData[9] then stockData[9] else 0
	# 					deal : if stockData[10] != '0' then stockData[10] else stockData[1]
	# 					dealVol : if stockData[11] then stockData[11] else 0
	# 					change : if stockData[10] != '0' then (stockData[10] - stockData[1]).toFixed(1) else 0
	# 					offer1 : if stockData[12] then stockData[12] else 0
	# 					offer1Vol : if stockData[13] then stockData[13] else 0
	# 					offer2 : if stockData[14] then stockData[14] else 0
	# 					offer2Vol : if stockData[15] then stockData[15] else 0
	# 					offer3 : if stockData[16] then stockData[16] else 0
	# 					offer3Vol : if stockData[17] then stockData[17] else 0
	# 				, (err, ok)->
	# 					if err
	# 						return cb("[StockInfoService.autoUpdate] ERROR: Could not create StockInfo... #{JSON.stringify(err)}")
	# 					return cb()						
	# , (err)->
	# 	if err
	# 		return done(err)
	# 	return done(null)

exports.createDaily = (done)->
	StockInfoCache.find {}, (err, stockInfos)->
		if err
			return done("[StockInfoService.createDaily] ERROR: Could not get StockInfo Cache... #{err}")
		if stockInfos[0]?
			for obj in stockInfos
				delete obj.id
			StockInfo.create stockInfos, (err, todayInfos)->
				if err
					return done("[StockInfoService.createDaily] ERROR: Could not create today StockInfo... #{err}")
				return done(null)
		else
			return done("[StockInfoService.createDaily] ERROR: Could not find StockInfo Cache")

exports.list = (params, done) ->  
	# build sort condition
	# if !params.sortBy || params.sortBy not in ['stock.code']
	# 	params.sortBy = 'stock.code'
	# if !params.sortOrder || params.sortOrder not in ['ASC', 'DESC']
	# 	params.sortOrder = 'ASC'
	# params.sort = params.sortBy + ' ' + params.sortOrder
	# sortCond = {}
	# sortCond[params.sortBy] = params.sortOrder

	cond = {}
	# StockInfo.native
	if params.code
		try
			cond.code = JSON.parse params.code
		catch err
			return done({code: 1006, error: 'Could not JSON.parse', log: "[StockService.list] ERROR: Could not JSON.parse params.code... #{err}"})
	
	if params.market
		cond.market = params.market
	Stock.find cond, (err, stocks)->
		if err
			return done({code: 1000, error: "[StockInfoService.list] ERROR: Could not get Stock list... #{err}"})
		query = {}
		if stocks[0]
			query.stock = _.pluck stocks, 'id'
		if params.id
			query.id = params.id
		query.date = if params.date then moment(params.date).format('YYYY-MM-DD') else moment().format('YYYY-MM-DD')
		if params.dates
			query.date = params.dates
		# build condition  
		params.page = parseInt(params.page) || 1
		params.limit = parseInt(params.limit) || 50
		params.skip = (params.page-1)*params.limit

		# if params.limit > 0
		#   cond.limit = params.limit
		#   cond.skip = params.limit * (params.page - 1)
		StockInfo.find query
		.populate('stock')
		.exec (err, stockInfos)->
			if err
				return done({code: 1000, error: "[StockInfoService.list] ERROR: Could not get StockInfo list... #{err}"}, null)
			sortedStocks = _.sortBy stockInfos, (stockInfo)->
				stockInfo.stock.code
			total = sortedStocks.length
			return done(null, {result: sortedStocks.slice(params.skip, params.skip+params.limit), total: total})

exports.newList = (params, done) ->  
	cond = {}
	if params.code
		try
			cond.code = JSON.parse params.code
		catch err
			return done({code: 1006, error: 'Could not JSON.parse', log: "[StockService.list] ERROR: Could not JSON.parse params.code... #{err}"})
	
	if params.market
		cond.market = params.market
	Stock.find cond, (err, stocks)->
		if err
			return done({code: 1000, error: "[StockInfoService.newList] ERROR: Could not get Stock list... #{err}"})
		query = {}
		if stocks[0]
			query.stock = _.pluck stocks, 'id'
		if params.id
			query.id = params.id
	
		# build condition  
		params.page = parseInt(params.page) || 1
		params.limit = parseInt(params.limit) || 50
		params.skip = (params.page-1)*params.limit

		# if params.limit > 0
		#   cond.limit = params.limit
		#   cond.skip = params.limit * (params.page - 1)
		StockInfoCache.find query
		.populate('stock')
		.exec (err, stockInfos)->
			if err
				return done({code: 1000, error: "[StockInfoService.newList] ERROR: Could not get StockInfoCache list... #{err}"}, null)
			sortedStocks = _.sortBy stockInfos, (stockInfo)->
				stockInfo.stock.code
			total = sortedStocks.length
			return done(null, {result: sortedStocks.slice(params.skip, params.skip+params.limit), total: total})

exports.changeList = (params, done) ->
	query = {}
	if params.stock
		query.stock = params.stock
	query.change = {'!': ['0', '0.0']}
	StockInfoCache.find query
	.populate('stock')
	.exec (err, stocks)->
		if err
			return done({code: 1000, error: "[StockInfoService.changeList] ERROR: Could not get StockInfoCache list... #{err}"}, null)

		stocks = _.groupBy(stocks, (stock)-> stock.change > 0)
		loseStocks = stocks['false']
		gainStocks = stocks['true']		
		return done(null, {lose: loseStocks, gain: gainStocks})
