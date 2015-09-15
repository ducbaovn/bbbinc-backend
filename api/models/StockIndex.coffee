moment = require('moment')

module.exports =
	schema: true
	attributes:
		group:
			type: 'string'
			enum: _.values(['VN', 'VN30'])

		index:
			type: 'float'

		change:
			type: 'float'

		percentChange:
			type: 'float'
		
		date:
			type: 'date'
			defaultsTo: moment().format('YYYY-MM-DD')

		dayOfWeek:
			type: 'integer'
			defaultsTo: new Date().getDay()
