request = require('request')

module.exports =
  getHSC: ()->
    # hd1 = new memwatch.HeapDiff()
    DataService.reqData (err, reqData)->
      if err
        return sails.log.info err
      DataService.getStockData reqData, (err, data)->
        if err
          return sails.log.info err
        StockIndexService.autoUpdate data.index, (err)->
          if err
            return sails.log.info err
          StockInfoService.autoUpdate data.stock, (err)->
            if err
              return sails.log.info err
            StockUserService.autoUpdate (err)->
              if err
                return sails.log.info err
              UserPropertyService.autoUpdate (err, lastDay)->
                if err
                  return sails.log.info err
                UserIndexService.autoUpdate (err)->
                  if err
                    sails.log.info err
                  return console.log '=====================END================================='

                # diff1 = hd1.end()
                # console.log("ALL MEMORY: #{JSON.stringify(diff1)}")
  createPerDay: ()->
    StockIndexService.createDaily (err)->
      if err
        return sails.log.info err
      StockInfoService.createDaily (err)->
        if err
          return sails.log.info err
        StockUserService.createDaily (err)->
          if err
            return sails.log.info err
          UserPropertyService.createDaily (err)->
            if err
              return sails.log.info err
            UserIndexService.createDaily (err)->
              if err
                return sails.log.info err