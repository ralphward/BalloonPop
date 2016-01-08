local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local utility = require( "config.utility" )
local ads = require( "ads" )

local params

local function handlePlayButtonEvent( event )
    if ( "ended" == event.phase ) then
        composer.removeScene( "menu.levelselect", false )
        composer.gotoScene("menu.levelselect", { effect = "fromTop", time = 333 })
    end
end

local function handleSurvivalButtonEvent( event )
    if ( "ended" == event.phase ) then
        composer.removeScene( "menu.survival", false )
        composer.gotoScene("menu.survival", { effect = "fromTop", time = 333 })
    end
end

local function handleHelpButtonEvent( event )
    if ( "ended" == event.phase ) then
        composer.showOverlay("menu.help", { effect = "fromTop", time = 333, isModal = true })
    end
end

local function handleCreditsButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.showOverlay("menu.gamecredits", { effect = "fromTop", time = 333, isModal = true })
    end
end

local function handleSettingsButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.showOverlay("menu.gamesettings", { effect = "fromTop", time = 333, isModal = true })
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
    local playButton = widget.newButton({
        id = "button1",
        shape = "circle",
        fillColor = {default=blue_green, over=blue_green},
        label = "Play",
        width = 100,
        height = 32,
        onEvent = handlePlayButtonEvent
    })
    playButton.x = display.contentCenterX
    playButton.y = display.contentCenterY
    sceneGroup:insert( playButton )

    local surviveButton = widget.newButton({
        id = "button1",
        label = "Survival",
        shape = "circle",
        fillColor = {default=pink, over=pink},
        width = 100,
        height = 32,
        onEvent = handleSurvivalButtonEvent
    })
    surviveButton.x = display.contentCenterX / 2
    surviveButton.y = display.contentCenterY / 2
    sceneGroup:insert( surviveButton )

    -- Create the widget
    local settingsButton = widget.newButton({
        id = "button2",
        label = "Settings",
        shape = "circle",
        fillColor = {default=blue, over=blue},
        width = 100,
        height = 32,
        onEvent = handleSettingsButtonEvent
    })
    settingsButton.x = display.contentCenterX / 2
    settingsButton.y = display.contentCenterY * 1.5
    sceneGroup:insert( settingsButton )

    -- Create the widget
    local helpButton = widget.newButton({
        id = "button3",
        label = "Help",
        shape = "circle",
        fillColor = {default=yellow, over=yellow},
        width = 100,
        height = 32,
        onEvent = handleHelpButtonEvent
    })
    helpButton.x = display.contentCenterX * 1.5
    helpButton.y = display.contentCenterY / 2
    sceneGroup:insert( helpButton )

    -- Create the widget
    local creditsButton = widget.newButton({
        id = "button4",
        label = "Credits",
        shape = "circle",
        fillColor = {default=green, over=green},
        width = 100,
        height = 32,
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

    if event.phase == "did" then
        composer.removeScene( "game" ) 
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
