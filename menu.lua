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
    
    local background = display.newImageRect( sceneGroup, "start-background.png", 500, 300)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    
    local widget = require "widget"
    
    startButton = widget.newButton {
        id = "botao1",         -- Identificador do Botão
        left = display.contentCenterX-75,       -- Posição X que o botão aparecerá na tela
        top = display.contentHeight-90,             -- Posição Y que o botão aparecerá na tela
        defaultFile = "start-button.png",
        width = 150,           -- Largura do Botão
        height = 50,           -- Altura do Botão
        onEvent = playGame  -- Função que o botão irá chamar
    }
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
