moment = require('moment')
ObjectId = require('mongodb').ObjectID
async = require('async')

exports.create = (params, done)->
  if !params.user || !params.stockList
    return done({code: 1010, error: 'Missing params', log: "[ExchangeService.create] ERROR: Missing params"})
  if typeof(params.stockList) != 'object'
    try
      params.stockList = JSON.parse(params.stockList)
    catch err
      if err
        return done({code: 1011, error: 'Could not JSON.parse stockList', log: "[ExchangeService.create] ERROR: Could not JSON.parse stockList... #{err}"})
  try
    params.cash = parseInt(params.cash)
  catch err
    if err
      return done({code: 1011, error: 'Could not parse Number', log: "[ExchangeService.create] ERROR: Could not parse Number... #{err}"}) 
  
  stockCapital = 0
  for stock in params.stockList
    try
      stock.qty = parseInt(stock.qty)
      stock.price = parseFloat(stock.price)
      stock.total = parseInt(stock.total)
      stock.fee = parseInt(stock.fee)
    catch err
      if err
        return done({code: 1011, error: 'Could not parse Number', log: "[ExchangeService.create] ERROR: Could not parse Number... #{err}"})
    stock.cash = -(stock.qty*stock.price + stock.fee)
    stockCapital -= stock.cash
    stock.reason = UserHistory.REASON.BUY
    stock.commission = stock.fee
    stock.user = params.user
  async.waterfall [
    # codeToId
    (cb)->
      console.log('1111111111111111111111111111111111')
      async.each params.stockList, (stock, cb1)->
        Stock.findOne code: stock.code, (err, holding)->
          if err
            return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.create] ERROR: Could not process - get Stock... #{err}"})
          if holding?
            stock.stock = holding.id
            stock.currentPrice = holding.price
            return cb1()
          return cb1({code: 1012, error: "Invalid Stock code: #{stock.stock}", log: "[ExchangeService.create] ERROR: Invalid Stock Code"})
      , (err, ok)->
        if err
          return cb(err)
        return cb(null)

    # history
    (cb)->
      console.log('222222222222222222222222222222222222222222')
      UserHistory.create params.stockList, (err, userHistory)->
        if err
          return cb({code: 1000, error: "Could not process", log: "[ExchangeService.create] ERROR: Could not create Exchange UserHistory...#{err}"})
        UserHistory.create
          user: params.user
          cash: params.cash + stockCapital
          reason: UserHistory.REASON.DEPOSIT
        , (err, ok)->
          if err
            return cb({code: 1000, error: "Could not process", log: "[ExchangeService.create] ERROR: Could not create Cash UserHistory...#{err}"})
          return cb(null)

    # stock
    (cb)->
      console.log('3333333333333333333333333333333333333333');
      async.each params.stockList, (exc, cb1)->
        StockUserCache.create
          user: params.user
          stock: exc.stock
          qty: exc.qty
          avgPrice: exc.price
          price: exc.currentPrice
          payout: 0
          total: exc.qty * exc.currentPrice
          totalBuy: exc.total
          profit: 0
        , (err, success)->
          if err
            return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - create StockUserCache... #{err}"})
          return cb1()
      , (err)->
        if err
          return cb(err)
        return cb(null)

    # userProperty
    (cb)->
      console.log('444444444444444444444444444444444444444444');
      StockUserCache.find user: params.user, (err, stocks)->
        if err
          return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - get StockUserCache... #{err}"})
        totalStock = 0
        totalStock += stock.total for stock in stocks
        totalCash = 0
        totalFee = 0
        for exchange in params.stockList
          totalCash += exchange.qty * exchange.price
          totalFee += exchange.fee
        
        UserProperty.create
          user: params.user
          stock: 0
          cash: totalCash + totalFee + params.cash
          total: totalCash + totalFee + params.cash
          capital: totalCash + totalFee + params.cash
          commission: 0
          tax: 0
          profit: 0
          percent: 100
          date: moment().subtract(1, 'days').format('YYYY-MM-DD')
          dayOfWeek: moment().subtract(1, 'days').weekday()
        , (err, lastProperty)->
          if err
            return cb({code: 1000, error: 'Could not process',log: "[ExchangeService.buy] ERROR: Could not process - create UserProperty... #{err}"})
          UserPropertyCache.create
            user: params.user
            stock: totalStock
            cash: params.cash
            total: totalStock + params.cash
            capital: totalCash + totalFee + params.cash
            commission: totalFee
            tax: 0
            profit: totalStock - (totalCash + totalFee)
            percent: (totalStock+params.cash)/(totalCash+totalFee+params.cash)*100
          , (err, success)->
            if err
              return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - create UserPropertyCache... #{err}"})
            return cb(null, success)

    # UserIndex
    (todayProperty, cb)->
      console.log('55555555555555555555555555555555555555555555');
      UserIndex.create
        user: params.user
        index: 100
        change: 0
        percentChange: 0
        date: moment().subtract(1, 'days').format('YYYY-MM-DD')
        dayOfWeek: moment().subtract(1, 'days').weekday()
      , (err, lastIndex)->
        if err
          return cb({code: 1000, error: 'Could not process',log: "[ExchangeService.buy] ERROR: Could not process - create UserIndex... #{err}"})
      
        UserIndexCache.create
          user: params.user
          index: todayProperty.percent
          change: todayProperty.percent - 100
          percentChange: todayProperty.percent - 100
        , (err, success)->
          if err
            return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - create UserIndexCache... #{err}"})
          return cb(null)
  ], (err)->
    if err
      return done(err)
    return done(null, {success: 'Update Data success'})

