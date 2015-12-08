local M = {}
local composer = require( "composer" )

local myData = require( "mydata" )
local gmData = require( "gamedata" )
local levelData = require( "leveldata" )
local CBE = require("CBE.CBE")
local vent = require( "vent")

local curLevel = myData.settings.currentLevel

function M:killTimers()

    for i, l_timer in pairs(gmData.timers) do    
        if l_timer ~= nil then timer.cancel(l_timer) end
    end

    return true
end

function M:removeEnemies()
    for i, l_enemy in pairs(gmData.g_enemies) do    
        -- this test is to avoid race time conditions where user may press restart level very quickly
        if (l_enemy.removeSelf) ~= nil then 
            l_enemy:removeSelf() 
        end
        if l_enemy ~= nil then 
            l_enemy = nil
        end
    end        

    return true
end

local function handleEnemyTouch( event )
    if event.phase == "began" then

        gmData.currentScore = gmData.currentScore + 10
        gmData.currentScoreDisplay.text = string.format( "%06d", gmData.currentScore )
        if gmData.currentScore > gmData.topScore then
            gmData.currentTopScore.text = string.format( "%06d", gmData.currentScore ) 
            gmData.topScore = gmData.currentScore
        end

        gmData.g_enemies[event.target.id]:removeSelf()
        gmData.g_enemies[event.target.id] = nil
        timer.cancel(gmData.timers[event.target.id])

        vent.emitX = event.x
        vent.emitY = event.y
        vent:start()
        
        return true
    end
end

local function destroyEnemy( event )
    gmData.g_enemies[event.source.params.id]:removeSelf()
    gmData.g_enemies[event.source.params.id] = nil
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

    gmData.g_enemies[enemy.id] = enemy
    gmData.timers[enemy.id] = timer.performWithDelay( 10000, destroyEnemy )
    gmData.timers[enemy.id].params = { id = enemy.id }
end

function M:spawnEnemies()

    E = levelData:getLevel(curLevel)
    for i, enemy in ipairs(E) do        
        gmData.timers["z"..enemy.id]  = timer.performWithDelay( enemy.timerDelay , spawnEnemy, 1 )
        gmData.timers["z"..enemy.id].params = { xpos = enemy.xpos, image = enemy.image, id = enemy.id }
    end

end

return M