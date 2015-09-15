moment = require('moment')

exports.autoUpdate = (done)->	
	UserIndex.native (err, collection)->
		if err
			return done("[UserIndexService.autoUpdate] ERROR: Could not native UserIndex... #{err}")
		collection.aggregate
			$group:
				_id: ''
				max:
					$max: '$date'
		, (err, result)->
			if err
				return done("[StockUserService.autoUpdate] ERROR: Could not get last date in StockUser... #{err}")
			if result[0]
				UserIndexCache.find {}, (err, userIndexs)->
					if err
						return done("[UserIndexService.autoUpdate] ERROR: Could not process...#{err}")
					if userIndexs[0]
						async.each userIndexs, (userIndex, cb)->							
							UserProperty.findOne {user: userIndex.user, date: result[0].max}, (err, lastProperty)->
								if err
									return cb("[UserIndexService.autoUpdate] ERROR: Could not get last UserProperty... #{err}")
								UserPropertyCache.findOne {user: userIndex.user}, (err, todayProperty)->
									if err || !todayProperty
										return cb("[UserIndexService.autoUpdate] ERROR: Could not get today UserProperty... #{err}")
									lastPropertyTotal = if lastProperty then lastProperty.total else todayProperty.capital
									lastPropertyProfit = if lastProperty then lastProperty.profit else 0
									userIndex.index = (userIndex.index - userIndex.change)*todayProperty.total/(todayProperty.capital + lastPropertyProfit)
									userIndex.change = userIndex.index*(1 - (todayProperty.capital+lastPropertyProfit)/todayProperty.total)
									userIndex.percentChange = userIndex.change/(userIndex.index - userIndex.change)*100
									userIndex.save (err)->
										if err
											return cb("[UserIndexService.autoUpdate] ERROR: Could not update UserIndex... #{err}")
										return cb()
						, (err)->
							if err
								return done(err)
							return done(null)
					else
						UserIndex.find {date: result[0].max}, (err, lastIndexs)->
							if err
								return done("[UserIndexService.autoUpdate] ERROR: Could not get last UserIndex... #{err}")
							async.each lastIndexs, (lastIndex, cb)->
								UserProperty.findOne {user: lastIndex.user, date: result[0].max}, (err, lastProperty)->
									if err
										return cb("[UserIndexService.autoUpdate] ERROR: Could not get last UserProperty... #{err}")
									UserPropertyCache.findOne {user: lastIndex.user}, (err, todayProperty)->
										if err || !todayProperty
											return cb("[UserIndexService.autoUpdate] ERROR: Could not get today UserProperty... #{err}")
										lastPropertyTotal = if lastProperty then lastProperty.total else todayProperty.capital
										lastPropertyProfit = if lastProperty then lastProperty.profit else 0
										UserIndexCache.create
											user: lastIndex.user
											index: lastIndex.index*todayProperty.total/(lastProperty.profit + todayProperty.capital)
											change: lastIndex.index*(todayProperty.total/(lastProperty.profit + todayProperty.capital) - 1)
											percentChange: (todayProperty.total/(lastProperty.profit + todayProperty.capital) - 1)*100
										, (err, todayIndex)->
											if err
												return cb("[UserIndexService.autoUpdate] ERROR: Could not create today UserIndex... #{err}")
											return cb()
							, (err)->
								if err
									return done(err)
								return done(null)

	# UserIndex.native (err, collection)->
	# 	if err
	# 		return done("[UserIndexService.autoUpdate] ERROR: Could not native UserIndex... #{err}")
	# 	collection.aggregate
	# 		$group:
	# 			_id: ''
	# 			max:
	# 				$max: '$date'
	# 	, (err, result)->
	# 		if err
	# 			return done("[UserIndexService.autoUpdate] ERROR: Could not get last date in UserIndex... #{err}")
	# 		if result[0]
	# 			UserIndex.find {date: moment().format('YYYY-MM-DD')}, (err, userIndexs)->
	# 				if err
	# 					return done("[UserIndexService.autoUpdate] ERROR: Could not process...#{err}")
	# 				if userIndexs[0]
	# 					async.each userIndexs, (userIndex, cb)->							
	# 						UserProperty.findOne {user: userIndex.user, date: moment('2015-08-02').format('YYYY-MM-DD')}, (err, lastProperty)->
	# 							if err
	# 								return cb("[UserIndexService.autoUpdate] ERROR: Could not get last UserProperty... #{err}")
	# 							UserProperty.findOne {user: userIndex.user, date: moment().format('YYYY-MM-DD')}, (err, todayProperty)->
	# 								if err || !todayProperty
	# 									return cb("[UserIndexService.autoUpdate] ERROR: Could not get today UserProperty... #{err}")
	# 								userIndex.index = (userIndex.index - userIndex.change)*todayProperty.total/lastProperty.total
	# 								userIndex.change = userIndex.index*(1 - lastProperty.total/todayProperty.total)
	# 								userIndex.percentChange = userIndex.change/(userIndex.index - userIndex.change)*100
	# 								userIndex.save (err)->
	# 									if err
	# 										return cb("[UserIndexService.autoUpdate] ERROR: Could not update UserIndex... #{err}")
	# 									return cb()
	# 					, (err)->
	# 						if err
	# 							return done(err)
	# 						return done(null)
	# 				else
	# 					UserIndex.find date: result[0].max, (err, lastIndexs)->
	# 						if err
	# 							return done("[UserIndexService.autoUpdate] ERROR: Could not get last UserIndex... #{err}")
	# 						async.each lastIndexs, (lastIndex, cb)->
	# 							UserProperty.findOne {user: lastIndex.user, date: result[0].max}, (err, lastProperty)->
	# 								if err
	# 									return cb("[UserIndexService.autoUpdate] ERROR: Could not get last UserProperty... #{err}")
	# 								UserProperty.findOne {user: lastIndex.user, date: moment().format('YYYY-MM-DD')}, (err, todayProperty)->
	# 									if err || !todayProperty
	# 										return cb("[UserIndexService.autoUpdate] ERROR: Could not get today UserProperty... #{err}")
	# 									UserIndex.create
	# 										user: lastIndex.user
	# 										index: lastIndex.index*todayProperty.total/lastProperty.total
	# 										change: lastIndex.index*(todayProperty.total/lastProperty.total - 1)
	# 										percentChange: (todayProperty.total/lastProperty.total - 1)*100
	# 									, (err, todayIndex)->
	# 										if err
	# 											return cb("[UserIndexService.autoUpdate] ERROR: Could not create today UserIndex... #{err}")
	# 										return cb()
	# 						, (err)->
	# 							if err
	# 								return done(err)
	# 							return done(null)

