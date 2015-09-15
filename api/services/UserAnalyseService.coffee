exports.info = (params, done)->
	UserPropertyService.annualReturn params, (err, property)->
		if err
			return done(err, null)
		StockUserService.newList user: params.user, (err, stockUsers)->
			if err
				return done(err, null)
			result = []
			async.each stockUsers, (stockUser, cb)->
				StockAnalyse.findOne
					stock: stockUser.stock.id
					quarter: params.quarter
					year: params.year
				, (err, stockAnalyse)->
					if err
						return cb({code: 1000, error: 'Could not process StockAnalyse', log: "[UserAnalyseService.info] ERROR: Could not process StockAnalyse... #{err}"})
					if !stockAnalyse
						return cb({code: 1009, error: "StockAnalyse does not exist", log: "[UserPropertyService.annualReturn] ERROR: StockAnalyse #{stockUser.stock.id} does not exist"})
					stockAnalyse.percent = (stockUser.qty * stockUser.stock.price)/property.stockAsset					
					result.push stockAnalyse
					return cb()
			, (err)->
				if err
					return done(err)
				info =
					userAsset: property.userAsset
					annualReturn: property.annualReturn
					pe: 0
					pb: 0
					roa: 0
					roe: 0
				info.pe += stock.pe * stock.percent for stock in result
				info.pb += stock.pb * stock.percent for stock in result
				info.roa += stock.roa * stock.percent for stock in result
				info.roe += stock.roe * stock.percent for stock in result
				return done(null, info)