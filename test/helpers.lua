local http = require('http')
local table = require('table')
local t = {}

function t:test(msg, fn)
  local this = self

  self.tot = self.tot + 1

  return function(...)
    local args = {...}
    local status, err = pcall(function() fn(unpack(args)) end)

    if not err then
      this.succtests = this.succtests + 1
      print('\x1b[32m✔\x1b[0m ' .. msg)
    else
      print('\x1b[31m×\x1b[0m ' .. msg)
    end

    this.tests = this.tests + 1

    if (this.tests == this.tot) then
      print(this.succtests .. '/' .. this.tot .. ' Succeded')
      process.exit(this.succtests == this.tot and 0 or 1)
    end
  end
end

function get(path, cbl)
  chunks = {}

  req = http.request({
    path = path,
    port = 8000,
    host = "127.0.0.1"
  }, function(res) 
    res:on("data", function(chunk)
      table.insert(chunks, chunk)
    end)

    res:on("end", function() 
      local body = table.concat(chunks, '')
      chunks = {}

      res:destroy()
      cbl(body)
    end)
  end)

  req:done()
end

function spawntest()
  local instance = {
    tests = 0,
    succtests = 0,
    tot = 0
  }

  setmetatable(instance, {__index = t})
  return instance
end

return {
  get = get,
  spawntest = spawntest
}