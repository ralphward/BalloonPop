local composer = require( "composer" )
local scene = composer.newScene()
local CBE = require("CBE.CBE")

local widget = require( "widget" )
local json = require( "json" )
local utility = require( "utility" )
local physics = require( "physics" )
local myData = require( "mydata" )
local levelData = require( "leveldata" )
local vent = require( "vent")
local level_tips = require( "level_tips")

-- 
-- define local variables here
--
local currentScore          -- used to hold the numeric value of the current score
local currentScoreDisplay   -- will be a display.newText() that draws the score on the screen
local levelText             -- will be a display.newText() to let you know what level you're on
local topScore              -- will be used to store the best score for this level
local currentTopScore       -- will be a display.newText() that draws the to score on the screen
local curLevel              -- will be used to hold the current level
local isPaused = false
local timers = {}           -- Variable used to hold local scene timers
local enemies = {}          -- Variable used to hold enemies


local function killTimers()
    for i = 1, #timers do
        if timers[i] ~= nil then timer.cancel(timers[i]) end
    end        
    return true
end

local function removeEnemies()
    for i = 1, #enemies do
        if enemies[i] ~= nil then 
            enemies[i]:removeSelf() 
        end
    end        
    return true
end
function resetScore()

    currentScore = 0
    currentScoreDisplay.text = string.format( "%06d", currentScore )

    if myData.settings.levels[curLevel].topScore == nil then
        currentTopScore.text = string.format( "%06d", currentScore )
    else
        currentTopScore.text = string.format( "%06d", myData.settings.levels[curLevel].topScore )
        topScore = myData.settings.levels[curLevel].topScore
    end

    return true 
end

local function handleEnemyTouch( event )
    if event.phase == "began" then
        currentScore = currentScore + 10
        currentScoreDisplay.text = string.format( "%06d", currentScore )
        if currentScore > topScore then
            currentTopScore.text = string.format( "%06d", currentScore ) 
            topScore = currentScore
        end
        enemies[event.target.id]:removeSelf()
        enemies[event.target.id] = nil

        vent.emitX = event.x
        vent.emitY = event.y
        vent:start()
        
        return true
    end
end

local function spawnEnemy( event )
    local sceneGroup = scene.view  

    local params = event.source.params
    local enemy = display.newImage(params.image, params.xpos, -50)
    enemy.id = params.id
    sceneGroup:insert( enemy )
    physics.addBody( enemy, "dynamic" )
    enemy:addEventListener( "touch", handleEnemyTouch )

    enemies[enemy.id] = enemy
end


local function spawnEnemies()

    E = levelData:getLevel(curLevel)
    for i, enemies in ipairs(E) do        
        timers[#timers + 1]  = timer.performWithDelay( enemies.timerDelay , spawnEnemy, 1 )
        timers[#timers].params = {xpos = enemies.xpos,  xpos = enemies.xpos, image = enemies.image, id = i }
    end

end

local function handleRestart( event )
    if event.phase == "ended" then
        physics.pause()
        removeEnemies()
        isPaused = true
        killTimers()
        resetScore()
        spawnEnemies()
        physics.start()
    end
end

local function handlePause( event )

    if event.phase == "ended" then
        if isPaused == false then
            physics.pause()
            isPaused = true
        elseif isPaused == true then
            physics.start()
            isPaused = false
        end
    end

    return true
end

--
-- define local functions here
--
local function handleWin( event )

    if event.phase == "ended" then
        myData.settings.levels[curLevel].topScore = topScore
        myData.settings.currentLevel = curLevel + 1
        if myData.settings.unlockedLevels < myData.settings.currentLevel then
            myData.settings.unlockedLevels = myData.settings.currentLevel
        end
        utility.saveTable(myData.settings, "settings.json")
        composer.removeScene("nextlevel")
        composer.gotoScene("nextlevel", { time= 500, effect = "crossFade" })
    end
    return true
end

local function handleLoss( event )
    if event.phase == "ended" then
        composer.removeScene("gameover")
        composer.gotoScene("gameover", { time= 500, effect = "crossFade" })
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

    currentScoreDisplay = display.newText("000000", display.contentWidth - 50, 10, native.systemFont, 16 )
    sceneGroup:insert( currentScoreDisplay )

    currentTopScore = display.newText("000000", display.contentWidth - 50, 30, native.systemFont, 16 )
    sceneGroup:insert( currentTopScore )

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
    --
    -- Make a local reference to the scene's view for scene:show()
    --
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
        timers[#timers + 1] = timer.performWithDelay( 500, spawnEnemies )

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
        killTimers()
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

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
