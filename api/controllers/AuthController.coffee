async = require('async')
moment = require('moment')

module.exports =
  
  loginpage: (req, res)->
    res.view()

  register: (req, res)->
    params = req.allParams()
    AuthService.register req, res

  login: (req, res)->
    params = req.allParams()
    AuthService.login req, res

  facebook: (req, res)->
    params = req.allParams
    AuthService.facebook req, res

  fbcallback: (req, res)->
    params = req.allParams
    AuthService.fbcallback req, res

  google: (req, res)->
    params = req.allParams
    AuthService.google req, res

  ggcallback: (req, res)->
    params = req.allParams
    AuthService.ggcallback req, res
  
  logout: (req, res)->
    req.session.destroy (err)->
      if err
        res.badRequest(err)
      else
        res.status(200).send({success: 'Log out success'})