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

    physics.start()
    physics.pause()

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
