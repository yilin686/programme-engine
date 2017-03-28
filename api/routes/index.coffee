express = require '../express'

module.exports = router = express.Router()

# 统一处理参数

# 路由
router.use '/', require './programmes'