exports.createDaily = (done)->
	UserIndexCache.find {}, (err, userIndexs)->
		if err
			return done("[UserIndexService.createDaily] ERROR: Could not get UserIndex Cache... #{err}")
		if userIndexs[0]?
			for obj in userIndexs
				delete obj.id
			UserIndex.create userIndexs, (err, todayIndexs)->
				if err
					return done("[UserIndexService.createDaily] ERROR: Could not create today UserIndex... #{err}")
				return done(null)
		else
			return done("[UserIndexService.createDaily] ERROR: Could not find UserIndex Cache")

exports.list = (params, done)->
	query = {}
	if params.id
		query.id = params.id
	if params.user
		query.user = params.user
	if params.date
		query.date = moment(params.date).format('YYYY-MM-DD')
	if params.dates
		query.date = params.dates
	if params.fromDate
		query.date = {'>=': moment(params.fromDate).format('YYYY-MM-DD')}
	if params.toDate
		query.date['<='] = moment(params.toDate).format('YYYY-MM-DD')
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

	UserIndex.find query
	.sort(sortCond)
	.exec (err, indexs)->
		if err
			return done({code: 1000, error: "[UserIndexService.list] ERROR: Could not get User Index list... #{err}"})
		UserIndex.count query, (err, total)->
			if err
				return done({code: 1000, error: "[UserIndexService.list] ERROR: Could not count User Index list... #{err}"})
			return done(null, {result: indexs, total: total})

exports.newList = (params, done)->
	query = {}
	if params.id
		query.id = params.id
	if params.user
		query.user = params.user

	sortCond = {}
	if params.sortBy not in ['index']
		params.sortBy = 'index'
	if params.orderBy not in ['ASC', 'DESC']
		params.orderBy = 'DESC'
	sortCond[params.sortBy] = params.orderBy

	UserIndexCache.find query
	.sort(sortCond)
	.exec (err, indexs)->
		if err
			return done({code: 1000, error: "[UserIndexService.newList] ERROR: Could not get User Index Cache list... #{err}"})
		return done(null, indexs)
				