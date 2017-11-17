player = {}
player.body = love.physics.newBody(myWorld, 100, 100, "dynamic")
player.shape = love.physics.newRectangleShape(66, 92)
player.fixture = love.physics.newFixture(player.body, player.shape)
player.speed = 200
player.jumpForce = 2500
player.grounded = false
player.direction = 1

function playerUpdate(dt)
  if (love.keyboard.isDown("left")) then
    player.body:setX(player.body:getX() - player.speed * dt)
    player.direction = -1
  end

  if (love.keyboard.isDown("right")) then
    player.body:setX(player.body:getX() + player.speed * dt)
    player.direction = 1
  end
end
