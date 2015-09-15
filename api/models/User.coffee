 # User.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

ONLINE_STATUSES =
  ONLINE: 'ONLINE'
  BUSY: 'BUSY'
  AWAY: 'AWAY'
  INVISIBLE: 'INVISIBLE'
  OFFLINE: 'OFFLINE'

module.exports =
  ONLINE_STATUSES: ONLINE_STATUSES
  schema: true
  autoCreatedAt: true
  autoUpdatedAt: true
  attributes:
    # ---------------------#
    # store web controls  #
    # ------------------- #
    
    local:
      model: 'LocalAcc'

    facebook:
      model: 'FbAcc'

    google:
      model: 'GgAcc'

    email:
      type: 'email'
      unique: true

    nickname:
      type: 'string'
      defaultsTo: ''
      maxLength: 50
      index: true

    avatar_url:
      type: 'string'

    package:
      type: 'string'
      # required: true

    cellphone:
      type: 'string'

    onlineStatus:
      type: 'string'
      defaultsTo: ONLINE_STATUSES.ONLINE

    fbFriends:
      type: 'array'

    # exp on global
    exp: 
      type: 'float'
      defaultsTo: 0.0

    level:
      type: 'integer'
      defaultsTo: 1

    history:
      collection: 'UserHistory'
      via: 'user'

  publicJSON: ()->
    obj = this.toObject()
    ojs = 
      id: obj.id
      nickname: obj.nickname
      exp: obj.exp
      level: (obj.level || 1)
    ojs
