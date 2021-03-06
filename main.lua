function love.load()
  love.window.setMode(900, 700)
  love.graphics.setBackgroundColor(155, 214, 255)

  myWorld = love.physics.newWorld(0, 500, false)
  myWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

  sprites = {}
  sprites.coin_sheet = love.graphics.newImage('sprites/coin_sheet.png')
  sprites.player_jump = love.graphics.newImage('sprites/player_jump.png')
  sprites.player_stand = love.graphics.newImage('sprites/player_stand.png')

  require('player')
  require('coin')
  require('show')
  anim8 = require('anim8')
  sti = require('sti')
  camera = require('camera')

  cam = camera()
  gameState = 1
  myFont = love.graphics.newFont(30)
  timer = 0

  saveData = {}
  saveData.bestTime = 999
  if (love.filesystem.exists('data.lua')) then
    local data = love.filesystem.load('data.lua')
    data()
  end

  platforms = {}

  gameMap = sti("maps/lvPlatformerMap.lua")

  for i, obj in pairs(gameMap.layers["Platforms"].objects) do
    spawnPlatform(obj.x, obj.y, obj.width, obj.height)
  end

  spawnCoins()
end

function love.draw()
  cam:attach()
  gameMap:drawLayer(gameMap.layers['Tile Layer 1'])

  for i, c in ipairs(coins) do
    c.animation:draw(sprites.coin_sheet, c.x, c.y, nil, nil, nil, 20.5, 21)
  end

  love.graphics.draw(player.sprite, player.body:getX(), player.body:getY(), nil, player.direction, 1, sprites.player_stand:getWidth() / 2, sprites.player_stand:getHeight() / 2)
  cam:detach()

  -- Add UI draw calls after cam:detach
  if (gameState == 1) then
    love.graphics.setFont(myFont)
    love.graphics.printf("Press any key to begin!", 0, 50, love.graphics.getWidth(), "center")
    love.graphics.printf("Best time: " .. saveData.bestTime, 0, 150, love.graphics.getWidth(), "center")
  end

  love.graphics.print("Time: " .. math.floor(timer), 10, 660)
end

function love.update(dt)
  myWorld:update(dt)
  gameMap:update(dt)
  if (gameState == 2) then
    playerUpdate(dt)
    incrementTimer(dt)
  end
  coinsUpdate(dt)
  checkCoinCount()
  cam:lookAt(player.body:getX(), love.graphics.getHeight() / 2)
end

function love.keypressed(key, scancode, isrepeat)
  if (gameState == 1) then
    gameState = 2
    timer = 0
  elseif (gameState == 2) then
    if (key == 'up' and player.grounded) then
        player.body:applyLinearImpulse(0, -player.jumpForce)
    end
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

function incrementTimer(dt)
    timer = timer + dt
end

function checkCoinCount()
    if (#coins == 0 and gameState == 2) then
        resetGame()
    end
end

function resetGame()
    gameState = 1
    player.body:setPosition(500, 443)

    if (#coins == 0) then
        spawnCoins()
    end

    if (timer < saveData.bestTime) then
        saveData.bestTime = math.floor(timer)
        love.filesystem.write('data.lua', table.show(saveData, "saveData"))
    end
end

function spawnCoins()
    for i, obj in pairs(gameMap.layers["Coins"].objects) do
        spawnCoin(obj.x, obj.y, obj.width, obj.height)
    end
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
