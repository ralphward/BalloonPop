local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local json = require( "json" )
local physics = require( "physics" )

local utility = require( "config.utility" )
local myData = require( "config.mydata" )

local gmData = require( "game.gamedata" )
local level_tips = require( "game.level_tips")
local enemies = require("game.enemies")
-- 
-- define local variables here
--
local levelText             -- will be a display.newText() to let you know what level you're on
local curLevel              -- will be used to hold the current level
local gm_timer              -- used for local game timer to start the game

-- projectile firing variables
local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cw, ch = display.contentWidth, display.contentHeight

local proj
local x0 = 60
local y0 = ch - 60
local ppm = 60 --pixel per metre
local line = {}

local xf, yf, vy, vx

function removeLine()
    for i, circ in pairs(line) do    
        -- this test is to avoid race time conditions where user may press restart level very quickly
        if (circ.removeSelf) ~= nil then 
            circ:removeSelf() 
        end
        if circ ~= nil then 
            circ = nil
        end
    end            
end

function removeProj()
    if proj ~= nil then 
        if (proj.removeSelf) ~= nil then 
            proj:removeSelf() 
        end
        proj = nil
    end    
end

function resetScore()

    gmData.currentScore = 0
    gmData.currentScoreDisplay.text = string.format( "%06d", gmData.currentScore )
    
    if curLevel > 0 then
        gmData.currentTopScore.text = string.format( "%06d", myData.settings.levels[curLevel].topScore )
        gmData.topScore = myData.settings.levels[curLevel].topScore
    elseif curLevel == -1 then
        gmData.currentTopScore.text = string.format( "%06d", myData.settings.survival[curLevel * -1].topScore )
        gmData.topScore = myData.settings.survival[curLevel * -1].topScore
    else
        gmData.currentTopScore.text = string.format( "%06d", myData.settings.survival[curLevel * -1].topScore )
        gmData.topScore = myData.settings.survival[curLevel * -1].topScore
    end

    return true 
end

local function handleRestart( event )
    if event.phase == "ended" and gmData.state == "playing" then
        local sceneGroup = scene.view  
        gmData.state = "restarting"
        physics.pause()
        enemies.killTimers()
        enemies.removeEnemies()
        removeLine()
        removeProj()
        gmData.fireState = 0
        resetScore()
        enemies.spawnEnemies()
        physics.start()
        gmData.state = "playing"
    end
end

local function handlePause( event )

    if event.phase == "ended" and gmData.state == "playing" then
        physics.pause()
        for i, l_timer in pairs(gmData.timers) do    
            if l_timer ~= nil then timer.pause(l_timer) end
        end            
        isPaused = true
        gmData.state = "paused"

        composer.showOverlay("game.pause", { effect = "fromTop", time = 333, isModal = true })
    end

    return true
end

--
-- define local functions here
--
local function handleWin( event )

    if event.phase == "ended" then
        if curLevel > 0 then
            myData.settings.levels[curLevel].topScore = gmData.topScore
            myData.settings.currentLevel = curLevel + 1
            if myData.settings.unlockedLevels < myData.settings.currentLevel then
                myData.settings.unlockedLevels = myData.settings.currentLevel
            end
            utility.saveTable(myData.settings, "settings.json")
            composer.removeScene("game.nextlevel")
            composer.gotoScene("game.nextlevel", { time= 500, effect = "crossFade" })
        else
            myData.settings.survival[curLevel * -1].topScore = gmData.topScore
            utility.saveTable(myData.settings, "settings.json")
            composer.removeScene("game.survivalover")
            composer.gotoScene("game.survivalover", { time= 500, effect = "crossFade" })
        end

    end
    return true
end

local function handleLoss( event )
    if event.phase == "ended" then
        if curLevel > 0 then
            composer.removeScene("game.gameover")
            composer.gotoScene("game.gameover", { time= 500, effect = "crossFade" })
        else
            composer.removeScene("game.survivalover")
            composer.gotoScene("game.survivalover", { time= 500, effect = "crossFade" })
        end
    end
    return true
