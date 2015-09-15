/**
 * Bootstrap
 * (sails.config.bootstrap)
 *
 * An asynchronous bootstrap function that runs before your Sails app gets lifted.
 * This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
 *
 * For more information on bootstrapping your app, check out:
 * http://sailsjs.org/#/documentation/reference/sails.config/sails.config.bootstrap.html
 */

var async = require('async');
// var _ = require('lodash');
// var path = require('path');
// var SeedData = require(process.cwd()+'/data/seed');
var Cron = require('../workers/cron');
// var AmqpServer = require(process.cwd()+'/amqp/server');
// var QueueServer = require(process.cwd()+'/amqp/queue');

module.exports.bootstrap = function(cb) {

  // override sails.log.eror to print stacktrace
  var _oldSailsLogError = sails.log.error;
  // setInterval(function() {
  //   http.get("http://baomongolab.herokuapp.com");
  // }, 300000);
  sails.log.error = function(msg) {
    if (typeof msg == 'string') {
      msg = new Error(msg);
    }

    _oldSailsLogError(msg);
  }; 
  // data bootstrap
  async.parallel([
    // SeedData.import,
    Cron.start
    // LockerService.init,
    // QueueServer.start
  ], function(){
    cb();
    // AmqpServer.start(cb);
  });
};
