local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local utility = require( "config.utility" )
local myData = require( "config.mydata" )

local params

local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.removeScene( "menu.menu", false )
        composer.gotoScene( "menu.menu", { effect = "slideUp", time = 333 } )
    end
end

local function handlePlayEvent( event )

    if ( "ended" == event.phase ) then
        myData.settings.currentLevel = event.target.id
        composer.removeScene( "game.game", false )
        composer.gotoScene( "game.game", { effect = "crossFade", time = 333 } )
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
    local background = display.newRect( 0, 0, 570, 360)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)

    local selectLevelText = display.newText("Survival Mode Select", 125, 32, native.systemFontBold, 32)
    selectLevelText:setFillColor( 0 )
    selectLevelText.x = display.contentCenterX
    selectLevelText.y = 50
    sceneGroup:insert(selectLevelText)

    --local x = 90
    --local y = 115
    local easyButton = widget.newButton({
        id = -1,
        label = "Easy",
        width = 100,
        height = 32,
        onEvent = handlePlayEvent
    })
    easyButton.x = display.contentCenterX / 2
    easyButton.y = display.contentHeight - 160
    sceneGroup:insert( easyButton )

    local hardButton = widget.newButton({
        id = -2,
        label = "Hard",
        width = 100,
        height = 32,
        onEvent = handlePlayEvent
    })
    hardButton.x = display.contentCenterX * 1.5
    hardButton.y = display.contentHeight - 160
    sceneGroup:insert( hardButton )

    local doneButton = widget.newButton({
        id = "button3",
        label = "Done",
        width = 100,
        height = 32,
        onEvent = handleButtonEvent
    })
    doneButton.x = display.contentCenterX
    doneButton.y = display.contentHeight - 40
    sceneGroup:insert( doneButton )
end

function scene:show( event )
    local sceneGroup = self.view

    params = event.params

    if event.phase == "did" then
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
