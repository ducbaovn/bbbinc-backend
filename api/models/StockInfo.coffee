moment = require('moment')

module.exports =
	schema: true
	autoCreatedAt: true
	autoUpdatedAt: true
	attributes:
		stock:
			model: 'Stock'
			required: true

		open:
			type: 'string'
			required: true

		ceiling:
			type: 'string'

		floor:
			type: 'string'

		bid3:
			type: 'string'

		bid3Vol:
			type: 'string'

		bid2:
			type: 'string'

		bid2Vol:
			type: 'string'

		bid1:
			type: 'string'

		bid1Vol:
			type: 'string'

		deal:
			type: 'string'
			required: true

		dealVol: 
			type: 'string'

		change:
			type: 'string'
			required: true

		offer1:
			type: 'string'

		offer1Vol:
			type: 'string'

		offer2:
			type: 'string'

		offer2Vol:
			type: 'string'

		offer3:
			type: 'string'

		offer3Vol:
			type: 'string'

		date:
			type: 'date'
			defaultsTo: moment().format('YYYY-MM-DD')
			
		dayOfWeek:
			type: 'integer'
			defaultsTo: new Date().getDay()
