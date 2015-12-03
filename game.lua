local composer = require( "composer" )
local scene = composer.newScene()
local CBE = require("CBE.CBE")

local widget = require( "widget" )
local json = require( "json" )
local utility = require( "utility" )
local physics = require( "physics" )
local myData = require( "mydata" )
local levelData = require( "leveldata" )

-- 
-- define local variables here
--
local currentScore          -- used to hold the numeric value of the current score
local currentScoreDisplay   -- will be a display.newText() that draws the score on the screen
local levelText             -- will be a display.newText() to let you know what level you're on
local topScore              -- will be used to store the best score for this level
local currentTopScore       -- will be a display.newText() that draws the to score on the screen
local curLevel              -- will be used to hold the current level

local vent = CBE.newVent({
    preset = "fountain",
    title = "explosion",

    positionType = "inRadius",
    color = {{1, 0, 0}, {0.9, 0, 0}, {0.7, 0, 0}},
    particleProperties = {blendMode = "add"},
    emitX = display.contentCenterX,
    emitY = display.contentCenterY,

    emissionNum = 5,
    emitDelay = 5,
    perEmit = 1,

    inTime = 100,
    lifeTime = 0,
    outTime = 200,

    onCreation = function(particle)
        particle:changeColor({
            color = {0.1, 0.1, 0.1},
            time = 600
        })
    end,

    onUpdate = function(particle)
        particle:setCBEProperty("scaleRateX", particle:getCBEProperty("scaleRateX") * 0.998)
        particle:setCBEProperty("scaleRateY", particle:getCBEProperty("scaleRateY") * 0.998)
    end,

    physics = {
        velocity = 0,
        gravityY = 0,
        angles = {0, 360},
        scaleRateX = 1,
        scaleRateY = 1
    }
})


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

local function handleEnemyTouch( event )
    --
    -- When you touch the enemy:
    --    1. Increment the score
    --    2. Update the onscreen text that shows the score
    --    3. Kill the object touched
    --    4. Check the high score and update if necessary
    if event.phase == "began" then
        currentScore = currentScore + 10
        currentScoreDisplay.text = string.format( "%06d", currentScore )
        if currentScore > topScore then
            currentTopScore.text = string.format( "%06d", currentScore ) 
            topScore = currentScore
        end
        event.target:removeSelf()

        vent.emitX = event.x
        vent.emitY = event.y
        vent:start()
        
        return true
    end


end

local function spawnEnemy( event )
    -- make a local copy of the scene's display group.
    -- since this function isn't a member of the scene object,
    -- there is no "self" to use, so access it directly.
    local sceneGroup = scene.view  

    -- generate a starting position on the screen, y will be off screen
    local params = event.source.params
    local enemy = display.newImage(params.image, params.xpos, -50)
    sceneGroup:insert( enemy )
    --
    -- Add the physics body and the touch handler
    --
    physics.addBody( enemy, "kinematic" )
    --
    -- Since the touch handler is on an "object" and not the whole screen, 
    -- you don't need to remove it. When Composer hides the scene, it can't be
    -- interacted with and doesn't need removed. 
    -- when the scene is destroyed any display objects will be removed and that
    -- will remove this listener.
    enemy:addEventListener( "touch", handleEnemyTouch )

    -- Not needed in this implementation, but you may want to call spawnEnemy() to create one 
    -- and you might want to pass that enemy back to the caller.
    return enemy
end

local function spawnEnemies()
    --
    -- Spawn a new enemy every second until canceled.
    --
    E = levelData:getLevel(curLevel)
    for i, enemies in ipairs(E) do        
        local tm = timer.performWithDelay( enemies.timerDelay , spawnEnemy, 1 )
        tm.params = {xpos = enemies.xpos,  xpos = enemies.xpos, image = enemies.image }
    end

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
        timer.performWithDelay( 500, spawnEnemies )

    else -- event.phase == "will"
        -- The "will" phase happens before the scene transitions on screen.  This is a great
        -- place to "reset" things that might be reset, i.e. move an object back to its starting
        -- position. Since the scene isn't on screen yet, your users won't see things "jump" to new
        -- locations. In this case, reset the score to 0.
        currentScore = 0
        currentScoreDisplay.text = string.format( "%06d", currentScore )

        if myData.settings.levels[curLevel].topScore == nil then
            currentTopScore.text = string.format( "%06d", currentScore )
        else
            currentTopScore.text = string.format( "%06d", myData.settings.levels[curLevel].topScore )
            topScore = myData.settings.levels[curLevel].topScore
        end
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
