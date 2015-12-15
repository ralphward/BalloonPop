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

local prediction = display.newGroup() ; prediction.alpha = 0.2
local proj
local line
local xStartPos = 60
local yStartPos = ch - 60

local xEndPos
local yEndPos


function resetScore()

    gmData.currentScore = 0
    gmData.currentScoreDisplay.text = string.format( "%06d", gmData.currentScore )

    if myData.settings.levels[curLevel].topScore == nil then
        gmData.currentTopScore.text = string.format( "%06d", gmData.currentScore )
    else
        gmData.currentTopScore.text = string.format( "%06d", myData.settings.levels[curLevel].topScore )
        gmData.topScore = myData.settings.levels[curLevel].topScore
    end

    return true 
end

local function handleRestart( event )
    if event.phase == "ended" and gmData.state == "playing" then
        gmData.state = "restarting"
        physics.pause()
        enemies.killTimers()
        enemies.removeEnemies()
        display.remove( prediction )
        display.remove( proj )
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
        display.remove( prediction )
        display.remove( proj )
        gmData.fireState = 0
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
        myData.settings.levels[curLevel].topScore = gmData.topScore
        myData.settings.currentLevel = curLevel + 1
        if myData.settings.unlockedLevels < myData.settings.currentLevel then
            myData.settings.unlockedLevels = myData.settings.currentLevel
        end
        utility.saveTable(myData.settings, "settings.json")
        composer.removeScene("game.nextlevel")
        composer.gotoScene("game.nextlevel", { time= 500, effect = "crossFade" })
    end
    return true
end

local function handleLoss( event )
    if event.phase == "ended" then
        composer.removeScene("game.gameover")
        composer.gotoScene("game.gameover", { time= 500, effect = "crossFade" })
    end
    return true
end

local function getTrajectoryPoint( startingPosition, startingVelocity, n )

    --velocity and gravity are given per second but we want time step values here
    local t = 1/display.fps --seconds per time step at 60fps
    local stepVelocity = { x=t*startingVelocity.x, y=t*startingVelocity.y }  --b2Vec2 stepVelocity = t * startingVelocity
    local stepGravity = { x=t*0, y=t*9.8 }  --b2Vec2 stepGravity = t * t * m_world
    return {
        x = startingPosition.x + n * stepVelocity.x + 0.25 * (n*n+n) * stepGravity.x,
        y = startingPosition.y + n * stepVelocity.y + 0.25 * (n*n+n) * stepGravity.y
        }  --startingPosition + n * stepVelocity + 0.25 * (n*n+n) * stepGravity
end

local function calculateVerticalVelocityForHeight( desiredHeight )
    if ( desiredHeight <= 0 ) then
        return 0
    end
  
    --gravity is given per second but we want time step values here
    local t = 1 / display.fps
    local stepGravity = t * t * -9.8

    print("step gravity" .. stepGravity)

    --quadratic equation setup (ax² + bx + c = 0)
    local a = 0.5 / stepGravity
    local b = 0.5
    local c = desiredHeight

    print (" a b c " .. a .. " " .. b .. " " .. c)

    --check both possible solutions
    local quadraticSolution1 = ( -b - math.sqrt( b*b - 4*a*c ) ) / (2*a);
    local quadraticSolution2 = ( -b + math.sqrt( b*b - 4*a*c ) ) / (2*a);

    print( b*b - 4*a*c )

    --use the one which is positive
    local v = quadraticSolution1;
    if ( v < 0 ) then
        v = quadraticSolution2
    end
  
    --convert answer back to seconds
    return v * 60

end



local function updatePrediction( event )

--[[
    -- given vertex and another point find the parabola formula
    -- y=a(x−h)2+k
    local y, a, x, h, k, xh
    h = xEndPos   
    k = yEndPos
    x = xStartPos
    y = yStartPos

    --h = -2
    --k = -2
    --x = -1
    --y = 1

    -- solve for a
    xh = (x - h) * (x - h)
    y = y + (k * -1)
    a = y / xh

    -- convert to quadratic formula
    -- y = ax^2 + bx + c
    local b, c
    b = -2 * a * h
    c = a * (h * h) + k

    print (" a b c " .. a .. " " .. b .. " " .. c)
    -- find velocity and angle from quadratic forumula and plug into startingVelocity

    --local height = calculateVerticalVelocityForHeight(yStartPos - event.y)
    
    --print ("height " .. height)
]]--
    display.remove( prediction )  --remove dot group
    prediction = display.newGroup() ; prediction.alpha = 0.2  --now recreate it
    xEndPos = event.x
    yEndPos = event.y

    --xEndPos = 280
    --yEndPos = 120
    xStartPos = 60
    yStartPos = 260

    local distance = yEndPos - yStartPos 
    print ("distance " .. distance) 
    
    local a = 9.8 
    local v = math.sqrt(2 * a * distance)
    v = v * -1

    --local height = (calculateVerticalVelocityForHeight(distance * -1) + yStartPos) * -1


    print ("V0 " .. v)
    --print ("V0" .. height)
    print ("Start: (" .. xStartPos .. "," .. yStartPos .. ")")
    print ("Vertex: (" .. xEndPos .. "," .. yEndPos .. ")")
    print ("")

    --local startingVelocity = { x=xEndPos-xStartPos,  y=v}
    --local startingVelocity = { x=0,  y=v}
    local startingVelocity = { x=(event.x-xStartPos) * 1.2,  y=(event.y - yStartPos) * 2.2}
    
    for i = 1,180 do 
        local s = { x=xStartPos, y=yStartPos }
        local trajectoryPosition = getTrajectoryPoint( s, startingVelocity, i ) -- b2Vec2 trajectoryPosition = getTrajectoryPoint( startingPosition, startingVelocity, i )
        local circ = display.newCircle( prediction, trajectoryPosition.x, trajectoryPosition.y, 5 )
    end
end



local function fireProj( event )
    
    proj = display.newImageRect( "images/object.png", 64, 64 )
    physics.addBody( proj, { bounce=0.2, density=1.0, radius=14 } )
    proj.x, proj.y = xStartPos, yStartPos
    local vx, vy = xEndPos-xStartPos, yEndPos-yStartPos
    proj:setLinearVelocity( vx,vy )

end

local function screenTouch( event )

    if (gmData.fireState == 0 and event.phase == "began") then
        updatePrediction( event )
        gmData.fireState = 1
    elseif (event.phase == "began") then
        fireProj( event )
        gmData.fireState = 0
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

    physics.start() ; physics.setGravity( 0,9.8 ) ; physics.setDrawMode( "normal" ) ; physics.pause()

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

    local pause = widget.newButton({
        defaultFile = "images/restart.png",
        onEvent = handleRestart
    })
    sceneGroup:insert(pause)
    pause.x = display.contentCenterX - 140
    pause.y = display.contentHeight - 20


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
        display.remove( proj )
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