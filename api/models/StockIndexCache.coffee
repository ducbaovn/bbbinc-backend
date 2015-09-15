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

    toJSON: ()->
      obj = this.toObject()
      delete obj.id
      delete obj.createdAt
      delete obj.updatedAt
      
      obj

    