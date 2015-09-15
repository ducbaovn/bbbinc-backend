async = require('async')
moment = require('moment')

module.exports =
  
  loginpage: (req, res)->
    # res.header("Access-Control-Allow-Origin", "*")
    res.view()

  register: (req, res)->
    # res.header("Access-Control-Allow-Credentials", true)
    # res.header("Access-Control-Allow-Origin", "*")
    params = req.allParams()
    AuthService.register req, res

  login: (req, res)->
    # res.header("Access-Control-Allow-Credentials", true)
    # res.header("Access-Control-Allow-Origin", "*")
    params = req.allParams()
    AuthService.login req, res

  facebook: (req, res)->
    # res.header("Access-Control-Allow-Credentials", true)
    # res.header("Access-Control-Allow-Origin", "*")
    params = req.allParams
    AuthService.facebook req, res

  fbcallback: (req, res)->
    # res.header("Access-Control-Allow-Credentials", true)
    # res.header("Access-Control-Allow-Origin", "*")
    params = req.allParams
    AuthService.fbcallback req, res

  google: (req, res)->
    # res.header("Access-Control-Allow-Credentials", true)
    # res.header("Access-Control-Allow-Origin", "*")
    params = req.allParams
    AuthService.google req, res

  ggcallback: (req, res)->
    # res.header("Access-Control-Allow-Credentials", true)
    # res.header("Access-Control-Allow-Origin", "*")
    params = req.allParams
    AuthService.ggcallback req, res
  
  logout: (req, res)->
    # res.header("Access-Control-Allow-Credentials", true)
    # res.header("Access-Control-Allow-Origin", "*")

  test: (req, res)->
    UserHistory.find {}, (err, history)->
        res.send history
    # UserProperty.native (err, collection)->
    #   if err
    #     return console.log("[StockUserService.autoUpdate] ERROR: Could not native StockUser... #{err}")
    #   collection.find
    #     $where: 'this.profit != this.total - this.capital'
    #   .toArray (err, result)->
    #     if err
    #       return console.log("[StockUserService.autoUpdate] ERROR: Could not get last date in StockUser... #{err}")
    #     console.log result
        # async.each result, (stock, cb)->
        #   stock.profit = Math.round(stock.total + stock.payout - this.totalBuy)
        #   collection.save stock, (err, ok)->
        #     if err
        #       return cb(err)
        #     return cb()
        # , (err)->
        #   if err
        #     console.log 'err:'+err
        #   console.log 'ok'
    
    # properties = [[8935,357950,330040,40944,2531,'2015-07-31'],[8935,357950,330040,36845,2531,'2015-08-01'],[8935,357950,330040,36845,2531,'2015-08-02']]
    # User.create
    #   local:
    #     username: 'bbbfund'
    #     password: 'khongcopass'
    #   nickname: 'babua'
    # , (err, bbb)->
    #   if err
    #     return console.log('err1:'+err)
    #   console.log('done1')
    # indexData = []
    # indexData.push({group: index[0], index: index[2], date: index[1], dayOfWeek: new Date(index[1]).getDay()}) for index in vnIndex
    # indexData.push({user: "55b65e79bff543e427cce2be", index: index[2], date: index[1], dayOfWeek: new Date(index[1]).getDay()}) for index in bbbIndex  
    # StockIndex.create indexData, (err, ok)->
    #     if err
    #       return console.log('err2:'+err)
    #     console.log('done2')
    # stockData = []
    # async.each stocks, (stock, cb)->
    #   Stock.findOne code: stock[0], (err, found)->
    #     if err
    #       return cb(err)
    #     stockData.push
    #       user: "55b65e79bff543e427cce2be"
    #       stock: found.id
    #       qty: stock[2]
    #       avgPrice: stock[3]
    #       price: stock[4]
    #       total: stock[2]*stock[4]
    #       totalBuy: stock[2]*stock[3]
    #       profit: stock[2]*(stock[4]-stock[3])
    #       date: stock[5]
    #       dayOfWeek: new Date(stock[5]).getDay()
    #     return cb()
    # , (err)->
    #   if err
    #     return console.log('err3:'+err)
    #   console.log('done3')
    #   StockUser.create stockData, (err, ok)->
    #     if err
    #       return console.log('err4:'+err)
    #     console.log('done4')
    # propertyData = []
    # propertyData.push {user: "55b65e79bff543e427cce2be", stock: property[1], cash: property[0], total: property[0]+property[1], capital: property[2], commission: property[4], profit: property[3], percent: (property[0]+property[1])/property[2]*100, date: property[5], dayOfWeek: new Date(property[5]).getDay()} for property in properties
    # UserProperty.create propertyData, (err, ok)->
    #   if err
    #     return console.log('err5:'+err)
    #   console.log('done5')

    # StockInfo.native (err, collection)->
    #     if err
    #         return res.send("[StockUserService.autoUpdate] ERROR: Could not native StockUser... #{err}")
    #     collection.aggregate
    #         $group:
    #             _id: ''
    #             max:
    #                 $max: '$date'
    #     , (err, result)->
    #         if err
    #             return res.send("[StockUserService.autoUpdate] ERROR: Could not get last date in StockUser... #{err}")
    #         if result[0]
                # return res.send(result[0].max)