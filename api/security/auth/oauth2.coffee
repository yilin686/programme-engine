passport = require 'passport'
oauth2orize = require 'oauth2orize'
crypto = require 'crypto'
User = require '../../../core/models/user'
OAuth2Client = require './oauth2Client'
OAuth2Token = require './oauth2Token'
conf = require '../../../conf'

server = oauth2orize.createServer()

regenerateToken = (userId, clientId) ->
  OAuth2Token.remove {userId, clientId}
    .then ->
      OAuth2Token.create {
        userId,
        clientId,
        accessToken: crypto.randomBytes(32).toString('hex')
        refreshToken: crypto.randomBytes(32).toString('hex')
        createdAt: Date.now()
      }

# 用`username`和`password`换`token`
server.exchange (
  oauth2orize.exchange.password (client, username, password, scope, done) ->
    User.authenticate username, password
      .then (user) ->
        if not user
          done null, false
        else
          regenerateToken user.id, client.id
            .then (token) ->
              done null, token.accessToken, token.refreshToken, {expires_in: conf.security.tokenLife}
      .catch (err) ->
        console.error err
        done err
)

# 用`refreshToken`换新`token`
server.exchange (
  oauth2orize.exchange.refreshToken (client, refreshToken, scope, done) ->
    OAuth2Token.findOne {refreshToken}
      .then (token) ->
        if not token
          done null, false
        else
          regenerateToken token.userId, token.clientId
            .then (token) ->
              done null, token.accessToken, token.refreshToken, {expires_in: conf.security.tokenLife}
      .catch done
)


authenticateClient = (clientId, clientSecret, done) ->
  OAuth2Client.findOne _id: clientId
    .then (client) ->
      if client?.secret is clientSecret
        done null, client.toObject()
      else
        done null, false
    .catch done

BasicStrategy = require('passport-http').BasicStrategy
passport.use new BasicStrategy(authenticateClient)

ClientPasswordStrategy = require('passport-oauth2-client-password').Strategy
passport.use new ClientPasswordStrategy(authenticateClient)


module.exports.token = [
  passport.authenticate ['basic', 'oauth2-client-password'], {session: false}
  server.token()
  server.errorHandler()
]
