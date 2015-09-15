async = require('async')

module.exports =
	listMarket: (params, done)->
		Stock.native (err, collection)->
			if err
				return done({code: 1000, error: "[StockService.listMarket] ERROR: Could not native Stock... #{err}"}, null)
			collection.distinct 'market', (err, result)->
				if err
					return done({code: 1000, error: "[StockService.listMarket] ERROR: Could not get Market Stock list... #{err}"}, null)
				return done(null, result)

	list: (params, done)->
		query = {}
		if params.id
			query.id = params.id
		if params.market
			query.market = params.market
		if params.name
			query.name = params.name
		if params.code
			query.code = params.code
		if params.filter
			query.code = {startsWith: params.filter}
		params.page = parseInt(params.page) || 1
		params.limit = parseInt(params.limit) || 50
		if params.limit > 0
			query.limit = params.limit
			query.skip = (params.page-1)*params.limit
		sortCond = {}
		if params.sortBy not in ['code', 'market', 'price']
			params.sortBy = 'code'
		if params.sortOrder not in ['ASC', 'DESC']
			params.sortOrder = 'ASC'
		sortCond[params.sortBy] = params.sortOrder

		Stock.find query
		.sort(sortCond)
		.exec (err, stocks)->
			if err
				return done({code: 1000, error: "[StockService.list] ERROR: Could not get Stock list... #{err}"})
			Stock.count query, (err, total)->
				if err
					return done({code: 1000, error: "[StockService.list] ERROR: Could not count Stock list... #{err}"})
				return done(null, {result: stocks, total: total})
