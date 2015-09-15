async = require('async')
moment = require('moment')
ObjectId = require('mongodb').ObjectID

exports.autoUpdate = (done)->
	UserPropertyCache.find {}
	.exec (err, usersProperty)->
		if err
			return done("[UserPropertyService.autoUpdate] ERROR: Could not get today UserProperty... #{err}")
		if usersProperty[0]?
			async.each usersProperty, (userProperty, cb)->
				StockUserCache.find {user: userProperty.user}, (err, stocksUser)->
					stockProperty = 0
					stockProperty += stockUser.total for stockUser in stocksUser
					userProperty.stock = stockProperty
					userProperty.total = userProperty.stock + userProperty.cash
					userProperty.profit = userProperty.stock + userProperty.cash - userProperty.capital
					userProperty.percent = (userProperty.stock + userProperty.cash)/userProperty.capital*100
					userProperty.save (err)->
					if err
						return cb("[UserPropertyService.autoUpdate] ERROR: Could not update UserProperty... #{err}")
					return cb()
			, (err)->
				if err
					return done(err)
				return done(null)
		else 
			UserProperty.native (err, collection)->
				if err
					return done("[UserPropertyService.autoUpdate] ERROR: Could not native UserProperty... #{err}")
				collection.aggregate
					$group:
						_id: ''
						max:
							$max: '$date'
				, (err, result)->
					if err
						return done("[UserPropertyService.autoUpdate] ERROR: Could not get last date in UserProperty... #{err}")
					if result[0]
						UserProperty.find date: result[0].max, (err, lastProperty)->
							if err
								return done("[UserPropertyService.autoUpdate] ERROR: Could not get last UserProperty... #{err}")
							for property in lastProperty
								delete property.id
								delete property.date
							UserPropertyCache.create lastProperty, (err, todayProperty)->
								if err
									return done("[UserPropertyService.autoUpdate] ERROR: Could not create UserProperty... #{err}")
								return done(null, result[0].max)


	# UserProperty.find {date: moment().format('YYYY-MM-DD')}
	# .exec (err, usersProperty)->
	# 	if err
	# 		return done("[UserPropertyService.autoUpdate] ERROR: Could not get today UserProperty... #{err}")
	# 	if usersProperty[0]?
	# 		async.each usersProperty, (userProperty, cb)->
	# 			StockUser.find {user: userProperty.user, date: moment().format('YYYY-MM-DD')}, (err, stocksUser)->
	# 				stockProperty = 0
	# 				stockProperty += stockUser.total for stockUser in stocksUser
	# 				userProperty.stock = stockProperty
	# 				userProperty.total = userProperty.stock + userProperty.cash
	# 				userProperty.profit = userProperty.stock + userProperty.cash - userProperty.capital
	# 				userProperty.percent = (userProperty.stock + userProperty.cash)/userProperty.capital*100
	# 				userProperty.save (err)->
	# 				if err
	# 					return cb("[UserPropertyService.autoUpdate] ERROR: Could not update UserProperty... #{err}")
	# 				return cb()
	# 		, (err)->
	# 			if err
	# 				return done(err)
	# 			return done(null)
	# 	else 
	# 		UserProperty.native (err, collection)->
	# 			if err
	# 				return done("[UserPropertyService.autoUpdate] ERROR: Could not native UserProperty... #{err}")
	# 			collection.aggregate
	# 				$group:
	# 					_id: ''
	# 					max:
	# 						$max: '$date'
	# 			, (err, result)->
	# 				if err
	# 					return done("[UserPropertyService.autoUpdate] ERROR: Could not get last date in UserProperty... #{err}")
	# 				if result[0]
	# 					UserProperty.find date: result[0].max, (err, lastProperty)->
	# 						if err
	# 							return done("[UserPropertyService.autoUpdate] ERROR: Could not get last UserProperty... #{err}")
	# 						for property in lastProperty
	# 							delete property.id
	# 							delete property.date
	# 						UserProperty.create lastProperty, (err, todayProperty)->
	# 							if err
	# 								return done("[UserPropertyService.autoUpdate] ERROR: Could not create UserProperty... #{err}")
	# 							return done(null, result[0].max)

