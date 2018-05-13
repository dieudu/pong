Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_HEIGHT = 432
WINDOW_WIDTH = 243

PADDLE_SPEED = 200


function love.load()
    love.window.setMode(
        WINDOW_WIDTH,
        WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = false}
    )
    
    sounds = {
        ['lbounce'] = love.audio.newSource('sounds/bounce.wav', 'static'),
        ['rbounce'] = love.audio.newSource('sounds/bounce1.wav', 'static'),
        ['wbounce'] = love.audio.newSource('sounds/bounce2.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static')
    }
    
    love.window.setTitle("Pongity")
    player1 = Paddle(10, WINDOW_HEIGHT/2 - 25, 5, 50)
    player2 = Paddle(WINDOW_WIDTH - 15, WINDOW_HEIGHT/2 - 25, 5, 50)
    
    love.keyboard.setKeyRepeat(true)
    smallFont = love.graphics.newFont("font.ttf", 8)
    scoreFont = love.graphics.newFont("font.ttf", 24)
    math.randomseed(os.time())
    
    ball = Ball(WINDOW_WIDTH/2 - 5, WINDOW_HEIGHT/2 - 5, 10, 10)
    
    ballDX = math.random(2) == 1 and 100 or -100
    ballDY = math.random(-50, 50)
    
    gameState = "start"
    servingPlayer = player1
    reaction = 80
    
    
end

function love.update(dt)
    if love.keyboard.isDown('w')then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
        player2.dy = 0
    end
    
    
    if gameState == 'play' then
        ball:update(dt)
        if (ball.x < 0) then
            player2:gainScore()
            ball:reset()
            servingPlayer = player1
            if player2.score > 5 then
                gameState = 'gameOver'
            else
                gameState = 'serving'
                reaction = 80
            end
            
            love.audio.play(sounds.score)
            player1:reset()
            player2:reset()
        elseif (ball.x > WINDOW_WIDTH) then
            player1:gainScore()
            ball:reset()
            servingPlayer = player2
           
            gameState = 'serving'
            reaction = 80
            love.audio.play(sounds.score)
            player1:reset()
            player2:reset()
        end
        
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 10
            
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150) + (player1.dy * math.random(0, 20) * .02)
            else
                ball.dy = math.random(10, 150) + (player1.dy * math.random(0, 20) * .02)
            end
            
        reaction = math.max(20, reaction - 2)
        love.audio.play(sounds.lbounce)
        end
        
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 10
            
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            
        reaction = math.max(20, reaction - math.random(0, 4))
        sounds['rbounce']:play()
        end
        
        if ball.y < 0 then
            ball.dy = -ball.dy
            ball.y = 0
            love.audio.play(sounds.wbounce)
        elseif ball.y > WINDOW_HEIGHT - ball.height then
            ball.dy = -ball.dy
            ball.y = WINDOW_HEIGHT - ball.height             
            love.audio.play(sounds.wbounce)
        end
        
        if math.random(0, 100) < reaction then
            if ball.y + ball.height/2 < player2.y + (player2.height / 2) then
                player2.dy = -PADDLE_SPEED
            elseif ball.y  + ball.height/2 > player2.y + (player2.height / 2) then
                player2.dy = PADDLE_SPEED
            else
                player2.dy = 0
            end
        end
        
    elseif gameState == 'serving' then
        if servingPlayer == player1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    end
    
    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serving'
            ball:reset()
        elseif gameState == 'serving' then
            gameState = 'play'
        elseif gameState == 'gameOver' then
            gameState = 'start'
            player1.score = 0
            player2.score = 0
            player1:reset()
            player2:reset()
        end
    end
end

function love.draw()
    -- draw title
    love.graphics.setFont(smallFont)
    love.graphics.print("Pongity by Dieu Du", 10, 10)
    love.graphics.print(reaction, 10, 20)
    if gameState == 'gameOver' then
        love.graphics.setFont(scoreFont)
        love.graphics.print("SCORE: " .. tostring(player1.score), WINDOW_WIDTH/2 - 50, WINDOW_HEIGHT/2 - 50)
    else
        -- draw scores
        love.graphics.setFont(scoreFont)
        love.graphics.print(player1.score, 40, 30)
        love.graphics.print(player2.score, WINDOW_WIDTH - 40, 30)
    
        -- draw left paddle
        player1:render()
    
        -- draw right paddle
        player2:render()
    
        -- draw ball
        ball:render()
    
        if gameState == 'serving' then
            love.graphics.setFont(scoreFont)
            love.graphics.print("NOW SERVING", WINDOW_WIDTH/2 - 75, 50)
        end
    end
    
    displayFPS()
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 200, 10)
end