function love.load()
  -- body...
  --store files in table--
  sprites = {}
  sprites.player = love.graphics.newImage('sprites/player_idle_front.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet.png')
  sprites.enemy = love.graphics.newImage('sprites/tank_red.png')
  LoadBackgroundFiles();

  animSpeed = 0
  animSprite = 1

  --font--
  myFont = love.graphics.newFont(40)

  --store screen width and height--
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()

  --store sprite width and height--
  spriteWidth = 16 * 3
  spriteHeight = 16 * 3

 --player object (table)--
  player = {}
  player.x = love.graphics.getWidth()/2
  player.y = love.graphics.getHeight()/2
  player.speed = 180  --60 frames per second, 180 * 1/60(or dt) = 3

  --enemies--
  enemies = {}

  --bullets--
  bullets = {}

  --spawn timer--
  gameState = 1
  maxTime = 2
  sTimer = maxTime
  score = 0
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function love.update(dt)
--body--
  if gameState == 2 then
    --player movement--
    PlayerControls(dt)
  end

  --enemy movement--
  for i,e in ipairs(enemies) do
    --looks at current x value and adds current angle to move that direction in the x value--
    --needed to subtract because of the sprite orientation--
    e.x = e.x - math.sin(EnemyPlayerAngle(e)) * e.speed * dt
    --looks at current y value and adds current angle to move that direction in the y value--
    e.y = e.y + math.cos(EnemyPlayerAngle(e)) * e.speed * dt

    --collision detection--
    if DistanceBetween(e.x, e.y, player.x, player.y) < 40 then
      for i,e in ipairs(enemies) do
        enemies[i] = nil --removes zombie if collides with player--
        gameState = 1
        --resets player back to center of screen--
        player.x = love.graphics.getWidth()/2
        player.y = love.graphics.getHeight()/2
      end
    end
  end

--bullet movement--
  for i,b in ipairs(bullets) do
    --calculates the angle in radians of  where the bullet should be going--
    b.x = b.x + math.cos(b.direction) * b.speed * dt
    b.y = b.y + math.sin(b.direction) * b.speed * dt
  end

  --bullet deletion--
  --i is being set to the size of the table "bullets" ( i = #bullets)--
  --then 1 is the end value and -1 is iteration backwards or decrementing--
  for i = #bullets, 1,-1 do
    local b = bullets[i] --position in table--
    if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
      table.remove(bullets, i) --removes items from table--
    end
  end

--enemy and bullet collision--
--checks each enemy and each bullet for a collision--
  for i,e in ipairs(enemies) do
    for j,b in ipairs(bullets) do
      --gets the distance  between the bullets and the enemies  to see if they collide--
      if DistanceBetween(e.x, e.y, b.x, b.y) < 40 then
        e.dead = true  --is enemy dead--
        b.dead = true  --is bullet dead--
        score = score + 1  --adds to score
      end
    end
  end
--enemy deletion after collision--
  for i = #enemies, 1, -1 do
    local e = enemies[i]
    if e.dead == true then
      --removed enemy from list--
      table.remove(enemies, i)
    end
  end

  --bullet deletion after collision--
  for i = #bullets, 1, -1 do
    local b = bullets[i]
    if b.dead == true then
      --removed bullet from list--
      table.remove(bullets, i)
    end
  end

  --start timer count down--
  if gameState == 2 then
  --counts down in seonds--
    sTimer = sTimer - dt
    --increases spawn rate--
    if sTimer <= 0 then
      SpawnEnemy() --spawns--
      maxTime = maxTime * 0.95  --reduces time between spawns--
      sTimer = maxTime --resets timer--
    end
  end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function love.draw()
  -- body...
  DrawBackground();

  --Menu--
  if gameState == 1 then
    love.graphics.setFont(myFont)
    love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
  end

  love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
  --(file name, posx, posy, orientation in radian, scalex, scaley, origin offsetx, origin offsety, shear factor x, shear factor y)
  love.graphics.draw(sprites.player, player.x, player.y, nil, 2, 2)

  --cycles through enemies table to draw an enemy--
  for i,e in ipairs(enemies) do
    love.graphics.draw(sprites.enemy, e.x, e.y, EnemyPlayerAngle(e), sx, sy, sprites.enemy:getWidth()/2, sprites.enemy:getHeight()/2)
  end

  --draw bullets--
  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, b.x, b.y, r, .5, .5, -20, -40)
  end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--controls for player and animations--
