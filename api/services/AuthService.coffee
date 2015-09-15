passport = require('passport')
require('./passport.js')(passport)

exports.register = (req, res)=>
  passport.authenticate('local-signup', (err, user)->
    if err
      sails.log.info "[AuthService.register] ERROR: #{err.error}"
      return res.badRequest err
    req.login user, (err)->
      if err
        sails.log.info "[AuthService.register] ERROR: Could not local login... #{err}"
        return res.badRequest {code: 1002, error: "[AuthService.register] ERROR: Could not local login... #{err}"}
      # req.session.user = user.id
      return res.send user
  ) req, res

exports.login = (req, res)->
  passport.authenticate('local-login', (err, user)->
    if err
      sails.log.info "[AuthService.login] ERROR: #{err.error}"
      return res.badRequest err
    req.login user, (err)->
      if err
        sails.log.info "[AuthService.login] ERROR: Could not local login... #{err}"
        return res.badRequest {code: 1002, error: "[AuthService.login] ERROR: Could not local login... #{err}"}
      return res.send user
  ) req, res

exports.facebook = (req, res)->
  passport.authenticate('facebook', scope: ['email']
  , (err, user)->
    if err
      sails.log.info "[AuthService.facebook] ERROR: Could not facebook auth... #{err}"
      return res.badRequest {code: 1005, error: "[AuthService.facebook] ERROR: Could not facebook auth... #{err}"}
    req.login user, (err)->
      if err
        sails.log.info "[AuthService.facebook] ERROR: Could not facebook login... #{err}"
        return res.badRequest {code: 1002, error: "[AuthService.facebook] ERROR: Could not facebook login... #{err}"}
      return res.send(user)
  )(req, res)

exports.fbcallback = (req, res)->
  passport.authenticate('facebook', (err, user)->
    req.login user, (err)->
      if err
        sails.log.info "[AuthService.fbcallback] ERROR: Could not fb login... #{err}"
        return res.redirect 'http://bbbinc.herokuapp.com/#/login'
      return res.redirect 'http://bbbinc.herokuapp.com/#/user'
  )(req, res)

exports.google = (req, res)->
  passport.authenticate('google', scope: ['email']
  , (err, user)->
    if err
      sails.log.info "[AuthService.google] ERROR: Could not google login... #{err}"
      return res.badRequest {code: 1006, error: "[AuthService.google] ERROR: Could not google login... #{err}"}
    req.login user, (err)->
      if err
        sails.log.info "[AuthService.google] ERROR: Could not gg login... #{err}"
        return res.badRequest {code: 1002, error: "[AuthService.google] ERROR: Could not gg login... #{err}"}
      return res.send(user)
  )(req, res)

exports.ggcallback = (req, res)->
  passport.authenticate('google', (err, user)->
    req.login user, (err)->
      if err
        sails.log.info "[AuthService.register] ERROR: Could not gg login... #{err}"
        return res.redirect 'http://bbbinc.herokuapp.com/#/login'
      return res.redirect 'http://bbbinc.herokuapp.com/#/user'
  )(req, res)