exports.createDaily = (done)->
	UserPropertyCache.find {}, (err, userProperty)->
		if err
			return done("[UserPropertyService.createDaily] ERROR: Could not get UserProperty Cache... #{err}")
		if userProperty[0]?
			for obj in userProperty
				delete obj.id
			UserProperty.create userProperty, (err, todayProperty)->
				if err
					return done("[UserPropertyService.createDaily] ERROR: Could not create today UserProperty... #{err}")
				return done(null)
		else
			return done("[UserPropertyService.createDaily] ERROR: Could not find UserProperty Cache")

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
	params.page = parseInt(params.page) || 1
	params.limit = parseInt(params.limit) || 30
	if params.limit > 0
		query.limit = params.limit
		query.skip = (params.page-1)*params.limit
	sortCond = {}
	if params.sortBy not in ['date']
		params.sortBy = 'date'
	if params.sortOrder not in ['ASC', 'DESC']
		params.sortOrder = 'ASC'
	sortCond[params.sortBy] = params.sortOrder

	UserProperty.find query
	.sort(sortCond)
	.exec (err, properties)->
		if err
			return done({code: 1000, error: "Could not get UserProperty list", log: "[UserPropertyService.list] ERROR: Could not get UserProperty list... #{err}"})
		UserProperty.count query, (err, total)->
			if err
				return done({code: 1000, error: "Could not count UserProperty list", log: "[UserPropertyService.list] ERROR: Could not count UserProperty list... #{err}"})
			return done(null, {result: properties, total: total})

exports.newList = (params, done)->
	query = {}
	if params.id
		query.id = params.id
	if params.user
		query.user = params.user
	sortCond = {}
	if params.sortBy not in ['total']
		params.sortBy = 'total'
	if params.sortOrder not in ['ASC', 'DESC']
		params.sortOrder = 'DESC'
	sortCond[params.sortBy] = params.sortOrder

	UserPropertyCache.find query
	.populate('user')
	.sort(sortCond)
	.exec (err, properties)->
		if err
			return done({code: 1000, error: "Could not get UserProperty list", log: "[UserPropertyService.newList] ERROR: Could not get UserPropertyCache list... #{err}"})
		return done(null, properties)

exports.yearlyChart = (params, done)->
	result = {}
	UserProperty.native (err, collection)->
		if err
			return done("[UserPropertyService.autoUpdate] ERROR: Could not native UserProperty... #{err}")
		collection.aggregate [
			$match:
				user: ObjectId(params.user)
		,
			$group:
				_id:
					$month: '$date'
				date:
					$min: '$date'
		,
			$sort:
				_id: 1
		], (err, months)->
			if err
				return done({code: 1000, error: 'Could not native UserProperty', log: "[UserPropertyService.yearlyChart] ERROR: Could not native UserProperty... #{err}"})
			result.months = _.pluck(months, '_id')
			params.dates = _.pluck(months, 'date')
			UserPropertyService.list params, (err, properties)->
				if err
					return done({code: 1000, error: 'Could not list UserProperty', log: "[UserPropertyService.yearlyChart] ERROR: Could not list UserProperty... #{err}"})
				result.total = _.pluck(properties.result, 'total')
				result.capital = _.pluck(properties.result, 'capital')
				return done(null, result)

exports.annualReturn = (params, done)->
	if !params.year || !params.user
		return done({code: 1007, error: "Missing params", log: "[UserPropertyService.annualReturn] ERROR: Missing params"})
	UserProperty.native (err, collection)->
		if err
			return done({code: 1000, error: "Could not native", log: "[UserPropertyService.annualReturn] ERROR: Could not native UserProperty"})
		collection.aggregate [
			$match:
				user: ObjectId(params.user)
		,
			$group:
				_id: 
					$year: '$date'
				date:
					$min: '$date'
		], (err, result)->
			if err
				return done({code: 1000, error: "Could not get min date", log: "[UserPropertyService.annualReturn] ERROR: Could not get min date"})
			UserProperty.findOne
				user: params.user
				date: result[0].date
			, (err, firstProperty)->
				if err
					return done({code: 1000, error: "Could not get min date UserProperty", log: "[UserPropertyService.annualReturn] ERROR: Could not get min date UserProperty"})
				UserPropertyCache.findOne user: params.user, (err, lastProperty)->
					if err
						return done({code: 1000, error: "Could not get lastProperty", log: "[UserPropertyService.annualReturn] ERROR: Could not get lastProperty"})
					if !lastProperty
						return done({code: 1008, error: "UserPropertyCache does not exist", log: "[UserPropertyService.annualReturn] ERROR: UserPropertyCache #{params.user} does not exist"})
					return done(null, {userAsset: lastProperty.total, stockAsset: lastProperty.stock, annualReturn: (lastProperty.profit - firstProperty.profit)})