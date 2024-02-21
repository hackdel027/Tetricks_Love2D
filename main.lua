io.stdout:setvbuf('no')
require('constants')

local racket
local bricks
local lives

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
  initializeRacket()
  initializeBricks()
  initializeLives()
  love.window.setTitle(TITLE)
  love.window.setMode(480, 640)
end
function love.update(dt)
 -- Fonction pour mettre à jour (appelée à chaque frame)
  if love.keyboard.isDown('left', 'a') and racket.x > 0 then
    racket.x = racket.x - (racket.speedX*dt)
  elseif love.keyboard.isDown('right', 'd') and racket.x + racket.width < WIN_WIDTH  then
    racket.x = racket.x + (racket.speedX*dt)
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
end

function love.keypressed(key)
end