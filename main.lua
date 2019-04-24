function love.load()
  -- body...
  --store files in table--
  sprites = {}
  sprites.player = love.graphics.newImage('sprites/player_idle_front.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet.png')
  sprites.enemy = love.graphics.newImage('sprites/enemy_idle_front.png')
  LoadBackgroundFiles();

  animSpeed = 0
  animSprite = 1

  --store screen width and height--
  screenWidth = 800
  screenHeight = 600

  --store sprite width and height--
  spriteWidth = 16 * 3
  spriteHeight = 16 * 3

 --player object (table)--
  player = {}
  player.x = 200
  player.y = 200
  player.speed = 180  --60 frames per second, 180 * 1/60(or dt) = 3

  --enemies--
  enemies = {}
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function love.update(dt)
--body--
  PlayerControls(dt);
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function love.draw()
  -- body...
  DrawBackground();
  --(file name, posx, posy, orientation in radian, scalex, scaley, origin offsetx, origin offsety, shear factor x, shear factor y)
  love.graphics.draw(sprites.player, player.x, player.y, nil, 2, 2)
  love.graphics.draw(sprites.bullet, 200, 100, r, .5, .5)

  --cycles through enemies table to draw enemies--
  for i,z in ipairs(enemies) do
    love.graphics.draw(sprites.enemy, z.x, z.y, r, 2, 2)
  end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function PlayerControls(dt)
  spriteFrontWalkAnim = {}
  spriteFrontWalkAnim[1] = love.graphics.newImage('sprites/player_walk_front1.png')
  spriteFrontWalkAnim[2] = love.graphics.newImage('sprites/player_walk_front2.png')
  frontWalkAnim = spriteFrontWalkAnim[1]

  if love.keyboard.isDown("s") then
    animSpeed = animSpeed + dt
    frontWalkAnim = spriteFrontWalkAnim[animSprite]
    sprites.player = frontWalkAnim
    if animSpeed > 0.2 then
      animSprite = animSprite + 1
      animSpeed = 0
    end
    if animSprite > 2 then
      animSprite = 1
    end
    player.y = player.y + player.speed * dt
  end

  spriteBackWalkAnim = {}
  spriteBackWalkAnim[1] = love.graphics.newImage('sprites/player_walk_back1.png')
  spriteBackWalkAnim[2] = love.graphics.newImage('sprites/player_walk_back2.png')
  backWalkAnim = spriteBackWalkAnim[1]

  if love.keyboard.isDown("w") then
    animSpeed = animSpeed + dt
    backWalkAnim = spriteBackWalkAnim[animSprite]
    sprites.player = backWalkAnim

    if animSpeed > 0.2 then
      animSprite = animSprite + 1
      animSpeed = 0
    end
    if animSprite > 2 then
      animSprite = 1
    end
    player.y = player.y - player.speed * dt
  end

  spriteLeftWalkAnim = {}
  spriteLeftWalkAnim[1] = love.graphics.newImage('sprites/player_walk_left1.png')
  spriteLeftWalkAnim[2] = love.graphics.newImage('sprites/player_walk_left2.png')
  leftWalkAnim = spriteLeftWalkAnim[1]

  if love.keyboard.isDown("a") then
    animSpeed = animSpeed + dt
    leftWalkAnim = spriteLeftWalkAnim[animSprite]
    sprites.player = leftWalkAnim

    if animSpeed > 0.2 then
      animSprite = animSprite + 1
      animSpeed = 0
    end
    if animSprite > 2 then
      animSprite = 1
    end

    player.x = player.x - player.speed * dt
  end

  spriteRightWalkAnim = {}
  spriteRightWalkAnim[1] = love.graphics.newImage('sprites/player_walk_right1.png')
  spriteRightWalkAnim[2] = love.graphics.newImage('sprites/player_walk_right2.png')
  rightWalkAnim = spriteRightWalkAnim[1]

  if love.keyboard.isDown("d") then
    animSpeed = animSpeed + dt
    rightWalkAnim = spriteRightWalkAnim[animSprite]
    sprites.player = rightWalkAnim

    if animSpeed > 0.2 then
      animSprite = animSprite + 1
      animSpeed = 0
    end
    if animSprite > 2 then
      animSprite = 1
    end

    player.x = player.x + player.speed * dt
  end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function LoadBackgroundFiles()
  sprites.backgroundA = love.graphics.newImage('sprites/ground_top_Left.png')
  sprites.backgroundB = love.graphics.newImage('sprites/ground_top_center.png')
  sprites.backgroundC = love.graphics.newImage('sprites/ground_top_right.png')
  sprites.backgroundD = love.graphics.newImage('sprites/ground_mid_left.png')
  sprites.backgroundE = love.graphics.newImage('sprites/ground_mid_center.png')
  sprites.backgroundF = love.graphics.newImage('sprites/ground_mid_right.png')
  sprites.backgroundG = love.graphics.newImage('sprites/ground_bottom_left.png')
  sprites.backgroundH = love.graphics.newImage('sprites/ground_bottom_center.png')
  sprites.backgroundI = love.graphics.newImage('sprites/ground_bottom_right.png')
end

function DrawBackground()
  --background--
  for i=1, 15, 1 do
    --top--
    if i == 1 then
      love.graphics.draw(sprites.backgroundA, 0, 0, r, 3, 3)
      for i=1, 15, 1 do
        spritePos = spriteWidth * i
        love.graphics.draw(sprites.backgroundB, spritePos , 0, r, 3, 3)
      end
      love.graphics.draw(sprites.backgroundC, screenWidth - spriteWidth, 0, r, 3, 3)
    end
    --top--
    --center--
    if i < 12 then
      love.graphics.draw(sprites.backgroundD, 0, spriteHeight * i, r, 3, 3)
      for j=1, 15, 1 do
        love.graphics.draw(sprites.backgroundE, spriteWidth * j, spriteHeight * i, r, 3, 3)
      end
      love.graphics.draw(sprites.backgroundF, screenWidth - spriteWidth, spriteHeight * i, r, 3, 3)
    end
    --center--
    --bottom--
    if i == 15 then
      love.graphics.draw(sprites.backgroundG, 0, screenHeight - spriteHeight, r, 3, 3)
      for i=1, 15, 1 do
        spritePos = spriteWidth * i
        love.graphics.draw(sprites.backgroundH, spritePos , screenHeight - spriteHeight, r, 3, 3)
      end
      love.graphics.draw(sprites.backgroundI, screenWidth - spriteWidth, screenHeight - spriteHeight, r, 3, 3)
    end
    --bottom--
  end
  --background--
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--gets angle in radians between mouse and player sprite
function PlayerMouseAngle()
  return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function SpawnEnemy()
  --creates enemy objects/table--
  enemy = {}
  enemy.x = math.random(0, love.graphics.getWidth()) --random x pos--
  enemy.y = math.random(0, love.graphics.getHeight())  --random y pos--
  enemy.speed = 100

  --addes to enemies table--
  table.insert(enemies, enemy)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--testing enemy spawn--
function love.keypressed(key, scancode, isrepeat)
  -- body...
  if key == "space" then
    SpawnEnemy()
  end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--reset player to idle--
function love.keyreleased(key)
  if key == "s" then
    sprites.player = love.graphics.newImage('sprites/player_idle_front.png')
  end
  if key == "a" then
    sprites.player = love.graphics.newImage('sprites/player_idle_left.png')
  end
  if key == "d" then
    sprites.player = love.graphics.newImage('sprites/player_idle_right.png')
  end
  if key == "w" then
    sprites.player = love.graphics.newImage('sprites/player_idle_back.png')
  end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