end

local function getTrajectoryPoint( startingPosition, startingVelocity, n )
    --velocity and gravity are given per second but we want time step values here
    local t = 1/display.fps --seconds per time step at 60fps
    local stepVelocity = { x=t*startingVelocity.x, y=t*startingVelocity.y }  --b2Vec2 stepVelocity = t * startingVelocity
    local stepGravity = { x=t*0, y=t*9.8 }  --b2Vec2 stepGravity = t * t * m_world
    return {
        x = startingPosition.x + n * stepVelocity.x + 0.5 * (n*n+n) * stepGravity.x,
        y = startingPosition.y + n * stepVelocity.y + 0.5 * (n*n+n) * stepGravity.y
        }  --startingPosition + n * stepVelocity + 0.25 * (n*n+n) * stepGravity
end


local function updatePrediction( event )
    if (event.y < y0 and gmData.state == "playing") then
        local sceneGroup = scene.view
        removeLine()

        xf = event.x
        yf = event.y

        local dy = (yf - y0) * ppm
        local dx = (xf - x0) * ppm
        local t = 1 / display.fps
        local a = t * t * -9.8

        vy = math.sqrt(2 * a * dy) * display.fps * -1
        vx = dx * math.sqrt(a / (2 * dy)) * display.fps

        local startingVelocity = { x=vx,  y=vy}
        
        for i = 1,180 do 
            local s = { x=x0, y=y0 }
            local trajectoryPosition = getTrajectoryPoint( s, startingVelocity, i ) -- b2Vec2 trajectoryPosition = getTrajectoryPoint( startingPosition, startingVelocity, i )
            line[i] = display.newCircle( trajectoryPosition.x, trajectoryPosition.y, 5 )
            sceneGroup:insert(line[i])
        end
        gmData.fireState = 1                
    end
end



local function fireProj( event )
    if (event.phase == "began" and gmData.fireState == 1 and gmData.state == "playing") then
        local sceneGroup = scene.view
        local collFilter = { categoryBits = 2, maskBits = 1}
        display.remove( prediction )  --remove dot group
        proj = display.newImageRect( "images/object.png", 64, 64 )
        physics.addBody( proj, { bounce=0.2, density=1.0, radius=14 , filter = collFilter} )
        proj.x, proj.y = x0, y0
        proj:setLinearVelocity( vx,vy )
        sceneGroup:insert(proj)

        -- limit projectiles to one per line, uncomment below
        --gmData.fireState = 0
        --removeLine
    end
end

local function screenTouch( event )
    if (event.phase == "began") then
        updatePrediction( event )
    end
    return true

end

