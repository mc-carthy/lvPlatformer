function love.load()
  myWorld = love.physics.newWorld(0, 500, false)
  myWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

  sprites = {}
  sprites.coin_sheet = love.graphics.newImage('sprites/coin_sheet.png')
  sprites.player_jump = love.graphics.newImage('sprites/player_jump.png')
  sprites.player_stand = love.graphics.newImage('sprites/player_stand.png')

  require('player')

  platforms = {}
  spawnPlatform(50, 400, 300, 30)
end

function love.draw()
  for i, p in ipairs(platforms) do
    love.graphics.rectangle("fill", p.body:getX(), p.body:getY(), p.width, p.height)
  end

  love.graphics.draw(player.sprite, player.body:getX(), player.body:getY(), nil, player.direction, 1, sprites.player_stand:getWidth() / 2, sprites.player_stand:getHeight() / 2)
end

function love.update(dt)
  myWorld:update(dt)
  playerUpdate(dt)
end

function love.keypressed(key, scancode, isrepeat)
  if (key == 'up' and player.grounded) then
    player.body:applyLinearImpulse(0, -player.jumpForce)
  end
end

function beginContact(a, b, coll)
  player.grounded = true
end

function endContact(a, b, coll)
  player.grounded = false
end

function spawnPlatform(x, y, width, height)
  local platform = {}
  platform.body = love.physics.newBody(myWorld, x, y, "static")
  platform.shape = love.physics.newRectangleShape(width / 2, height / 2, width, height)
  platform.fixture = love.physics.newFixture(platform.body, platform.shape)
  platform.width = width
  platform.height = height

  table.insert(platforms, platform)
end