function PlayerControls(dt)
  --stores player sprites for animations--
  --stores the front walk sprites--
  spriteFrontWalkAnim = {}
  spriteFrontWalkAnim[1] = love.graphics.newImage('sprites/player_walk_front1.png')
  spriteFrontWalkAnim[2] = love.graphics.newImage('sprites/player_walk_front2.png')
  frontWalkAnim = spriteFrontWalkAnim[1]  --stores first sprite for walking front--
  --move player down toward bottom of screen and limits movement off screen--
  if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() - spriteHeight then
    --animates the player--
    animSpeed = animSpeed + dt  --speed of sprite transitions--
    frontWalkAnim = spriteFrontWalkAnim[animSprite]  --updates to animeSprite which is 1--
    sprites.player = frontWalkAnim  --updates player sprite to frontWalkAnim sprite--
    --cycles through the animation using delta time--
    if animSpeed > 0.2 then
      animSprite = animSprite + 1  --add 1 to change sprite--
      animSpeed = 0 --resets timer to 0
    end
    --reseting sprite to first sprite--
    if animSprite > 2 then
      animSprite = 1
    end
    --moves the player--
    player.y = player.y + player.speed * dt
  end

  --stores the back walk sprites--
  spriteBackWalkAnim = {}
  spriteBackWalkAnim[1] = love.graphics.newImage('sprites/player_walk_back1.png')
  spriteBackWalkAnim[2] = love.graphics.newImage('sprites/player_walk_back2.png')
  backWalkAnim = spriteBackWalkAnim[1]  --sets backwalkanim to first sprite--

  --moves player upward and limites movement--
  if love.keyboard.isDown("w") and player.y > 5 then
    --animates backwards movement by swapping sprites--
    animSpeed = animSpeed + dt
    backWalkAnim = spriteBackWalkAnim[animSprite] --spriteBackWalkAnim is set to 1 --
    sprites.player = backWalkAnim  --sets player sprite to backaalkanim sprite--
    --cycles through sprites using delta time--
    if animSpeed > 0.2 then
      animSprite = animSprite + 1  --add 1 to change sprite--
      animSpeed = 0 --resets timer to 0
    end
    --reseting sprite to first sprite--
    if animSprite > 2 then
      animSprite = 1
    end
    --moves player upward--
    player.y = player.y - player.speed * dt
  end

  --stores left walk sprites--
  spriteLeftWalkAnim = {}
  spriteLeftWalkAnim[1] = love.graphics.newImage('sprites/player_walk_left1.png')
  spriteLeftWalkAnim[2] = love.graphics.newImage('sprites/player_walk_left2.png')
  leftWalkAnim = spriteLeftWalkAnim[1]  --sets leftwalk to first sprite--
  --moves player left and limites movement--
  if love.keyboard.isDown("a") and player.x > 5 then
    --animate movement by swapping sprites--
    animSpeed = animSpeed + dt  --speed using delta time--
    leftWalkAnim = spriteLeftWalkAnim[animSprite]  --set spriteLeftWalkAnim to 1--
    sprites.player = leftWalkAnim  --sets drawing sprite to current sprite--
    --cycles through sprites using delta time--
    if animSpeed > 0.2 then
      animSprite = animSprite + 1  --add 1 to change sprite--
      animSpeed = 0 --resets timer to 0
    end
    --reseting sprite to first sprite--
    if animSprite > 2 then
      animSprite = 1
    end
    --moves the player left--
    player.x = player.x - player.speed * dt
  end

  --stores right walk sprites--
  spriteRightWalkAnim = {}
  spriteRightWalkAnim[1] = love.graphics.newImage('sprites/player_walk_right1.png')
  spriteRightWalkAnim[2] = love.graphics.newImage('sprites/player_walk_right2.png')
  rightWalkAnim = spriteRightWalkAnim[1]  --sets rightwalk to first sprite--

  --moves player right and limites movement--
  if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() - spriteWidth then
    animSpeed = animSpeed + dt
    rightWalkAnim = spriteRightWalkAnim[animSprite]  --sets spriteRightWalkAnim to 1--
    sprites.player = rightWalkAnim  --sets drawn sprite to current sprite--
     --cycles through sprites using delta time--
    if animSpeed > 0.2 then
      animSprite = animSprite + 1  --add 1 to change sprite--
      animSpeed = 0 --resets timer to 0
    end
    --reseting sprite to first sprite--
    if animSprite > 2 then
      animSprite = 1
    end
    --actually moves player right--
    player.x = player.x + player.speed * dt
  end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--loads tile sprites for background--
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
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--draws sprites tils for background--
--this could be done more efficiently, first crack at it, will try to optimize later--
function DrawBackground()
  --start background--
  for i=1, 15, 1 do
    --start top--
    if i == 1 then
      love.graphics.draw(sprites.backgroundA, 0, 0, r, 3, 3)
      for i=1, 15, 1 do
        spritePos = spriteWidth * i
        love.graphics.draw(sprites.backgroundB, spritePos , 0, r, 3, 3)
      end
      love.graphics.draw(sprites.backgroundC, screenWidth - spriteWidth, 0, r, 3, 3)
    end
    --end top--
    --start center--
    if i < 12 then
      love.graphics.draw(sprites.backgroundD, 0, spriteHeight * i, r, 3, 3)
      for j=1, 15, 1 do
        love.graphics.draw(sprites.backgroundE, spriteWidth * j, spriteHeight * i, r, 3, 3)
      end
      love.graphics.draw(sprites.backgroundF, screenWidth - spriteWidth, spriteHeight * i, r, 3, 3)
    end
    --end center--
    --start bottom--
    if i == 15 then
      love.graphics.draw(sprites.backgroundG, 0, screenHeight - spriteHeight, r, 3, 3)
      for i=1, 15, 1 do
        spritePos = spriteWidth * i
        love.graphics.draw(sprites.backgroundH, spritePos , screenHeight - spriteHeight, r, 3, 3)
      end
      love.graphics.draw(sprites.backgroundI, screenWidth - spriteWidth, screenHeight - spriteHeight, r, 3, 3)
    end
    --end bottom--
  end
  --end background--
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
  enemy.speed = 140
  enemy.dead = false

  --random number used for spawn location--
  local side = math.random(1, 4)
  --sets actual pos for enemy spawn--
  if side == 1 then
    enemy.x = -30
    enemy.y = math.random(0, love.graphics.getHeight())
  elseif side == 2 then
    enemy.x = math.random(0, love.graphics.getWidth())
    enemy.y = -30
  elseif side == 3 then
    enemy.x = love.graphics.getWidth() + 30
    enemy.y = math.random(0, love.graphics.getHeight())
  else
    enemy.x = math.random(0, love.graphics.getWidth())
    enemy.y = love.graphics.getHeight() + 30
  end
  --adds to enemy table to enemies table--
  table.insert(enemies, enemy)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--attack button--