--
-- This function gets called when composer.gotoScene() gets called an either:
--    a) the scene has never been visited before or
--    b) you called composer.removeScene() or composer.removeHidden() from some other
--       scene.  It's possible (and desirable in many cases) to call this once, but 
--       show it multiple times.
--
function scene:create( event )
    --
    -- self in this case is "scene", the scene object for this level. 
    -- Make a local copy of the scene's "view group" and call it "sceneGroup". 
    -- This is where you must insert everything (display.* objects only) that you want
    -- Composer to manage for you.
    local sceneGroup = self.view

    physics.start() ; physics.setGravity( 0,9.8 ) ; physics.setDrawMode( "normal" ) ; physics.setScale(ppm) ; physics.pause()

    curLevel = myData.settings.currentLevel

    --
    -- create your objects here
    --

    -- setup local background    
    local background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    background:setFillColor( 0.6, 0.7, 0.3 )
    sceneGroup:insert(background)

    levelText = display.newText(curLevel, 0, 0, native.systemFontBold, 48 )
    levelText:setFillColor( 0 )
    levelText.x = display.contentCenterX
    levelText.y = display.contentCenterY
    sceneGroup:insert( levelText )

    gmData.currentScoreDisplay = display.newText("000000", display.contentWidth - 50, 10, native.systemFont, 16 )
    sceneGroup:insert( gmData.currentScoreDisplay )

    gmData.currentTopScore = display.newText("000000", display.contentWidth - 50, 30, native.systemFont, 16 )
    sceneGroup:insert( gmData.currentTopScore )

    -- TODO:: Remove these buttons
    local iWin = widget.newButton({
        label = "I Win!",
        onEvent = handleWin
    })
    sceneGroup:insert(iWin)
    iWin.x = display.contentCenterX - 100
    iWin.y = display.contentHeight - 60

    local iLoose = widget.newButton({
        label = "I Loose!",
        onEvent = handleLoss
    })
    sceneGroup:insert(iLoose)
    iLoose.x = display.contentCenterX + 100
    iLoose.y = display.contentHeight - 60

    local pause = widget.newButton({
        defaultFile = "images/pause.png",
        onEvent = handlePause
    })
    sceneGroup:insert(pause)
    pause.x = display.contentCenterX - 100
    pause.y = display.contentHeight - 20

    local restart = widget.newButton({
        defaultFile = "images/restart.png",
        onEvent = handleRestart
    })
    sceneGroup:insert(restart)
    restart.x = display.contentCenterX - 140
    restart.y = display.contentHeight - 20

    local fire = widget.newButton({
        defaultFile = "images/pause.png",
        onEvent = fireProj
    })
    sceneGroup:insert(fire)
    fire.x = display.contentCenterX - 180
    fire.y = display.contentHeight - 20


end

--
-- This gets called twice, once before the scene is moved on screen and again once
-- afterwards as a result of calling composer.gotoScene()
--
function scene:show( event )
    local sceneGroup = self.view

    --
    -- event.phase == "did" happens after the scene has been transitioned on screen. 
    -- Here is where you start up things that need to start happening, such as timers,
    -- tranistions, physics, music playing, etc. 
    -- In this case, resume physics by calling physics.start()
    -- Fade out the levelText (i.e start a transition)
    -- Start up the enemy spawning engine after the levelText fades
    --
    if event.phase == "did" then
        physics.start()
        Runtime:addEventListener( "touch", screenTouch )
        transition.to( levelText, { time = 500, alpha = 0 } )
        gm_timer = timer.performWithDelay( 500, enemies.spawnEnemies )
        gmData.state = "playing"

    else -- event.phase == "will"
        -- The "will" phase happens before the scene transitions on screen.  This is a great
        -- place to "reset" things that might be reset, i.e. move an object back to its starting
        -- position. Since the scene isn't on screen yet, your users won't see things "jump" to new
        -- locations. In this case, reset the score to 0.
        resetScore()
    end
end

--
-- This function gets called everytime you call composer.gotoScene() from this module.
-- It will get called twice, once before we transition the scene off screen and once again 
-- after the scene is off screen.
function scene:hide( event )
    local sceneGroup = self.view
    
    if event.phase == "will" then
        -- The "will" phase happens before the scene is transitioned off screen. Stop
        -- anything you started elsewhere that could still be moving or triggering such as:
        -- Remove enterFrame listeners here
        -- stop timers, phsics, any audio playing
        --
        enemies.killTimers()
        display.remove( prediction )
        sceneGroup:remove( proj )
        Runtime:removeEventListener("touch", screenTouch)
        physics.stop()
    end

end

--
-- When you call composer.removeScene() from another module, composer will go through and
-- remove anything created with display.* and inserted into the scene's view group for you. In
-- many cases that's sufficent to remove your scene. 
--
-- But there may be somethings you loaded, like audio in scene:create() that won't be disposed for
-- you. This is where you dispose of those things.
-- In most cases there won't be much to do here.
function scene:destroy( event )
    local sceneGroup = self.view
    
end

function scene:resumeGame()
    --code to resume game
    physics.start()
    for i, l_timer in pairs(gmData.timers) do    
        if l_timer ~= nil then timer.resume(l_timer) end
    end            
    gmData.state = "playing"

end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene