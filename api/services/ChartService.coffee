moment = require('moment')

exports.indexLine = (params, done)->
	params.sortBy = 'date'
	params.orderBy = 'ASC'
	params.limit = -1
	params.dayOfWeek = {'!': [0, 6]}
	UserIndexService.list params, (err, userIndexs)->
		if err
			return done(err)
		if userIndexs.total > 0
			data = {date: _.map(userIndexs.result, (n)-> moment(n.date).format('DD-MM-YY')), userIndex: _.pluck(userIndexs.result, 'index')}
				
			params.fromDate = userIndexs.result[0].date
			params.toDate = _.last(userIndexs.result).date
			params.group = 'VN'
		
			StockIndexService.list params, (err, vnIndexs)->
				if err
					return done(err)
				data.vnIndex = _.pluck(vnIndexs.result, 'index')
				rootVnIndex = data.vnIndex[0]
				data.vnIndex = _.map(data.vnIndex, (n)->n/rootVnIndex*100)
				params.group = 'VN30'
				
				StockIndexService.list params, (err, vn30Indexs)->
					if err
						return done(err)
					data.vn30Index = _.pluck(vn30Indexs.result, 'index')
					roỏtVn0Index = data.vn30Index[0]
					data.vn30Index = _.map(data.vn30Index, (n)->n/roỏtVn0Index*100)

					return done(null, data)