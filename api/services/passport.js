var LocalStrategy    = require('passport-local').Strategy;
var FacebookStrategy = require('passport-facebook').Strategy;
var GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;
var bcrypt = require('bcrypt');
var config = { 
  facebook: {
    client_id: '',
    client_secret: '',
    redirect_url: '',
    timeout: 1200000
  },
  google: {
    client_id: '',
    client_secret: '',
    redirect_url: ''
  }
}

module.exports = function (passport) {
  passport.serializeUser(function(user, done) {
    done(null, user.id);
  });

  passport.deserializeUser(function(id, done) {
    User.findOne({id:id}, function(err, user) {
      done(err, user);
    });
  });
  
  // =========================================================================
  // LOCAL SIGNUP ================================================================
  // =========================================================================
  passport.use('local-signup', new LocalStrategy({
    usernameField : 'username',
    passwordField : 'password',
    passReqToCallback : true // allows us to pass back the entire request to the callback
  },
  function(req, username, password, done) {
    process.nextTick(function() {
      var params = req.allParams();
      LocalAcc.findOne({ 'username' :  username}, function(err, user) {
        if (err) {
          console.log(err);
          return done({code: 1000, error: 'Could not process'});
        }
        if (user) {
          return done({code: 1001, error: 'That username is already taken.'});
        } else {
          User.create({local: {username: username, password: password}, email: params.email, nickname: username}, function(err, newUser){
            if (err) {
              console.log(err);
              return done({code: 1000, error: 'Could not process'});
            }
            return done(null, newUser);
          })
        }
      });    
    });
  }));
  // =========================================================================
  // LOCAL LOGIN ================================================================
  // =========================================================================
  passport.use('local-login', new LocalStrategy({
    usernameField: 'username',
    passwordField: 'password',
    passReqToCallback : true // allows us to pass back the entire request to the callback
  },
  function(req, username, password, done) {
    LocalAcc.findOne({username: username}, function (err, local) {
      if (err) { return done({code: 1000, error: 'Could not process'}); }
      if (!local) {
        return done({code: 1003, error: 'Username is not existed'}, null);
      }
      bcrypt.compare(password, local.password, function (err, res) {
        if (!res)
          return done({code: 1004, error: 'Incorrect password'}, null);
        User.findOne({local: local.id}, function (err, user) {
          if (err) { return done({code: 1000, error: 'Could not process'}); }
          var returnUser = {
            nickname: user.nickname,
            createdAt: user.createdAt,
            id: user.id
          };
          return done(null, returnUser);
        })
      });
    });
  }));
  // =========================================================================
  // FACEBOOK ================================================================
  // =========================================================================
  passport.use(new FacebookStrategy({
    clientID        : config.facebook.client_id,
    clientSecret    : config.facebook.client_secret,
    callbackURL     : config.facebook.redirect_url
  },
  function(token, refreshToken, profile, done) {
    process.nextTick(function() {
      FbAcc.findOne({ 'fbid' : profile.id }, function(err, fbAcc) {
        if (err)
          return done(err);
        if (fbAcc) {
          fbAcc.token = token;
          fbAcc.email = profile.emails[0].value;
          fbAcc.name = profile.name.givenName + ' ' + profile.name.familyName;
          fbAcc.save(function(err, updated){
            if (err) return done(err, null);
            User.findOne({facebook: fbAcc.id}).populate('facebook').exec(function(err, user){
              if (err) {
                sails.log.info(err);
                return done(err, null);
              }
              return done(null, user);
            })
          })
        } else {
          User.create({facebook: {fbid: profile.id, token: token, email: profile.emails[0].value, name: profile.name.givenName + ' ' + profile.name.familyName}, nickname: profile.name.givenName}, function(err, user){
            if (err) {
              sails.log.info(err);
              return done(err,null);
            }
            return done(null, user);
          });
        }
      });
    });
  }));
  // =========================================================================
  // GOOGLE ================================================================
  // =========================================================================
  passport.use(new GoogleStrategy({
    clientID        : config.google.client_id,
    clientSecret    : config.google.client_secret,
    callbackURL     : config.google.redirect_url
  },
  function(token, refreshToken, profile, done) {
    process.nextTick(function() {
      GgAcc.findOne({ 'ggid' : profile.id }, function(err, ggAcc) {
        if (err)
          return done(err);
        if (ggAcc) {
          ggAcc.token = token;
          ggAcc.email = profile.emails[0].value;
          ggAcc.name = profile.displayName;
          ggAcc.save(function(err, updated){
            if (err) return done(err, null);
            User.findOne({google: ggAcc.id}).populate('google').exec(function(err, user){
              if (err) {
                sails.log.info(err);
                return done(err, null);
              }
            return done(null, user);
            })  
          })
        } else {
          User.create({google: {ggid: profile.id, token: token, email: profile.emails[0].value, name: profile.displayName}, nickname: profile.displayName}, function(err, user){
            if (err) {
              sails.log.info(err);
              return done(err, null);
            }
            return done(null, user);
          });
        }
      });
    });
  }));
};