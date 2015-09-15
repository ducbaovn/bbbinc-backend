moment = require('moment')

module.exports =
  schema: true
  attributes:
    user:
      model: 'User'
      via: 'stocksUser'
      required: true
    
    stock:
      model: 'Stock'
      required: true
    
    qty:
      type: 'integer'
      required: true

    avgPrice:
      type: 'float'
      required: true
    
    price:
      type: 'float'
        
    payout:
      type: 'integer'
      defaultsTo: 0

    total:
      type: 'integer'

    totalBuy:
      type: 'integer'
    
    profit:
      type: 'integer'

    toJSON: ()->
      obj = this.toObject()
      delete obj.id
      delete obj.createdAt
      delete obj.updatedAt
      
      obj