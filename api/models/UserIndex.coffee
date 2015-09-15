moment = require('moment')

module.exports =
	schema: true
	attributes:
		user:
			model: 'user'
			required: true

		index:
			type: 'float'
			required: true

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
