exports.stock = (req, res)->
  params = req.allParams()
  params.user = req.user.id
  console.log typeof params.exchange
  ExchangeService.stock params, (err, success)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send success

exports.payout = (req, res)->
  params = req.allParams()
  params.user = req.user.id
  ExchangeService.payout params, (err, success)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send success

exports.cash = (req, res)->
  params = req.allParams()
  params.user = req.user.id
  ExchangeService.cash params, (err, success)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send success

exports.create = (req, res)->
  params = req.allParams()
  params.user = req.user.id
  ExchangeService.create params, (err, success)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send success
