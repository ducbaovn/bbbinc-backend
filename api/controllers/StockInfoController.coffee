async = require('async')

module.exports =
  
  list: (req, res)->
    # res.header("Access-Control-Allow-Credentials", true)
    # res.header("Access-Control-Allow-Origin", "*")
    params = req.allParams()
    StockInfoService.list params, (err, list)->
      if err
        sails.log.info err.error
        return res.badRequest(err)
      sails.log.info '[StockInfoController.list] SUCCESS: Send list stockinfo'
      return res.send list

  newList: (req, res)->
    # res.header("Access-Control-Allow-Credentials", true)
    # res.header("Access-Control-Allow-Origin", "*")
    params = req.allParams()
    StockInfoService.newList params, (err, list)->
      if err
        sails.log.info err.error
        return res.badRequest(err)
      sails.log.info '[StockInfoController.list] SUCCESS: Send list stockinfo'
      return res.send list