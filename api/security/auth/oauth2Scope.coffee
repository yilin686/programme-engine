_ = require 'lodash'

DB = {}

module.exports = (scopes...) ->
  for scope in scopes
    if scope not in DB.scopes
      throw new ReferenceError "无效的`scope`: #{scope}"

  (req, res, next) ->
    if _(DB.permissions[req.user?.role]).any((scope) -> scope in scopes)
      next()
    else
      res.sendStatus 403

module.exports.initialize = (roles, scopes, permissions) ->
  for role, allows of permissions
    if role not in roles
      throw new ReferenceError "无效的`role`: #{role}"
    else
      for scope in allows
        if scope not in scopes
          throw new ReferenceError "无效的`scope`: #{scope}"
          
  DB = {roles, scopes, permissions}

