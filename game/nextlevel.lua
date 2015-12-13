local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local myData = require( "config.mydata" )
local utility = require( "config.utility" )
 
local nextLevelText
local params

-- Function to handle button events
local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.removeScene( "game.game", false )
        composer.gotoScene( "game.game", { effect = "crossFade", time = 333 } )
    end
end

local function returnToMenu( event )
    if ( event.phase == "ended" ) then
        local options = {
            effect = "crossFade",
            time = 500,
            params = {
                someKey = "someValue",
                someOtherKey = 10
            }
        }
        composer.gotoScene( "menu.menu", options )
    end
    return true
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
    local background = display.newRect( 0, 0, 570, 360 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)

    local wooHooOptions = { text = "Woo hoo!", fontSize = 42, font = native.systemFontBold, align = "center"}

    local wooHooText = display.newText( wooHooOptions )
    wooHooText.x = display.contentCenterX 
    wooHooText.y = 40
    wooHooText:setFillColor( 0 )
    sceneGroup:insert(wooHooText)


    nextLevelText = display.newText("Next Level " .. myData.settings.currentLevel, display.contentCenterX, display.contentCenterY, native.systemFontBold, 48)
    nextLevelText:setFillColor( 0 )
    sceneGroup:insert(nextLevelText)

    -- Create the widget
    local doneButton = widget.newButton({
        id = "button1",
        label = "Next level",
        width = 100,
        height = 32,
        onEvent = handleButtonEvent
    })
    doneButton.x = display.contentCenterX 
    doneButton.y = display.contentHeight - 70
    sceneGroup:insert( doneButton )

    local doneButton = widget.newButton({
        id = "button2",
        label = "Exit",
        width = 100,
        height = 32,
        onEvent = returnToMenu
    })
    doneButton.x = display.contentCenterX 
    doneButton.y = display.contentHeight - 20
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