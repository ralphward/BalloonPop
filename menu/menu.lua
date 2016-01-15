local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local utility = require( "config.utility" )
local ads = require( "ads" )

local params

local playButton
local creditsButton
local helpButton
local surviveButton
local settingsButton

local function playEvent(event)
    composer.removeScene( event.source.params.sceneName, false )
    composer.gotoScene(event.source.params.sceneName)
end

local function handlePlayButtonEvent( event )
    if ( "ended" == event.phase ) then
        event.target:setLabel("")
        event.target:toFront()
        transition.to(event.target, {time=333, xScale=10, yScale=10})
        local tm = timer.performWithDelay(333, playEvent)
        tm.params = {sceneName = "menu.levelselect"}
    end
end

local function handleSurvivalButtonEvent( event )
    if ( "ended" == event.phase ) then
        event.target:setLabel("")
        event.target:toFront()
        transition.to(event.target, {time=333, xScale=10, yScale=10})
        local tm = timer.performWithDelay(333, playEvent)
        tm.params = {sceneName = "menu.survival"}
    end
end

local function handleHelpButtonEvent( event )
    if ( "ended" == event.phase ) then
        event.target:setLabel("")
        event.target:toFront()
        transition.to(event.target, {time=333, xScale=10, yScale=10})
        local tm = timer.performWithDelay(333, playEvent)
        tm.params = {sceneName = "menu.help"}
    end
end

local function handleCreditsButtonEvent( event )

    if ( "ended" == event.phase ) then
        event.target:setLabel("")
        event.target:toFront()
        transition.to(event.target, {time=333, xScale=10, yScale=10})
        local tm = timer.performWithDelay(333, playEvent)
        tm.params = {sceneName = "menu.gamecredits"}
    end
end

local function handleSettingsButtonEvent( event )

    if ( "ended" == event.phase ) then
        event.target:setLabel("")
        event.target:toFront()
        transition.to(event.target, {time=333, xScale=10, yScale=10})
        local tm = timer.performWithDelay(333, playEvent)
        tm.params = {sceneName = "menu.gamesettings"}
    end
end

--
-- Start the composer event handlers
--
function scene:create( event )
    local sceneGroup = self.view

    params = event.params
        
    --
    -- setup a page background, really not that important though composer
    -- crashes out if there isn't a display object in the view.
    --
    local purple = {40/255, 20/255, 63/255}
    local blue_green = {17/255, 205/255, 197/255}
    local blue = {74/255, 144/255, 226/255}
    local pink = {252/255, 45/255, 121/255}
    local yellow = {252/255, 182/255, 53/255}
    local green = {85/255, 200/255, 85/255}

    local background = display.newRect( 0, 0, 570, 360 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background.fill = purple
    sceneGroup:insert( background )

    -- Create the widget
    playButton = widget.newButton({
        id = "button1",
        shape = "circle",
        fillColor = {default=blue_green, over=blue_green},
        label = "Play",
        radius = 50,
        onEvent = handlePlayButtonEvent
    })
    playButton.x = display.contentCenterX
    playButton.y = display.contentCenterY

    sceneGroup:insert( playButton )

    surviveButton = widget.newButton({
        id = "button1",
        label = "Survival",
        shape = "circle",
        fillColor = {default=pink, over=pink},
        radius = 50,
        onEvent = handleSurvivalButtonEvent
    })
    surviveButton.x = display.contentCenterX / 2
    surviveButton.y = display.contentCenterY / 2

    sceneGroup:insert( surviveButton )

    -- Create the widget
    settingsButton = widget.newButton({
        id = "button2",
        label = "Settings",
        shape = "circle",
        fillColor = {default=blue, over=blue},
        radius = 50,
        onEvent = handleSettingsButtonEvent
    })
    settingsButton.x = display.contentCenterX / 2
    settingsButton.y = display.contentCenterY * 1.5

    sceneGroup:insert( settingsButton )

    -- Create the widget
    helpButton = widget.newButton({
        id = "button3",
        label = "Help",
        shape = "circle",
        fillColor = {default=yellow, over=yellow},
        radius = 50,
        onEvent = handleHelpButtonEvent
    })
    helpButton.x = display.contentCenterX * 1.5
    helpButton.y = display.contentCenterY / 2

    sceneGroup:insert( helpButton )

    -- Create the widget
    creditsButton = widget.newButton({
        id = "button4",
        label = "Credits",
        shape = "circle",
        fillColor = {default=green, over=green},
        radius = 50,
        onEvent = handleCreditsButtonEvent
    })
    creditsButton.x = display.contentCenterX * 1.5
    creditsButton.y = display.contentCenterY * 1.5

    sceneGroup:insert( creditsButton )

end

function scene:show( event )
    local sceneGroup = self.view

    params = event.params
    utility.print_r(event)

    if params then
        print(params.someKey)
        print(params.someOtherKey)
    end
    if event.phase == "will" then
        if event.params == nil then
            playButton:setLabel("Play")
            playButton.xScale = 0.1
            playButton.yScale = 0.1

            surviveButton:setLabel("Survival")
            surviveButton.xScale = 0.01
            surviveButton.yScale = 0.01

            settingsButton:setLabel("Settings")
            settingsButton.xScale = 0.01
            settingsButton.yScale = 0.01

            helpButton:setLabel("Help")
            helpButton.xScale = 0.01
            helpButton.yScale = 0.01

            creditsButton:setLabel("Credits")
            creditsButton.xScale = 0.01
            creditsButton.yScale = 0.01
        elseif event.params.from == "survival" then
            surviveButton:setLabel("")
            surviveButton.xScale = 10
            surviveButton.yScale = 10            
        end            
    elseif event.phase == "did" then
        composer.removeScene( "game" ) 

        if event.params == nil then
            transition.to(playButton, {time=600, xScale=1, yScale=1, transition=easing.outBounce})
            transition.to(surviveButton, {time=600, delay=100, xScale=1, yScale=1, transition=easing.outBounce})
            transition.to(settingsButton, {time=600, delay=200, xScale=1, yScale=1, transition=easing.outBounce})
            transition.to(helpButton, {time=600, delay=300, xScale=1, yScale=1, transition=easing.outBounce})
            transition.to(creditsButton, {time=600, delay=400,  xScale=1, yScale=1, transition=easing.outBounce})
        elseif event.params.from == "survival" then
            surviveButton:toFront()
            transition.to(surviveButton, {time=600, delay=100, xScale=1, yScale=1, transition=easing.outBounce})
        end
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    
    if event.phase == "will" then
    end

end

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
