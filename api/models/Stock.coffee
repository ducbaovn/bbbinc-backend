module.exports =
	schema: true
	attributes:
		code:
			type: 'string'
			unique: true
			required: true
		
		name:
			type: 'string'
		
		market:
			type: 'string'
			enum: _.values(['HCM', 'HN'])
			defaultsTo: 'HCM'

		price:
			type: 'float'
			defaultsTo: 0

		toJSON: ()->
			obj = this.toObject()
			delete obj.createdAt
			delete obj.updatedAt
			obj