CronJob = require('cron').CronJob
StockJob = require('./StockJob')

cronEveryMinute = ()=>
  sails.log.info 'starting cronEveryMinute......'
  job = new CronJob
    cronTime: '00 */5 9-23 * * 1-5'
    onTick: ()->
      sails.log.info 'run every min from 9h-15h, Monday-Friday'
      StockJob.getHSC()
    onComplete: ()->
      sails.log.info 'stopping...'
    start: false
    timeZone: "Asia/Saigon"  

  job.start()

cronEvery15Minutes = ()=>
  job = new CronJob
    cronTime: '00 */15 * * * *'
    onTick: ()->
      sails.log.info 'run every 15 mins'
    onComplete: ()->
      sails.log.info 'stopping...'
    start: false
    timeZone: "Asia/Saigon"  

  job.start()

cronEveryHour = ()=>
  job = new CronJob
    cronTime: '00 00 * * * *'
    onTick: ()->
      sails.log.info 'run every hour'
    onComplete: ()->
      sails.log.info 'stopping...'
    start: false
    timeZone: "Asia/Saigon"  

  job.start()

cronEveryDay = ()=>
  job = new CronJob
    cronTime: '00 50 23 * * 1-5'
    onTick: ()->
      sails.log.info 'run every day, Monday-Friday'
      StockJob.createPerDay()
    onComplete: ()->
      sails.log.info 'stopping...'
    start: false
    timeZone: "Asia/Saigon"  

  job.start()

exports.start = (done)=>
  cronEveryMinute()
  cronEvery15Minutes()
  cronEveryHour()
  cronEveryDay()
  done(null)