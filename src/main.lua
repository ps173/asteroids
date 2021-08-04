function love.load()

    font = love.graphics.newFont(16)

    bullets = {}
    bulletRadius = 5
    arenaWidth = 1280
    arenaHeight = 720
    score = 0

    shipRadius = 30
    shipX = arenaWidth / 2
    shipY = arenaHeight / 2
    shipAngle = 0
    shipSpeedX = 0
    shipSpeedY = 0


    asteroids = {
        {
            x = 100,
            y = 100,
        },
        {
            x = arenaWidth - 100,
            y = 100,
        },
        {
            x = arenaWidth / 2,
            y = arenaHeight - 100,
        },
        {
            x = 200,
            y = 400,
        },
    }

    asteroidStages = {
        {
            speed = 120,
            radius = 15,
            red = 224/255, 
            blue = 242/255,
            green = 29/255,
        },
        {
            speed = 50,
            radius = 50,
            red = 66/255, 
            blue =  179/255,
            green =245/255,
        },
        {
            speed = 50,
            radius = 50,
            red = 91/255, 
            blue = 235/255,
            green = 156/255,
        },
        {
            speed = 20,
            radius = 80,
            red = 126/255, 
            blue = 245/255,
            green = 66/255,
        }
    }

    for asteroidIndex, asteroid in ipairs(asteroids) do
        asteroid.angle = love.math.random() * (2 * math.pi)
        asteroid.stage = #asteroidStages
    end

end

function love.update(dt)
    local turnSpeed = 10

    if #asteroids == 0 then
        love.load()
    end

    local function areCirclesIntersecting(aX, aY, aRadius, bX, bY, bRadius)
        return (aX - bX)^2 + (aY - bY)^2 <= (aRadius + bRadius)^2
    end

    -- asteroid movement
    for asteroidIndex, asteroid in ipairs(asteroids) do

        asteroid.x = (asteroid.x + math.cos(asteroid.angle)
            * asteroidStages[asteroid.stage].speed * dt) % arenaWidth
        asteroid.y = (asteroid.y + math.sin(asteroid.angle)
            * asteroidStages[asteroid.stage].speed * dt) % arenaHeight

       if areCirclesIntersecting( shipX, shipY, shipRadius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius ) then
            love.load()
            break
        end
    end

    if love.keyboard.isDown('up') then
        local shipSpeed = 100
        shipSpeedX = shipSpeedX + math.cos(shipAngle) * shipSpeed * dt
        shipSpeedY = shipSpeedY + math.sin(shipAngle) * shipSpeed * dt
    end

    if love.keyboard.isDown('right') then
         shipAngle = shipAngle + turnSpeed * dt
    end

    if love.keyboard.isDown('left') then
         shipAngle = shipAngle - turnSpeed * dt
    end

    for bulletIndex, bullet in ipairs(bullets) do
        for bulletIndex = #bullets, 1, -1 do
            local bullet = bullets[bulletIndex]

            -- every bullet when generated carries a timer with it
            bullet.timeLeft = bullet.timeLeft - dt

            if bullet.timeLeft <= 0 then
                table.remove(bullets, bulletIndex)
            else
                local bulletSpeed = 300
                bullet.x = (bullet.x + math.cos(bullet.angle) * bulletSpeed * dt)
                    % arenaWidth
                bullet.y = (bullet.y + math.sin(bullet.angle) * bulletSpeed * dt)
                    % arenaHeight
            end

            for asteroidIndex = #asteroids, 1, -1 do
                local asteroid = asteroids[asteroidIndex]

                if areCirclesIntersecting( bullet.x, bullet.y, bulletRadius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
                    table.remove(bullets, bulletIndex)
                    if asteroid.stage > 1 then
                        local angle1 = love.math.random() * (2 * math.pi)
                        local angle2 = (angle1 - math.pi) % (2 * math.pi)

                        table.insert(asteroids, {
                            x = asteroid.x,
                            y = asteroid.y,
                            angle = angle1,
                            stage = asteroid.stage - 1,
                        })
                        table.insert(asteroids, {
                            x = asteroid.x,
                            y = asteroid.y,
                            angle = angle2,
                            stage = asteroid.stage - 1,
                        })
                    end
                    table.remove(asteroids, asteroidIndex)
                    score = score + 1
                    break
                end
            end
        end
    end

    shipAngle = shipAngle % (2 * math.pi)
    shipX = shipX + shipSpeedX * dt
    shipY = shipY + shipSpeedY * dt

    shipX = (shipX + shipSpeedX * dt) % arenaWidth
    shipY = (shipY + shipSpeedY * dt) % arenaHeight

end



function love.draw()
    love.graphics.setFont(font)

    for y = -1, 1 do
        for x = -1, 1 do
            love.graphics.origin()
            love.graphics.translate(x * arenaWidth, y * arenaHeight)
            love.graphics.setColor(0, 0, 1)
            love.graphics.circle('fill', shipX, shipY, shipRadius)

            local shipCircleDistance = 20
            love.graphics.setColor(0, 1, 1)
            love.graphics.circle(
               'fill',
               shipX + math.cos(shipAngle) * shipCircleDistance,
               shipY + math.sin(shipAngle) * shipCircleDistance,
               5
            )       

            love.graphics.setColor(1, 1, 1)
            love.graphics.print("score : ".. score, 100 , 10)

            love.graphics.setColor(1, 1, 1)
            love.graphics.print("press q to quit", 600 , 10)
            love.graphics.print("press s to shoot", 800 , 10)
            love.graphics.print("use arrow-keys to move ", 800 , 30)

            for bulletIndex, bullet in ipairs(bullets) do
                love.graphics.setColor(245/255, 67/255, 47/255)
                love.graphics.circle('fill', bullet.x, bullet.y, bulletRadius)
            end

            for asteroidIndex, asteroid in ipairs(asteroids) do
                -- bit more colored asteroids
                love.graphics.setColor(asteroidStages[asteroid.stage].red, 
                                       asteroidStages[asteroid.stage].green, 
                                       asteroidStages[asteroid.stage].blue
                                       )
                love.graphics.circle('fill', asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius)
            end

        end
    end

end

function love.keypressed(key,unicode)
    if key=="q" then
        love.event.quit()
    end

    if key == 's' then
        table.insert(bullets, {
            x = shipX + math.cos(shipAngle) * shipRadius,
            y = shipY + math.sin(shipAngle) * shipRadius,
            angle = shipAngle,
            timeLeft = 4,
        })
    end

end
