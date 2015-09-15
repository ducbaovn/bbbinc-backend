moment = require('moment')

REASON =
	BUY: 'BUY'
	SELL: 'SELL'
	DEPOSIT: 'DEPOSIT'
	CASH: 'CASH'
	PAYOUT: 'PAYOUT'

module.exports =
	schema: true
	REASON: REASON
	attributes:
		date:
			type: 'date'
			defaultsTo: moment().format('YYYY-MM-DD')

		user:
			model: 'User'
			via: 'history'
			required: true
		
		stock:
			model: 'Stock'
		
		qty:
			type: 'integer'

		price:
			type: 'float'

		cash:
			type: 'integer'

		commission:
			type: 'integer'
		
		tax:
			type: 'integer'
				
		reason:
			type: 'string'
			enum: _.values(REASON)