exports.stock = (params, done)->
  if !params.user || !params.exchange
  	return done({code: 1010, error: 'Missing params', log: "[ExchangeService.stock] ERROR: Missing params"})
  if typeof(params.exchange) != 'object'
    try
      params.exchange = JSON.parse(params.exchange)
    catch err
      if err
        return done({code: 1011, error: 'Could not JSON.parse exchange', log: "[ExchangeService.stock] ERROR: Could not JSON.parse exchange... #{err}"})

  for ex in params.exchange
    try
      ex.qty = parseInt(ex.qty)
      ex.price = parseFloat(ex.price)
      ex.total = parseInt(ex.total)
      ex.fee = parseInt(ex.fee)
    catch err
      if err
        return done({code: 1011, error: 'Could not JSON.parse exchange', log: "[ExchangeService.stock] ERROR: Could not JSON.parse exchange... #{err}"})
    ex.reason = if ex.qty > 0 then UserHistory.REASON.BUY else UserHistory.REASON.SELL
    ex.cash = -(ex.qty*ex.price + ex.fee)
    ex.commission = ex.fee
    ex.user = params.user

  async.waterfall [
    # codeToId
    (cb)->
      console.log('1111111111111111111111111111111111')
      async.each params.exchange, (exchange, cb1)->
        Stock.findOne code: exchange.code, (err, stock)->
          if err
            return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.stock] ERROR: Could not process - get Stock... #{err}"})
          if stock?
            exchange.stock = stock.id
            exchange.currentPrice = stock.price
            exchange.market = stock.market
            return cb1()
          return cb1({code: 1012, error: "Invalid Stock code: #{exchange.stock}", log: "[ExchangeService.stock] ERROR: Invalid Stock Code"})
      , (err, ok)->
        if err
          return cb(err)
        return cb(null)

  	# history
    (cb)->
      console.log('222222222222222222222222222222222222222222')
      UserHistory.create params.exchange, (err, userHistory)->
        if err
          return cb({code: 1000, error: "Could not process", log: "[ExchangeService.stock] ERROR: Could not process - create UserHistory... #{err}"})
        return cb(null)

  	# stock
    (cb)->
      console.log('3333333333333333333333333333333333333333');
      async.eachSeries params.exchange, (exc, cb1)->
        StockUserCache.findOne
          user: params.user
          stock: exc.stock
        , (err, existStock)->
          if err
            return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process StockUser... #{err}"})
          if existStock?
            existStock.qty += exc.qty
            if exc.qty > 0
              existStock.avgPrice = (existStock.totalBuy + exc.total)/existStock.qty
            existStock.total = existStock.qty * existStock.price
            existStock.totalBuy = existStock.qty * existStock.avgPrice
            existStock.profit = existStock.total - existStock.totalBuy + existStock.payout
            existStock.save (err, ok)->
              if err
                return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - update StockUserCache... #{err}"})
              return cb1()
          else
            StockUserCache.create
              user: params.user
              stock: exc.stock
              qty: exc.qty
              avgPrice: exc.price
              price: exc.currentPrice
              payout: 0
              total: exc.qty * exc.currentPrice
              totalBuy: exc.total
              profit: 0
            , (err, success)->
              if err
                return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - create StockUserCache... #{err}"})
              return cb1()
      , (err)->
        if err
          return cb(err)
        return cb(null)

    # userProperty
    (cb)->
      console.log('444444444444444444444444444444444444444444');
      StockUserCache.find user: params.user, (err, stocks)->
        if err
          return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - get StockUserCache... #{err}"})
        totalStock = 0
        totalStock += stock.total for stock in stocks
        totalCash = 0
        totalFee = 0
        for exchange in params.exchange
          totalCash += exchange.qty * exchange.price
          totalFee += exchange.fee
        UserPropertyCache.findOne user: params.user, (err, property)->
          if err
            return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - get UserPropertyCache... #{err}"})
          if property?
            property.stock = totalStock
            property.cash -= (totalCash + totalFee)
            property.commission += totalFee
            property.total = property.stock + property.cash
            property.profit = property.total - property.capital
            property.percent = property.total/property.capital*100
            property.save (err, todayProperty)->
              if err
                return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - update UserPropertyCache... #{err}"})
              return cb(null, todayProperty)

    # UserIndex
    (todayProperty, cb)->
      console.log('55555555555555555555555555555555555555555555');
      UserIndexCache.findOne user: params.user, (err, index)->
        if err
          return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not process - get UserIndexCache... #{err}"})
        
        UserIndex.native (err, collection)->
          if err
            return cb({code: 1000, error: 'Could not process' , log: "[ExchangeService.buy] ERROR: Could not native UserIndex... #{err}"})
          collection.aggregate [
            $match:
              user: ObjectId(params.user)
          ,
            $group:
              _id: ''
              max:
                $max: '$date'
          ], (err, result)->
            if err
              return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.autoUpdate] ERROR: Could not get last date in StockUser... #{err}"})
            
            UserProperty.findOne {user: params.user, date: result[0].max}, (err, lastProperty)->
              if err
                return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not procees - get UserProperty... #{err}"})
              
              index.percentChange = (todayProperty.profit - lastProperty.profit)/(todayProperty.capital+lastProperty.profit)*100
              index.change = (index.index - index.change) * index.percentChange/100
              index.index = index.change/(index.percentChange/100) + index.change
              index.save (err)->
                if err
                  return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.buy] ERROR: Could not update UserIndex... #{err}"})
                return cb(null)
  ], (err)->
    if err
      return done(err)
    User.findOne id: params.user, (err, user)->
      if err
        return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.stock] ERROR: Could not process - get User... #{err}"})
      if user.nickname == "bbbfund"
        bbbfundDatas = []
        for element in params.exchange
          data = {}
          if element.qty > 0 then data.submit = "Mua" else data.submit = "Bán"
          data.maCP = element.code
          data.maSan = element.market
          if element.qty > 0 then data.soLuong = element.qty else data.soLuong = -element.qty
          data.gia = element.price
          bbbfundDatas.push data
        DataService.updatebbbfund(bbbfundDatas)
    return done(null, {success: 'Update Data success'})

