request = require('request')
cheerio = require('cheerio')
_ = require('lodash')
numeral = require('numeral')

options = [
	market: 'HN'
	uri: 'http://priceonline.hsc.com.vn/hnpriceonline/Process.aspx?Type=MS'
	encoding: 'utf8'
	method: 'GET'
	headers: {cookie: "_kieHNXSF="}
,
	market: 'HCM'
	uri: 'http://priceonline.hsc.com.vn/Process.aspx?Type=MS'
	encoding: 'utf8'
	method: 'GET'
	headers: {cookie: "_kieHoSESF="}
]
exports.reqData = (done)->
	reqData = []
	async.each options, (option, cb1)->
		Stock.count market: option.market, (err, count)->
			if err
				return cb1({code: 1000, error: "[DataService.reqData] ERROR: Could not count stock... #{err}"})
			pages = Math.floor(count/50)
			conds = []
			for i in [0..pages]
				conds.push market: option.market, limit: 50, skip: 50*i
			async.each conds, (cond, cb2)->
				Stock.find cond, (err, stocks)->
					if err
						return cb2({code: 1000, error: "[DataService.reqData] ERROR: Could not get stock... #{err}"})
					a = _.cloneDeep(option)
					a.headers.cookie += stock.code + '|' for stock in stocks
					reqData.push a
					return cb2()
			, (err)->
				if err
					return cb1(err)
				return cb1()
	, (err)->
		if err
			return done(err, null)
		return done(null, reqData)

exports.getStockData = (reqDatas, done)->
	stocks = []
	indexs = []
	indexStr = [];
	async.each reqDatas, (reqData, cb)->
		request reqData, (err, res, body)->
			if err
				return cb({code: 1000, error: "[DataService.getStockData] ERROR: Could not request Data... #{err}"})
			if reqData.market == 'HCM'
				indexStr = body.split('^')[0].split('|')
			datas = body.split('^')[1].split('|')
			datas.pop()
			stocks.push data.split(',') for data in datas
			return cb()
	, (err)->
		if err
			return done(err, null)
		indexs.push index.split(',') for index in indexStr
		return done(null, {index: indexs, stock: stocks})

exports.updatebbbfund = (datas)->
	for data in datas
		request.post {url:'http://bbbfund.herokuapp.com/admin', form: data}, (err,httpResponse,body)->
			console.log '=============================================================='
			console.log JSON.stringify data
			console.log '=============================================================='
			console.log JSON.stringify body
			if err
				sails.log.info "[DataService.updatebbbfund] ERROR: Could not process... #{err}"
# exports.getCompanyInfo = (done)->
# 	reqSample =
# 		uri: 'http://www.cophieu68.vn/filter_index_result.php?currentPage='
# 		encoding: 'utf8'
# 		method: 'GET'

# 	result = []
# 	async.each [1..39], (page, cb1)->
# 		req = reqSample
# 		req = req.uri + page
# 		request req, (err, res, body)->
# 			if err
# 				return cb1({code: 1000, error: "[DataService.getCompanyInfo] ERROR: Could not request Data... #{err}"})
# 			$ = cheerio.load(body)
# 			datas = _.chunk($('.td_bottom3'), 14)
# 			companies = $('.td_bottom3 a strong')
# 			async.each [0..companies.length-1], (i, cb2)->
# 				info = {}
# 				Stock.findOne code: companies[i].children[0].data, (err, stock)->
# 					if err
# 						return cb2({code: 1000, error: "[DataService.getCompanyInfo] ERROR: Could not get Stock... #{err}"})
# 					if stock?
# 						info.stock = stock.id
# 						info.eps = numeral().unformat(datas[i][4].children[0].data)
# 						info.pe = numeral().unformat(datas[i][5].children[0].data)
# 						info.roe = numeral().unformat(datas[i][6].children[0].data)
# 						info.roa = numeral().unformat(datas[i][7].children[0].data)
# 						info.pb = numeral().unformat(datas[i][8].children[0].data)
# 						info.quantity = numeral().unformat(datas[i][12].children[0].data)
# 						info.capital = numeral().unformat(datas[i][13].children[0].data)
# 						info.quarter = Math.floor(new Date().getMonth()/3) + 1
# 						info.year = new Date().getFullYear()
# 						result.push info
# 					return cb2()
# 			, (err)->
# 				if err
# 					return cb1(err)
# 				return cb1()
# 	, (err)->
# 		if err
# 			return done(err)
# 		return done(null, result)