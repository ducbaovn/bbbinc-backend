exports.changeList = (req, res)->
  params = req.allParams()
  User.findOne nickname: 'bbbfund', (err, bbbfund)->
    if err
      sails.log.info "[bbbfund/StockController.changeList] ERROR: Could not find user bbbfund... #{err}"
      return res.badRequest {code: 1000, error: "Could not process"}
    params.user = bbbfund.id
    StockUserService.newList params, (err, bbbStocks)->
      if err
        sails.log.info err.log
        return res.badRequest {code: err.code, error: err.error}
      params.stock = _.pluck(_.pluck(bbbStocks, 'stock'), 'id')
      StockInfoService.changeList params, (err, changeList)->
        if err
          sails.log.info err.log
          return res.badRequest {code: err.code, error: err.error}
        return res.send changeList

exports.newList = (req, res)->
  params = req.allParams()
  User.findOne nickname: 'bbbfund', (err, bbbfund)->
    if err
      sails.log.info "[bbbfund/StockController.newList] ERROR: Could not find user bbbfund... #{err}"
      return res.badRequest {code: 1000, error: "Could not process"}
    params.user = bbbfund.id
    StockUserService.newList params, (err, bbbStocks)->
      if err
        sails.log.info err.log
        return res.badRequest {code: err.code, error: err.error}
      return res.send bbbStocks

exports.list = (req, res)->
  params = req.allParams()
  User.findOne nickname: 'bbbfund', (err, bbbfund)->
    if err
      sails.log.info "[bbbfund/StockController.list] ERROR: Could not find user bbbfund... #{err}"
      return res.badRequest {code: 1000, error: "Could not process"}
    params.user = bbbfund.id
    StockUserService.list params, (err, bbbStocks)->
      if err
        sails.log.info err.log
        return res.badRequest {code: err.code, error: err.error}
      return res.send bbbStocks

exports.analyse = (req, res)->
  params = req.allParams()
  User.findOne nickname: 'bbbfund', (err, bbbfund)->
    if err
      sails.log.info "[bbbfund/StockController.analyse] ERROR: Could not find user bbbfund... #{err}"
      return res.badRequest {code: 1000, error: "Could not process"}
    params.user = bbbfund.id
    UserAnalyseService.info params, (err, userAnalyse)->
      if err
        sails.log.info err.log
        return res.badRequest {code: err.code, error: err.error}
      return res.send userAnalyse