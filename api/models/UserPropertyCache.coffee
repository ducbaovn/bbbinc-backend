moment = require('moment')

module.exports =
  schema: true
  attributes:
    user:
      model: 'User'
      via: 'property'
      required: true
    
    stock:
      type: 'integer'
      required: true
    
    cash:
      type: 'integer'
      required: true

    total:
      type: 'integer'

    capital:
      type: 'integer'
      required: true

    commission:
      type: 'integer'

    tax:
      type: 'integer'
    
    profit:
      type: 'integer'

    percent:
      type: 'float'

    toJSON: ()->
      obj = this.toObject()
      delete obj.id
      delete obj.createdAt
      delete obj.updatedAt
      
      obj