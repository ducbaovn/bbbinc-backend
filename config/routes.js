/**
 * Route Mappings
 * (sails.config.routes)
 *
 * Your routes map URLs to views and controllers.
 *
 * If Sails receives a URL that doesn't match any of the routes below,
 * it will check for matching files (images, scripts, stylesheets, etc.)
 * in your assets directory.  e.g. `http://localhost:1337/images/foo.jpg`
 * might match an image file: `/assets/images/foo.jpg`
 *
 * Finally, if those don't match either, the default 404 handler is triggered.
 * See `api/responses/notFound.js` to adjust your app's 404 logic.
 *
 * Note: Sails doesn't ACTUALLY serve stuff from `assets`-- the default Gruntfile in Sails copies
 * flat files from `assets` to `.tmp/public`.  This allows you to do things like compile LESS or
 * CoffeeScript for the front-end.
 *
 * For more information on configuring custom routes, check out:
 * http://sailsjs.org/#/documentation/concepts/Routes/RouteTargetSyntax.html
 */

module.exports.routes = {

  /***************************************************************************
  *                                                                          *
  * Make the view located at `views/homepage.ejs` (or `views/homepage.jade`, *
  * etc. depending on your default view engine) your home page.              *
  *                                                                          *
  * (Alternatively, remove this and add an `index.html` file in your         *
  * `assets` directory)                                                      *
  *                                                                          *
  ***************************************************************************/

  // '/': {
  //   view: 'index'
  // },

  // 'get /partials/home': 'ViewController.home',
  /***************************************************************************
  *                                                                          *
  * Custom routes here...                                                    *
  *                                                                          *
  *  If a request to a URL doesn't match any of the custom routes above, it  *
  * is matched against Sails route blueprints. See `config/blueprints.js`    *
  * for configuration options and examples.                                  *
  *                                                                          *
  ***************************************************************************/
  // 'post /auth/register': 'AuthController.register',
  // 'post /auth/registerfb': 'AuthController.registerFb',
  // 'post /auth/registergg': 'AuthController.registerGg',
  // 'post /auth/loginfb': 'AuthController.loginFb',
  // 'post /auth/logingg': 'AuthController.loginGg',
  'post /auth/register': 'AuthController.register',
  'post /auth/login': 'AuthController.login',
  'post /auth/facebook': 'AuthController.facebook',
  'get /auth/facebook/callback': 'AuthController.fbcallback',
  'post /auth/google': 'AuthController.google',
  'get /auth/google/callback': 'AuthController.ggcallback',
  'post /test': 'AuthController.test',
  'post /auth/logout': 'AuthController.logout',
  'post /refresh': 'StockController.refresh',

  'post /stock/listMarket': 'StockController.listMarket',
  'post /stock/list': 'StockController.list',
  'post /stockinfo/new': 'StockInfoController.newList',

  'post /bbbfund/property/new': 'bbbfund/PropertyController.newList',
  'post /bbbfund/index/new': 'bbbfund/IndexController.newList',
  'post /bbbfund/index/chart': 'bbbfund/IndexController.chart',
  'post /bbbfund/property/yearlychart': 'bbbfund/PropertyController.yearlyChart',
  'post /bbbfund/stock/change': 'bbbfund/StockController.changeList',
  'post /bbbfund/stock/list': 'bbbfund/StockController.list',
  'post /bbbfund/stock/new': 'bbbfund/StockController.newList',
  'post /bbbfund/stock/analyse': 'bbbfund/StockController.analyse',

  'post /stockIndex/vnlist': 'StockIndexController.vnList',

  'post /user/property/new': 'user/PropertyController.newList',
  'post /user/index/new': 'user/IndexController.newList',
  'post /user/index/chart': 'user/IndexController.chart',
  'post /user/property/yearlychart': 'user/PropertyController.yearlyChart',
  'post /user/stock/change': 'user/StockController.changeList',
  'post /user/stock/list': 'user/StockController.list',
  'post /user/stock/new': 'user/StockController.newList',
  'post /user/stock/analyse': 'user/StockController.analyse',
  'post /user/exchange/stock': 'user/ExchangeController.stock',
  'post /user/exchange/create': 'user/ExchangeController.create',
  'post /user/exchange/cash': 'user/ExchangeController.cash',
  'post /user/exchange/payout': 'user/ExchangeController.payout',
};
