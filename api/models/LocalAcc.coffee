 # User.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models
bcrypt = require('bcrypt')

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  attributes:
    # ---------------------#
    # store web controls  #
    # ------------------- #
    
    username:
      type: 'string'
      index: true
      required: true

    password:
      type: 'string'
      required: true

    publicJSON: ()->
      obj = this.toObject()
      ojs = 
        id: obj.id
        username: obj.username
      ojs

  beforeCreate: (user, cb)->
    bcrypt.genSalt 10, (err, salt)->
      bcrypt.hash user.password, salt, (err, hash)->
        if (err)
          console.log(err)
          cb(err)
        else 
          user.password = hash
          cb()