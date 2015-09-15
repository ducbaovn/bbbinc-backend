exports.buy = (req, res)->
  # res.header("Access-Control-Allow-Origin", "*")
  params = req.allParams()
  User.findOne nickname: 'bbbfund', (err, bbbfund)->
    if err
      sails.log.info "[bbbfund/StockController.changeList] ERROR: Could not find user bbbfund... #{err}"
      return res.badRequest {code: 1000, error: "Could not process"}
    params.user = bbbfund.id
    ExchangeService.buy params, (err, success)->
      if err
        sails.log.info err.log
        return res.badRequest {code: err.code, error: err.error}
      return res.send success

# exports.sell = (req, res)->
#   res.header("Access-Control-Allow-Origin", "*")
#   params = req.allParams()
#   User.findOne nickname: 'bbbfund', (err, bbbfund)->
#     if err
#       sails.log.info "[bbbfund/StockController.newList] ERROR: Could not find user bbbfund... #{err}"
#       return res.badRequest {code: 1000, error: "Could not process"}
#     params.user = bbbfund.id

#       if err
#         sails.log.info err.log
#         return res.badRequest {code: err.code, error: err.error}
#       return res.send bbbStocks

# exports.payout = (req, res)->
#   res.header("Access-Control-Allow-Origin", "*")
#   params = req.allParams()
#   User.findOne nickname: 'bbbfund', (err, bbbfund)->
#     if err
#       sails.log.info "[bbbfund/StockController.list] ERROR: Could not find user bbbfund... #{err}"
#       return res.badRequest {code: 1000, error: "Could not process"}
#     params.user = bbbfund.id
    
#       if err
#         sails.log.info err.log
#         return res.badRequest {code: err.code, error: err.error}
#       return res.send bbbStocks

# exports.deposit = (req, res)->
#   res.header("Access-Control-Allow-Origin", "*")
#   params = req.allParams()
#   User.findOne nickname: 'bbbfund', (err, bbbfund)->
#     if err
#       sails.log.info "[bbbfund/StockController.analyse] ERROR: Could not find user bbbfund... #{err}"
#       return res.badRequest {code: 1000, error: "Could not process"}
#     params.user = bbbfund.id
    
#       if err
#         sails.log.info err.log
#         return res.badRequest {code: err.code, error: err.error}
#       return res.send userAnalyse

# exports.cash = (req, res)->
#   res.header("Access-Control-Allow-Origin", "*")
#   params = req.allParams()
#   User.findOne nickname: 'bbbfund', (err, bbbfund)->
#     if err
#       sails.log.info "[bbbfund/StockController.analyse] ERROR: Could not find user bbbfund... #{err}"
#       return res.badRequest {code: 1000, error: "Could not process"}
#     params.user = bbbfund.id
    
#       if err
#         sails.log.info err.log
#         return res.badRequest {code: err.code, error: err.error}
#       return res.send userAnalyse