moment = require('moment')

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  attributes:
    stock:
      model: 'Stock'
      required: true

    eps:
      type: 'float'
      required: true

    pe:
      type: 'float'
      required: true

    roe:
      type: 'float'
      required: true

    roa:
      type: 'float'
      required: true

    pb:
      type: 'float'
      required: true

    quantity:
      type: 'integer'
      required: true

    capital:
      type: 'float'
      required: true

    quarter:
      type: 'integer'
      defaultsTo: Math.floor(new Date().getMonth()/3) + 1

    year:
      type: 'integer'
      defaultsTo: new Date().getFullYear()