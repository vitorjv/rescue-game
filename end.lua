local physics = require("physics")
physics.start()
local composer = require("composer")
local scene = composer.newScene()

local function playGame()
    composer.removeScene("menu")
    composer.gotoScene("game", { time=800, effect="crossFade" } )
end

function scene:create(event)    
    local sceneGroup = self.view
    
    local background = display.newImageRect( sceneGroup, "end-background.png", 500, 300)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
end

function scene:destroy( event )

    local sceneGroup = self.view
    display.remove(startButton)
    print('saiu')
	-- Code here runs prior to the removal of scene's view

end

scene:addEventListener( "create", scene )
scene:addEventListener( "destroy", scene )

return scene
