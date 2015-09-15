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

    toJSON: ()->
      obj = this.toObject()
      delete obj.id
      delete obj.createdAt
      delete obj.updatedAt
      
      obj