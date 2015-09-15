/**
 * Session Configuration
 * (sails.config.session)
 *
 * Sails session integration leans heavily on the great work already done by
 * Express, but also unifies Socket.io with the Connect session store. It uses
 * Connect's cookie parser to normalize configuration differences between Express
 * and Socket.io and hooks into Sails' middleware interpreter to allow you to access
 * and auto-save to `req.session` with Socket.io the same way you would with Express.
 *
 * For more information on configuring the session, check out:
 * http://sailsjs.org/#/documentation/reference/sails.config/sails.config.session.html
 */

module.exports.session = {

  /***************************************************************************
  *                                                                          *
  * Session secret is automatically generated when your new app is created   *
  * Replace at your own risk in production-- you will invalidate the cookies *
  * of your users, forcing them to log in again.                             *
  *                                                                          *
  ***************************************************************************/
  secret: 'd881714a88d977db90e92cbc047a7071',


  /***************************************************************************
  *                                                                          *
  * Set the session cookie expire time The maxAge is set by milliseconds,    *
  * the example below is for 24 hours                                        *
  *                                                                          *
  ***************************************************************************/

  cookie: {
    maxAge: 30 * 24 * 60 * 60 * 1000
  },

  /***************************************************************************
  *                                                                          *
  * In production, uncomment the following lines to set up a shared redis    *
  * session store that can be shared across multiple Sails.js servers        *
  ***************************************************************************/

  // adapter: 'redis',

  /***************************************************************************
  *                                                                          *
  * The following values are optional, if no options are set a redis         *
  * instance running on localhost is expected. Read more about options at:   *
  * https://github.com/visionmedia/connect-redis                             *
  *                                                                          *
  *                                                                          *
  ***************************************************************************/
  
   // redisToGo: {
  //   adapter: 'sails-redis',
  //   host: 'catfish.redistogo.com',
  //   port: 9756,
  //   database: 0,
  //   user: 'redistogo',
  //   password: 'bb08a3f1e673cf13ea06c04bb7e03591',
  //   options: {
  //     return_buffers: false,
  //     detect_buffers: false,
  //     socket_nodelay: true,
  //     enable_offline_queue: true
  //   }
  // },

  // host: 'catfish.redistogo.com',
  // port: 9756,
  // db: 1,
  // pass: 'bb08a3f1e673cf13ea06c04bb7e03591',


  /***************************************************************************
  *                                                                          *
  * Uncomment the following lines to use your Mongo adapter as a session     *
  * store                                                                    *
  *                                                                          *
  ***************************************************************************/

  // adapter: 'mongo',
  // host: 'ds047672-a.mongolab.com',
  // port: 47672,
  // user: 'heroku_ghlgdgn2',
  // password: '67u6fl8npmc0jrj2thrvqj3es7',
  // db: 'heroku_ghlgdgn2',
  // url: 'mongodb://heroku_ghlgdgn2:67u6fl8npmc0jrj2thrvqj3es7@ds047672-a.mongolab.com:47672/heroku_ghlgdgn2/sessions',

  /***************************************************************************
  *                                                                          *
  * Optional Values:                                                         *
  *                                                                          *
  * # Note: url will override other connection settings url:                 *
  * 'mongodb://user:pass@host:port/database/collection',                     *
  *                                                                          *
  ***************************************************************************/

  // username: '',
  // password: '',
  // auto_reconnect: false,
  // ssl: false,
  // stringify: true

};
