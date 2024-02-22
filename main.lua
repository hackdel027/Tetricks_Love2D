io.stdout:setvbuf('no')
require('constants')

local racket
local bricks
local lives
local ball
local nbBricks = BRICKS_PER_COLUMN * BRICKS_PER_LINE

function initializeBall(racketHeight, racketY)
  ball = {} -- Initialisation variable pour la balle
  ball.width, ball.height = racketHeight * 0.75, racketHeight * 0.75 -- Taille
  ball.speedY = -DEFAULT_SPEED_BY -- Vitesse verticale
  ball.speedX = math.random(-DEFAULT_SPEED_BX, DEFAULT_SPEED_BX) --Vitesse horizontale
  ball.x = WIN_WIDTH / 2 - ball.width / 2 -- Position en abscisse
  ball.y = racketY - 2 * ball.height - ball.height / 2
end
function resetBall(racketY)
  ball.speedY = -DEFAULT_SPEED_BY -- Vitesse verticale
  ball.speedX = math.random(-DEFAULT_SPEED_BX, DEFAULT_SPEED_BX) --Vitesse horizontale
  ball.x = WIN_WIDTH / 2 - ball.width / 2 -- Position en abscisse
  ball.y = racketY - 2 * ball.height - ball.height / 2 -- Positionen ordonnée
end
function collideRect(rect1, rect2)
  if rect1.x < rect2.x + rect2.width and
    rect1.x + rect1.width > rect2.x and
    rect1.y < rect2.y + rect2.height and
    rect1.height + rect1.y > rect2.y then
      return true
  end
  return false
end
function initializeLives()
  lives = {}
  lives.COUNT = NBR_LIVES
  lives.img = love.graphics.newImage(PATH_ICON)
  lives.width, lives.height = lives.img:getDimensions()
end
function createBrick(line, column)
  local brick = {}
  brick.isNotBroken = true
  brick.width = WIN_WIDTH / BRICKS_PER_LINE - 5
  brick.height = WIN_HEIGHT / 35
  brick.x = 2.5 + (column-1) * (5+brick.width)
  brick.y = line * (WIN_HEIGHT/35+2.5)
  return brick
end

function initializeBricks()
  
  bricks = {}
  for line=1, BRICKS_PER_LINE do
    table.insert(bricks, {})
    for column=1, BRICKS_PER_COLUMN do
      local brick = createBrick(line, column)
      table.insert(bricks[line], brick)
    end
  end
end
function initializeRacket()
  racket = {}
  racket.speedX = 215
  racket.width = WIN_WIDTH / 4
  racket.height = WIN_HEIGHT / 37
  racket.x = (WIN_WIDTH-racket.width) / 2
  racket.y = WIN_HEIGHT - 64

end
function love.load()
 -- Fonction pour initialiser le jeu (appelée au début de celui-ci)
  math.randomseed(love.timer.getTime())  
  initializeRacket()
  initializeBricks()
  initializeLives()
  initializeBall(racket.height, racket.y)
  love.window.setTitle(TITLE)
  love.window.setMode(480, 640)
end
function collisionBallWithBrick(ball, brick)
  -- Collision côté gauche brique
  if ball.x < brick.x and ball.speedX > 0 then
    ball.speedX = -ball.speedX
  -- Collision côté droit brique
  elseif ball.x > brick.x + brick.width and ball.speedX < 0 then
    ball.speedX = -ball.speedX
  end
  -- collision haut brique
  if ball.y < brick.y and ball.speedY > 0 then
    ball.speedY = -ball.speedY
  -- Collision bas brique
  elseif ball.y > brick.y and ball.speedY < 0 then
    ball.speedY = -ball.speedY
  end  
  brick.isNotBroken = false
  nbBricks = nbBricks - 1
end
  function collisionBallWithRacket()
  -- Collision par la gauche (coin haut inclus)
  if ball.x < racket.x + 1/8 * racket.width and ball.speedX >= 0 then
    if ball.speedX <= DEFAULT_SPEED_BX/2 then -- Si vitesse trop faible
      ball.speedX = -math.random(0.75*DEFAULT_SPEED_BX,
      DEFAULT_SPEED_BX) -- Nouvelle vitesse
    else
      ball.speedX = -ball.speedX
    end
  -- Collision par la droite (coin haut inclus)
  elseif ball.x > racket.x + 7/8 * racket.width and ball.speedX <= 0 then
    if ball.speedX >= -DEFAULT_SPEED_BX/2 then -- Si vitesse trop faible
      ball.speedX = math.random(0.75*DEFAULT_SPEED_BX,
      DEFAULT_SPEED_BX) -- Nouvelle vitesse
    else
      ball.speedX = -ball.speedX
    end
  end
  -- Collision par le haut
  if ball.y < racket.y and ball.speedY > 0 then
    ball.speedY = -ball.speedY
  end
end
  
function love.update(dt)
 -- Fonction pour mettre à jour (appelée à chaque frame)
  if love.keyboard.isDown('left', 'a') and racket.x > 0 then
    racket.x = racket.x - (racket.speedX*dt)
  elseif love.keyboard.isDown('right', 'd') and racket.x + racket.width < WIN_WIDTH  then
    racket.x = racket.x + (racket.speedX*dt)
  end
  ball.x = ball.x + ball.speedX * dt -- Mise à jour position en
  ball.y = ball.y + ball.speedY * dt -- Mise à jour position en
  if ball.x + ball.width >= WIN_WIDTH then -- Bordure droite
    ball.speedX = -ball.speedX
  elseif ball.x <= 0 then -- Bordure gauche
    ball.speedX = -ball.speedX
  end
  if ball.y <= 0 then -- Bordure haut
    ball.speedY = -ball.speedY
  elseif ball.y + ball.height >= WIN_HEIGHT then -- Bordure bas
    lives.COUNT = lives.COUNT - 1
    resetBall(racket.y)
  end
  if collideRect(ball, racket) then
    collisionBallWithRacket() -- Collision entre la balle et la raquette
  end
  for line=#bricks, 1, -1 do
    for column=#bricks[line], 1, -1 do
      if bricks[line][column].isNotBroken and collideRect(ball,
        bricks[line][column]) then
        collisionBallWithBrick(ball, bricks[line][column]) --Collision entre la balle et une brique
      end
    end
  end
end
function love.draw()
 -- Fonction pour dessiner (appelée à chaque frame)
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('fill', racket.x, racket.y, racket.width, racket.height)
  for line=1, #bricks do
    for column=1, #bricks[line] do
      local brick = bricks[line][column]
      if brick.isNotBroken then
        love.graphics.rectangle('fill', brick.x, brick.y, brick.width, brick.height)
      end
    end
  end
  for i=0, lives.COUNT-1 do
    local posX = 5 + i * 1.20 * 20
    love.graphics.rectangle('fill', posX, WIN_HEIGHT-20, 20, 20)
  end
  love.graphics.rectangle('fill', ball.x, ball.y, ball.width, ball.height)
end

function love.keypressed(key)
end