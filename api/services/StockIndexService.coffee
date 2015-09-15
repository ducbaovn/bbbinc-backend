async = require('async')
moment = require('moment')

exports.autoUpdate = (indexDatas, done)->
	StockIndexCache.findOne {group: 'VN'}, (err, vnindex)->
		if err
			return done("[StockIndexService.autoUpdate] ERROR: Could not get VN index... #{err}")
		if vnindex
			vnindex.index = indexDatas[0][3]
			vnindex.change = indexDatas[0][4]
			vnindex.percentChange = indexDatas[0][5]
			vnindex.save (err, ok)->
				if err
					return done("[StockIndexService.autoUpdate] ERROR: Could not update VN index... #{err}")
				StockIndexCache.findOne {group: 'VN30'}, (err, vn30index)->
					if err
						return done("[StockIndexService.autoUpdate] ERROR: Could not get VN30 index... #{err}")
					if vn30index
						vn30index.index = indexDatas[1][3]
						vn30index.change = indexDatas[1][4]
						vn30index.percentChange = indexDatas[1][5]
						vn30index.save (err, ok)->
							if err
								return done("[StockIndexService.autoUpdate] ERROR: Could not update VN30 index... #{err}")
							return done(null)
		else
			# return done('VN index does not had data today')
			StockIndexCache.create [
				group: 'VN'
				index: indexDatas[0][3]
				change: indexDatas[0][4]
				percentChange: indexDatas[0][5]
			,
				group: 'VN30'
				index: indexDatas[1][3]
				change: indexDatas[1][4]
				percentChange: indexDatas[1][5]
			], (err, ok)->
				if err
					return done("[StockIndexService.autoUpdate] ERROR: Could not create VN index... #{err}")
				return done(null)

	# StockIndex.findOne {group: 'VN', date: moment().format('YYYY-MM-DD')}, (err, vnindex)->
	# 	if err
	# 		return done("[StockIndexService.autoUpdate] ERROR: Could not get VN index... #{err}")
	# 	if vnindex
	# 		vnindex.index = indexDatas[0][3]
	# 		vnindex.change = indexDatas[0][4]
	# 		vnindex.percentChange = indexDatas[0][5]
	# 		vnindex.save (err, ok)->
	# 			if err
	# 				return done("[StockIndexService.autoUpdate] ERROR: Could not update VN index... #{err}")
	# 			return done(null)
	# 	else
	# 		# return done('VN index does not had data today')
	# 		StockIndex.create
	# 			group: 'VN'
	# 			index: indexDatas[0][3]
	# 			change: indexDatas[0][4]
	# 			percentChange: indexDatas[0][5]
	# 			date: moment().format('YYYY-MM-DD')
	# 		, (err, ok)->
	# 			if err
	# 				return done("[StockIndexService.autoUpdate] ERROR: Could not create VN index... #{err}")
	# 			return done(null)
	# StockIndex.findOne {group: 'VN30', date: moment().format('YYYY-MM-DD')}, (err, vn30index)->
	# 	if err
	# 		return done("[StockIndexService.autoUpdate] ERROR: Could not get VN30 index... #{err}")
	# 	if vn30index
	# 		vn30index.index = indexDatas[1][3]
	# 		vn30index.change = indexDatas[1][4]
	# 		vn30index.percentChange = indexDatas[1][5]
	# 		vn30index.save (err, ok)->
	# 			if err
	# 				return done("[StockIndexService.autoUpdate] ERROR: Could not update VN30 index... #{err}")
	# 			return done(null)
	# 	else
	# 		# return done('VN30 index does not had data today')
	# 		StockIndex.create 
	# 			group: 'VN30'
	# 			index: indexDatas[1][3]
	# 			change: indexDatas[1][4]
	# 			percentChange: indexDatas[1][5]
	# 			date: moment().format('YYYY-MM-DD')
	# 		, (err, ok)->
	# 			if err
	# 				return done("[StockIndexService.autoUpdate] ERROR: Could not create VN30 index... #{err}")
	# 			return done(null)

exports.createDaily = (done)->
	StockIndexCache.find {}, (err, stockIndexs)->
		if err
			return done("[StockIndexService.createDaily] ERROR: Could not get VN index Cache... #{err}")
		if stockIndexs[0]?
			for obj in stockIndexs
				delete obj.id
			StockIndex.create stockIndexs, (err, todayIndexs)->
				if err
					return done("[StockIndexService.createDaily] ERROR: Could not create today VN index... #{err}")
				return done(null)
		else
			return done("[StockIndexService.createDaily] ERROR: Could not find VN index Cache")

exports.list = (params, done)->
	query = {}
	if params.id
		query.id = params.id
	if params.group
		query.group = params.group
	if params.date
		query.date = moment(params.date).format('YYYY-MM-DD')
	if params.dates
		query.date = params.dates
	if params.fromDate
		query.date = {'>=': params.fromDate}
	if params.toDate
		query.date['<='] = params.toDate
	if params.dayOfWeek
		query.dayOfWeek = params.dayOfWeek
	params.page = parseInt(params.page) || 1
	params.limit = parseInt(params.limit) || 30
	if params.limit > 0
		query.limit = params.limit
		query.skip = (params.page-1)*params.limit
	sortCond = {}
	if params.sortBy not in ['date']
		params.sortBy = 'date'
	if params.orderBy not in ['ASC', 'DESC']
		params.orderBy = 'DESC'
	sortCond[params.sortBy] = params.orderBy
	
	StockIndex.find query
	.sort(sortCond)
	.exec (err, indexs)->
		if err
			return done({code: 1000, error: "[StockIndex.list] ERROR: Could not get Stock Index list... #{err}"})
		StockIndex.count query, (err, total)->
			if err
				return done({code: 1000, error: "[StockIndex.list] ERROR: Could not count Stock Index list... #{err}"})
			return done(null, {result: indexs, total: total})

exports.newList = (params, done)->
	query = {}
	if params.id
		query.id = params.id
	if params.group
		query.group = params.group
	params.page = parseInt(params.page) || 1
	params.limit = parseInt(params.limit) || 30
	if params.limit > 0
		query.limit = params.limit
		query.skip = (params.page-1)*params.limit
	sortCond = {}
	if params.sortBy not in ['group', 'index']
		params.sortBy = 'group'
	if params.orderBy not in ['ASC', 'DESC']
		params.orderBy = 'ASC'
	sortCond[params.sortBy] = params.orderBy
	
	StockIndexCache.find query
	.sort(sortCond)
	.exec (err, indexs)->
		if err
			return done({code: 1000, error: "[StockIndexService.newList] ERROR: Could not get Stock Index Cache list... #{err}"})
		return done(null, indexs)
