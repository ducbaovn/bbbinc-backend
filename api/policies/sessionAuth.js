/**
 * sessionAuth
 *
 * @module      :: Policy
 * @description :: Simple policy to allow any authenticated user
 *                 Assumes that your login action in one of your controllers sets `req.session.authenticated = true;`
 * @docs        :: http://sailsjs.org/#!documentation/policies
 *
 */
module.exports = function(req, res, next) {

  // User is allowed, proceed to the next policy, 
  // or if this is the last policy, the controller
  // res.header("Access-Control-Allow-Origin", "*")
  // res.header("Access-Control-Allow-Credentials", true)
  if (req.isAuthenticated()) {
    return next();
  }

  // User is not allowed
  // (default res.forbidden() behavior can be overridden in `config/403.js`)
  sails.log.info("[sessionAuth] ERROR: User is not authenticated");
  return res.forbidden({code: 1013, error: 'You are not permitted to perform this action.'});
};
