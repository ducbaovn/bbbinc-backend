exports.vnList = (req, res)->
	params = req.allParams()
	params.group = ['VN', 'VN30']
	StockIndexService.list params, (err, list)->
		if err
			sails.log.info err.log
			return res.badRequest {code: err.code, error: err.error}
		return res.send list

exports.newList = (req, res)->
  params = req.allParams()
  params.group = ['VN', 'VN30']
  StockIndexService.newList params, (err, list)->
    if err
      sails.log.info err.log
      return res.badRequest {code: err.code, error: err.error}
    return res.send list