exports.payout = (params, done)->
  if !params.user || !params.exchange
    return done({code: 1010, error: 'Missing params', log: "[ExchangeService.payout] ERROR: Missing params"})
  if typeof(params.exchange) != 'object'
    try
      params.exchange = JSON.parse(params.exchange)
    catch err
      if err
        return done({code: 1011, error: 'Could not JSON.parse exchange', log: "[ExchangeService.payout] ERROR: Could not JSON.parse exchange... #{err}"})
  for ex in params.exchange
    try
      ex.qty = parseInt(ex.qty)
      ex.price = parseFloat(ex.price)
      ex.total = parseInt(ex.total)
      ex.fee = parseInt(ex.fee)
    catch err
      if err
        return done({code: 1011, error: 'Could not JSON.parse exchange', log: "[ExchangeService.payout] ERROR: Could not JSON.parse exchange... #{err}"})
    ex.reason = UserHistory.REASON.PAYOUT
    ex.cash = ex.qty * ex.price
    ex.tax = ex.fee
    ex.user = params.user
  async.waterfall [
    # codeToId
    (cb)->
      console.log('1111111111111111111111111111111111')
      async.each params.exchange, (exchange, cb1)->
        Stock.findOne code: exchange.code, (err, stock)->
          if err
            return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - get Stock... #{err}"})
          if stock?
            exchange.stock = stock.id
            exchange.currentPrice = stock.price
            return cb1()
          return cb1({code: 1012, error: "Invalid Stock code: #{exchange.stock}", log: "[ExchangeService.payout] ERROR: Invalid Stock Code"})
      , (err, ok)->
        if err
          return cb(err)
        return cb(null)

    # history
    (cb)->
      console.log('222222222222222222222222222222222222222222')
      for ex in params.exchange
          ex.reason = UserHistory.REASON.PAYOUT
          ex.tax = ex.fee
          ex.user = params.user
      UserHistory.create params.exchange, (err, userHistory)->
        if err
          return cb({code: 1000, error: "Could not process", log: "[ExchangeService.payout] ERROR: Could not process - create UserHistory... #{err}"})
        return cb(null)

    # stock
    (cb)->
      console.log('3333333333333333333333333333333333333333');
      async.each params.exchange, (exc, cb1)->
        StockUserCache.findOne
          user: params.user
          stock: exc.stock
        , (err, existStock)->
          if err
            return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process StockUser... #{err}"})
          if !existStock
            return cb1({code: 1000, error: 'You do not own this stock', log: "[ExchangeService.payout] ERROR: You do not own this stock"})
          if exc.price == 0
            existStock.qty += exc.qty
            existStock.avgPrice = existStock.totalBuy/existStock.qty
            existStock.total = existStock.qty * existStock.price
            existStock.profit = existStock.total - existStock.totalBuy + existStock.payout
            existStock.save (err, ok)->
              if err
                return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - update StockUserCache... #{err}"})
              return cb1()
          else
            existStock.payout = exc.total
            existStock.save (err, ok)->
              if err
                return cb1({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - update StockUserCache... #{err}"})
              return cb1()
        # else
        #   UserPropertyCache.findOne user: params.user, (err, property)->
        #     if err
        #       return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - get UserPropertyCache... #{err}"})
        #     if property?
        #       property.cash += params.cash
        #       property.total = property.stock + property.cash
        #       property.capital += params.cash
        #       property.profit = property.total - property.capital
        #       property.percent = property.total/property.capital*100
        #       property.save (err, todayProperty)->
        #         if err
        #           return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - update UserPropertyCache... #{err}"})
        #         return cb(null, todayProperty)  
        # return cb1()
      , (err)->
        if err
          return cb(err)
        return cb(null)

    # userProperty
    (cb)->
      console.log('444444444444444444444444444444444444444444');
      StockUserCache.find user: params.user, (err, stocks)->
        if err
          return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - get StockUserCache... #{err}"})
        totalStock = 0
        totalStock += stock.total for stock in stocks
        totalPayout = 0
        totalFee = 0
        for exchange in params.exchange
          totalPayout += exchange.qty * exchange.price
          totalFee += exchange.fee
        UserPropertyCache.findOne user: params.user, (err, property)->
          if err
            return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - get UserPropertyCache... #{err}"})
          if property?
            property.stock = totalStock
            property.cash += (totalPayout - totalFee)
            property.tax += totalFee
            property.total = property.stock + property.cash
            property.profit = property.total - property.capital
            property.percent = property.total/property.capital*100
            property.save (err, todayProperty)->
              if err
                return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - update UserPropertyCache... #{err}"})
              return cb(null, todayProperty)

    # UserIndex
    (todayProperty, cb)->
      console.log('55555555555555555555555555555555555555555555');
      UserIndexCache.findOne user: params.user, (err, index)->
        if err
          return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - get UserIndexCache... #{err}"})
        
        UserIndex.native (err, collection)->
          if err
            return cb({code: 1000, error: 'Could not process' , log: "[ExchangeService.payout] ERROR: Could not native UserIndex... #{err}"})
          collection.aggregate [
            $match:
              user: ObjectId(params.user)
          ,
            $group:
              _id: ''
              max:
                $max: '$date'
          ], (err, result)->
            if err
              return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not get last date in StockUser... #{err}"})
            
            UserProperty.findOne {user: params.user, date: result[0].max}, (err, lastProperty)->
              if err
                return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not procees - get UserProperty... #{err}"})
              
              index.percentChange = (todayProperty.profit - lastProperty.profit)/(todayProperty.capital+lastProperty.profit)*100
              index.change = (index.index - index.change) * index.percentChange/100
              index.index = index.change/(index.percentChange/100) + index.change
              index.save (err)->
                if err
                  return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not update UserIndex... #{err}"})
                return cb(null)
  ], (err)->
    if err
      return done(err)
    User.findOne id: params.user, (err, user)->
      if err
        return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.stock] ERROR: Could not process - get User... #{err}"})
      if user.nickname == "bbbfund"
        bbbfundDatas = []
        for element in params.exchange
          data = {}
          if element.price == 0
            data.submit = "Mua"
            data.maCP = element.code
            data.soLuong = element.qty
            data.gia = 0
          else
            data.submit = "Nhận"
            data.tienMat = element.total - element.fee
          bbbfundDatas.push data
        DataService.updatebbbfund(bbbfundDatas)
    return done(null, {success: 'Update Data success'})

exports.cash = (params, done)->
  if !params.user || !params.cash
    return done({code: 1010, error: 'Missing params', log: "[ExchangeService.cash] ERROR: Missing params"})
  try
    params.cash = parseInt(params.cash)
  catch err
    if err
      return done({code: 1011, error: 'Could not parseInt cash', log: "[ExchangeService.cash] ERROR: Could not parseInt cash... #{err}"})
  params.reason = if params.cash < 0 then UserHistory.REASON.CASH else UserHistory.REASON.DEPOSIT
  async.waterfall [
  
    # history
    (cb)->
      console.log('222222222222222222222222222222222222222222')
      UserHistory.create params, (err, userHistory)->
        if err
          return cb({code: 1000, error: "Could not process", log: "[ExchangeService.payout] ERROR: Could not process - create UserHistory... #{err}"})
        return cb(null)

    # userProperty
    (cb)->
      console.log('444444444444444444444444444444444444444444');
      UserPropertyCache.findOne user: params.user, (err, property)->
        if err
          return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - get UserPropertyCache... #{err}"})
        if property?
          property.cash += params.cash
          property.total = property.stock + property.cash
          property.capital += params.cash
          property.profit = property.total - property.capital
          property.percent = property.total/property.capital*100
          property.save (err, todayProperty)->
            if err
              return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - update UserPropertyCache... #{err}"})
            return cb(null, todayProperty)

    # UserIndex
    (todayProperty, cb)->
      console.log('55555555555555555555555555555555555555555555');
      UserIndexCache.findOne user: params.user, (err, index)->
        if err
          return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not process - get UserIndexCache... #{err}"})
        
        UserIndex.native (err, collection)->
          if err
            return cb({code: 1000, error: 'Could not process' , log: "[ExchangeService.payout] ERROR: Could not native UserIndex... #{err}"})
          collection.aggregate [
            $match:
              user: ObjectId(params.user)
          ,
            $group:
              _id: ''
              max:
                $max: '$date'
          ], (err, result)->
            if err
              return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not get last date in StockUser... #{err}"})
            
            UserProperty.findOne {user: params.user, date: result[0].max}, (err, lastProperty)->
              if err
                return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not procees - get UserProperty... #{err}"})
              
              index.percentChange = (todayProperty.profit - lastProperty.profit)/(todayProperty.capital+lastProperty.profit)*100
              index.change = (index.index - index.change) * index.percentChange/100
              index.index = index.change/(index.percentChange/100) + index.change
              index.save (err)->
                if err
                  return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.payout] ERROR: Could not update UserIndex... #{err}"})
                return cb(null)
  ], (err)->
    if err
      return done(err)
    User.findOne id: params.user, (err, user)->
      if err
        return cb({code: 1000, error: 'Could not process', log: "[ExchangeService.stock] ERROR: Could not process - get User... #{err}"})
      if user.nickname == "bbbfund"
        bbbfundDatas = []
        data = {}
        if params.cash > 0
          data.submit = "Gửi"
          data.tienMat = params.cash
        else
          data.submit = "Rút"
          data.tienMat = -params.cash
        bbbfundDatas.push data
        DataService.updatebbbfund(bbbfundDatas)
    return done(null, {success: 'Update Data success'})