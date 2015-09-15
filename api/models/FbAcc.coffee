 # User.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  attributes:
    # ---------------------#
    # store web controls  #
    # ------------------- #
    
    fbid:
      type: 'string'
      required: true

    token:
      type: 'string'
      required: true
    
    email:
      type: 'email'
      index: true
      required: true

    name:
      type: 'string'
      required: true

    publicJSON: ()->
      obj = this.toObject()
      ojs = 
        id: obj.id
        email: obj.email
        name: obj.name
      ojs
