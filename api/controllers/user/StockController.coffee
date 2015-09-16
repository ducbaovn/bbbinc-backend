exports.changeList = (req, res)->
  params = req.allParams()
  params.user = req.user.id
  StockUserService.newList params, (err, userStocks)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    params.stock = _.pluck(_.pluck(userStocks, 'stock'), 'id')
    StockInfoService.changeList params, (err, changeList)->
      if err
        sails.log.info err.log
        return res.badRequest {code: err.code, error: err.error}
      return res.send changeList

exports.newList = (req, res)->
  params = req.allParams()
  params.user = req.user.id
  StockUserService.newList params, (err, userStocks)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send userStocks

exports.list = (req, res)->
  params = req.allParams()
  params.user = req.user.id
  StockUserService.list params, (err, userStocks)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send bbbStocks

exports.analyse = (req, res)->
  params = req.allParams()
  params.user = req.user.id
  UserAnalyseService.info params, (err, userAnalyse)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send userAnalyse