function love.mousepressed(x, y, button, isTouch)
  -- body...
  --sets left click to shoot button--
  if button == 1 and gameState == 2 then
    SpawnBullets()  --spawns bullets when left mouse is clicked--
  end
  --starts game when left mouse is clicked if game is at title screen--
  if gameState == 1 then
    gameState = 2
    maxtime = 2
    sTimer = maxTime
    score = 0
  end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--after direction keys are pressed reset player to idle when keys are released--
function love.keyreleased(key)
  if gameState == 1 then
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
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--gets player to mouse angle--
function PlayerMouseAngle()
  --3 math.pi / 2 is 270 degrees and -math.pi/2 subtracts 90 degrees--
  --calculates the angle in radians of which way the player should be shooting--
  return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function EnemyPlayerAngle(enemy)
  --3 math.pi / 2 is 270 degrees and -math.pi/2 subtracts 90 degrees--
  --calculates the angle in radians of which way the enemy should be rotated--
  return math.atan2(player.y - enemy.y, player.x - enemy.x) - math.pi / 2
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--gets distance from enemy to player and checks if it is inside/colliding--
function DistanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2-x1)^2)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function SpawnBullets()
  bullet = {}
  bullet.x = player.x  --posX--
  bullet.y = player.y  --posY--
  bullet.speed = 400  --speed--
  bullet.direction = PlayerMouseAngle()  --direction to shoot--
  bullet.dead = false  --are you dead?--

  --adds bullet table to bullets table--
  table.insert(bullets, bullet)
end
