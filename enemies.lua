local M = {}
local composer = require( "composer" )

local myData = require( "mydata" )
local levelData = require( "leveldata" )
local CBE = require("CBE.CBE")
local vent = require( "vent")

local timers = {}           -- Variable used to hold local scene timers
local enemies = {}          -- Variable used to hold enemies
local curLevel = myData.settings.currentLevel

function M:killTimers()
    for i = 1, #timers do
        if timers[i] ~= nil then timer.cancel(timers[i]) end
    end        
    return true
end

function M:removeEnemies()
    for i = 1, #enemies do
        if enemies[i] ~= nil then 
            enemies[i]:removeSelf() 
            enemies[i] = nil
        end
    end        
    return true
end

local function handleEnemyTouch( event )
    if event.phase == "began" then

        --currentScore = currentScore + 10
        --currentScoreDisplay.text = string.format( "%06d", currentScore )
        --if currentScore > topScore then
            --currentTopScore.text = string.format( "%06d", currentScore ) 
            --topScore = currentScore
        --end
        enemies[event.target.id]:removeSelf()
        enemies[event.target.id] = nil

        vent.emitX = event.x
        vent.emitY = event.y
        vent:start()
        
        return true
    end
end

local function destroyEnemy( event )
    enemies[event.source.params.id]:removeSelf() 
    enemies[event.source.params.id] = nil
end

local function moveEnemies( event )
   local obj = event.source.objectID
   obj:setLinearVelocity( 0, 0 )
end

local function spawnEnemy( event )
    local scene = composer.getScene("game")
    local sceneGroup = scene.view  

    local params = event.source.params
    local enemy = display.newImage(params.image, params.xpos, -50)
    enemy.id = params.id
    sceneGroup:insert( enemy )
    physics.addBody( enemy, "kinematic" )
    enemy:setLinearVelocity( 0, 40 )

    enemy:addEventListener( "touch", handleEnemyTouch )

    enemies[enemy.id] = enemy

    timers[#timers + 1] = timer.performWithDelay( 10000, destroyEnemy )
    timers[#timers].params = {id = enemy.id}
end

function M:spawnEnemies()

    local numTimers = 1
    E = levelData:getLevel(curLevel)
    for i, enemies in ipairs(E) do        
        timers[numTimers]  = timer.performWithDelay( enemies.timerDelay , spawnEnemy, 1 )
        timers[numTimers].params = { xpos = enemies.xpos, image = enemies.image, id = i }
        numTimers = numTimers + 1
    end

end

return M