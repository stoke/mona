local http = require('http')
local table = require('table')

local server = {}

function server:use(fn)
  table.insert(self.middlewares, fn)

  return self -- Chainable
end

function server:router()
  local this = self

  return function(req, res)
    local i = 0

    local function loop()
      i = i + 1
      
      if not #this.middlewares or not this.middlewares[i] then
        return res:finish()
      end

      this.middlewares[i](req, res, loop)
    end

    loop()
  end
end

function server:listen(...)
  self.server:listen(...)
end

function server.new()
  local instance = {
    middlewares = {}
  }

  setmetatable(instance, {__index = server})
  instance.server = http.createServer(instance:router())

  return instance
end

return server