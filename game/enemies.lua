local M = {}
local composer = require( "composer" )

local myData = require( "config.mydata" )
local gmData = require( "game.gamedata" )
local levelData = require( "game.leveldata" )
local CBE = require("CBE.CBE")
local vent = require( "game.vent")

local curLevel = myData.settings.currentLevel
local enemy_count_id = 0

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
    if gmData.state == "playing" then

        gmData.currentScore = gmData.currentScore + 10
        gmData.currentScoreDisplay.text = string.format( "%06d", gmData.currentScore )
        if gmData.currentScore > gmData.topScore then
            gmData.currentTopScore.text = string.format( "%06d", gmData.currentScore ) 
            gmData.topScore = gmData.currentScore
        end

        gmData.g_enemies[event.target.id]:removeSelf()
        gmData.g_enemies[event.target.id] = nil
        timer.cancel(gmData.timers[event.target.id])

        vent.emitX = event.target.x
        vent.emitY = event.target.y
        vent:start()
        
        return true
    end
end

local function destroyEnemy( event )
    gmData.g_enemies[event.source.params.id]:removeSelf()
    gmData.g_enemies[event.source.params.id] = nil
end

local function spawnEnemy( event )
    local scene = composer.getScene("game.game")
    local sceneGroup = scene.view  

    local collFilter = { categoryBits = 1, maskBits = 2}

    local params = event.source.params.artifact
    if curLevel < 0 then
        params.xpos = math.random(50, 400)
        print(params.xpos)
    end

    local enemy = display.newImage(params.image, params.xpos, -50)
    if (curLevel > 0 ) then
        enemy.id = params.id
    else
        enemy.id = enemy_count_id .. params.id
        enemy_count_id = enemy_count_id + 1
    end
    
    sceneGroup:insert( enemy )
    physics.addBody( enemy, "dynamic", { filter = collFilter})
    enemy.gravityScale = 0
    enemy:setLinearVelocity( 0, 40 )

    enemy:addEventListener( "collision", handleEnemyTouch )

    gmData.g_enemies[enemy.id] = enemy
    gmData.timers[enemy.id] = timer.performWithDelay( 10000, destroyEnemy )
    gmData.timers[enemy.id].params = { id = enemy.id }
end

function M:spawnEnemies()

    curLevel = myData.settings.currentLevel

    E = levelData:getLevel(curLevel)
    for i, enemy in ipairs(E) do        
        gmData.timers["z"..enemy.id]  = timer.performWithDelay( enemy.timerDelay , spawnEnemy, enemy.rep_number )
        gmData.timers["z"..enemy.id].params = { artifact = enemy }
    end
    if curLevel < 0 then
        --gmData.timers["wave"] = timer.performWithDelay(1000, spawnRandomEnemy, 0)
    end

end


return M