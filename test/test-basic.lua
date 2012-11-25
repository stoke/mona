local http = require('http')
local mona = require('..')
local helpers = require('./helpers')
local server = mona.new()
local t = helpers.spawntest()

server
  :use(function(req, res, next)
    if (req.url == '/test1') then
      res:finish('test1')
    else
      req.test_properties = true
      next()
    end
  end)

  :use(function(req, res)
    assert(req.test_properties, "should set properties")
    res:finish('test')
  end)

  :listen(8000, function()
    helpers.get('/test1', t:test('should answer connections properly', function(body)
      assert(body == 'test1')
    end))

    helpers.get('/', t:test('should pass when "next" is called', function(body)
      assert(body == 'test')
    end))
  end)