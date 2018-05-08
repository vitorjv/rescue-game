local composer = require( "composer" )
 
local scene = composer.newScene()

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local sheetOptions =
{
    frames =
    {
        {   -- 1) 
            x = 0,
            y = 10,
            width = 420,
            height = 140
        },
        {   -- 2) 
            x = 0,
            y = 160,
            width = 420,
            height = 140
        },
        {   -- 3) 
            x = 0,
            y = 310,
            width = 420,
            height = 140
        },
        {   -- 4) 
            x = 0,
            y = 460,
            width = 420,
            height = 140
        },
    },
}

local sheetOptions3 =
{
    frames =
    {
        {   -- 1) 
            x = 0,
            y = 0,
            width = 44,
            height = 44
        },
        {   -- 2) 
            x = 0,
            y = 45,
            width = 44,
            height = 44
        },
        {   -- 3) 
            x = 0,
            y = 90,
            width = 44,
            height = 44
        },
        {   -- 4) 
            x = 0,
            y = 135,
            width = 44,
            height = 44
        },
        {   -- 5) 
            x = 0,
            y = 180,
            width = 44,
            height = 44
        },
        {   -- 6) 
            x = 0,
            y = 225,
            width = 44,
            height = 44
        },
        {   -- 7) 
            x = 0,
            y = 270,
            width = 44,
            height = 44
        },
        {   -- 8) 
            x = 0,
            y = 315,
            width = 44,
            height = 44
        },
        {   -- 9) 
            x = 0,
            y = 360,
            width = 44,
            height = 44
        },
        {   -- 10) 
            x = 0,
            y = 405,
            width = 44,
            height = 44
        },
    },
}

local sheetOptions4 =
{
    frames =
    {
        {   -- 1) 
            x = 0,
            y = 0,
            width = 32,
            height = 32
        },
        {   -- 2) 
            x = 0,
            y = 33,
            width = 32,
            height = 32
        },
        {   -- 3) 
            x = 0,
            y = 66,
            width = 32,
            height = 32
        },
        {   -- 4) 
            x = 0,
            y = 99,
            width = 32,
            height = 32
        },
    },
}

local sheetOptions5 =
{
    frames =
    {
        {   -- 1) 
            x = 127,
            y = 62,
            width = 113,
            height = 47
        },
        {   -- 2) 
            x = 253,
            y = 62,
            width = 113,
            height = 47
        },
        {   -- 3) 
            x = 379,
            y = 62,
            width = 113,
            height = 47
        },
        {   -- 4) 
            x = 1,
            y = 240,
            width = 113,
            height = 47
        },
        {   -- 5) 
            x = 127,
            y = 240,
            width = 113,
            height = 47
        },
        {   -- 6) 
            x = 253,
            y = 240,
            width = 113,
            height = 47
        },
        {   -- 7) 
            x = 379,
            y = 240,
            width = 113,
            height = 47
        },
        {   -- 8) 
            x = 1,
            y = 418,
            width = 113,
            height = 47
        },
        {   -- 9) 
            x = 127,
            y = 418,
            width = 113,
            height = 47
        },
        {   -- 10) 
            x = 253,
            y = 418,
            width = 113,
            height = 47
        },
        {   -- 11) 
            x = 379,
            y = 418,
            width = 113,
            height = 47
        },
        {   -- 12) 
            x = 1,
            y = 596,
            width = 113,
            height = 47
        },
    },
}

local objectSheet = graphics.newImageSheet( "helicopter-spritesheet.png", sheetOptions )
local enemySheet = graphics.newImageSheet( "inimigos.png", sheetOptions3 )
local refensSheet = graphics.newImageSheet( "refens.png", sheetOptions3 )
local refensPulandoSheet = graphics.newImageSheet( "pulando.png", sheetOptions4 )
local helicopteroFireSheet = graphics.newImageSheet( "helicopter-fire.png", sheetOptions5 )

local score = 0
local life = 100
local died = false
local helicopteroChanged = false
local paused = false

local enemiesTable = {}
local hostagesTable = {}
local bulletsTable = {}
local fireTable = {}

local helicoptero
local gameLoopTimer
local helicopterTimer
local scoreText

local backGroup
local mainGroup
local uiGroup

local function BotaoLeft(event)
        
    if (helicoptero.x > -5) then 
        helicoptero.x = helicoptero.x - 6
    end
    
    if (helicoptero.rotation > -30) then
        helicoptero.angularVelocity = -50
        timer.performWithDelay(1,verifyHelicopterAngular,100)
        timer.performWithDelay(1000,function() helicoptero.angularVelocity = 10 end)
    end
end

local function BotaoRight(event)
    paused = false
    if (helicoptero.x < (display.contentWidth+30)) then
        helicoptero.x = helicoptero.x + 6
    end

    if (helicoptero.rotation < 15) then
        helicoptero.angularVelocity = 50
        timer.performWithDelay(1,verifyHelicopterAngular,100)
        timer.performWithDelay(1000,function() helicoptero.angularVelocity = 10 end)
    end

end

local function tiroHelicoptero()
    local laser = display.newImageRect(mainGroup,"bullet.png",2,5)
    physics.addBody( laser, "dynamic", { isSensor=true } )
    laser.isBullet = true
    laser.myName = "laser"
    laser.x = helicoptero.x + 20
    laser.y = helicoptero.y + 15

    laser:toBack()
    rotacao = helicoptero.rotation
    xDestino = 2*display.contentWidth
    
    yDestino = (math.tan(rotacao*3.1415/180) * xDestino)
    yDestino = yDestino + helicoptero.y + 50
    transition.to( laser, { x=xDestino, y=yDestino, time=1000,
            onComplete = function() display.remove( laser ) end
        } )
end

local function createHostage()
    if #hostagesTable <= 2 then
        time = os.time()
        diff = time - inicio
        if diff / (#hostagesTable + 1 + score) > 20 then
            local newHostage = display.newSprite( refensSheet, inimigos)
            physics.addBody(newHostage, "dynamic", { friction = 0, radius=5, bounce=0.2, isSensor = true })
            newHostage.myName = "hostage"
            newHostage.isRescue = false
            newHostage.x = -20
            newHostage.y = display.contentHeight - 100
            newHostage:setLinearVelocity(40,0)
            newHostage:scale(0.5,0.5)
            newHostage:play()
            table.insert(hostagesTable, newHostage)
        end
    end
end

local function createEnemy()
    local newEnemy = display.newSprite( enemySheet, inimigos)
    physics.addBody( newEnemy, "dynamic", { friction = 0, radius=5, bounce=0.2, isSensor = true } )
    newEnemy.myName = "enemy"
    newEnemy.x = display.contentWidth + 40
    newEnemy.y = display.contentHeight - 102
    newEnemy.isAtirador = false
    newEnemy:scale(0.5,0.5)
    newEnemy:play()
    newEnemy:setLinearVelocity(math.random(-30,-10),0)
    table.insert( enemiesTable, newEnemy )
end

local function atirar(enemy)
    if (math.random() > 0.9 and enemy.x < display.contentWidth-20) then
        local newBullet = display.newImageRect(mainGroup,"bullet.png",2,5)
        physics.addBody( newBullet, "dynamic", { isSensor=true } )
        newBullet.isBullet = true
        newBullet.myName = "bullet"
        newBullet.x = enemy.x - 5
        newBullet.y = enemy.y - 5
        
        newBullet:toBack()
        
        xDestino = (helicoptero.x*(enemy.y + 20) - enemy.x*(helicoptero.y + 20)) / (enemy.y - helicoptero.y)
        erro = math.random(-200,200) 
        xDestino = xDestino + erro
        transition.to( newBullet, { x=xDestino,y=-20, time=1000, onComplete = function() display.remove( newBullet ) end
    } )
    end
end
    
local function verifyCreateEnemy() 
    if (math.random() * #enemiesTable < 1) then
        createEnemy()
    end 
end


local function verifyBecameShooter(shooter)
    if (math.random() > 0.9) or (shooter.x < display.contentCenterX-30) then
        x = shooter.x
        y = shooter.y
        display.remove(shooter)
        
        for i = #enemiesTable, 1, -1 do
            local refem = enemiesTable[i]
            if  (refem == shooter) then
                table.remove(enemiesTable, i)
            end
        end

        local newEnemy = display.newImageRect("atirador.png",32,32)
        physics.addBody(newEnemy, "dynamic", { friction = 0, radius=5, bounce=0.2, isSensor = true })
        newEnemy.myName = "enemy"
        newEnemy.isAtirador = true
        newEnemy.x = x
        newEnemy.y = y
        newEnemy:scale(0.75,0.75)
        table.insert(enemiesTable, newEnemy)
    end
end

local function verifyPositionHostage(hostage)
    if hostage.isRescue == false then
        if hostage.x > display.contentCenterX - 50 then
            x = hostage.x
            y = hostage.y
            display.remove(hostage)
            
            for i = #hostagesTable, 1, -1 do
                local refem = hostagesTable[i]
                if  (refem == hostage) then
                    table.remove(hostagesTable, i)
                end
            end

            local newHostage = display.newSprite( refensPulandoSheet, inimigos)
            physics.addBody(newHostage, "dynamic", { friction = 0, radius=5, bounce=0.2, isSensor = true })
            newHostage.myName = "hostage"
            newHostage.waiting = true
            newHostage.x = x
            newHostage.y = y
            newHostage:scale(0.75,0.75)
            newHostage:play()
            table.insert(hostagesTable, newHostage)
        end
    end
end

local function verifyRescueHostage(hostage)
    if ((hostage.x > helicoptero.x - 20 and hostage.x < helicoptero.x + 20) and (hostage.isRescue == false)) then
        hostage.isRescue = true
        hostage:setLinearVelocity(0,-20)
    end
end

local function verifyHelicopterAngular()
    if helicoptero.angularVelocity > 1 then
        if helicoptero.rotation > 15 then
            helicoptero.angularVelocity = 0
        end
    elseif helicoptero.angularVelocity < -1 then
        if helicoptero.rotation < -30 then
            helicoptero.angularVelocity = 0
        end
    end
end

local function gameLoop()
    if (not paused) then
        if (not died) then
            --tiroHelicoptero() 
            verifyCreateEnemy()
            createHostage()
            verifyHelicopterAngular()
        else
            if (not helicopteroChanged) then
                xHelicoptero = helicoptero.x
                yHelicoptero = helicoptero.y
                rotationHelicoptero = helicoptero.rotation
                helicoptero.y = -500
                helicopteroFire = display.newSprite( helicopteroFireSheet, sequenceData)
                helicopteroFire.myName="helicopteroFire"
                helicopteroFire.x=xHelicoptero
                helicopteroFire.y=yHelicoptero
                helicopteroFire.rotation = rotationHelicoptero
                helicopteroFire:scale(0.8,0.8)
                physics.addBody(helicopteroFire, "dynamic", { radius=30, bounce=0 }) 
                helicopteroFire:play()
                helicopteroFire.angularVelocity = 40
                helicopteroFire:setLinearVelocity(10,80)
                --died = false
                helicopteroChanged = true
            end
        end
        
        for i = #enemiesTable, 1, -1 do
            local enemy = enemiesTable[i]
            if ( enemy.x < -20 or
                enemy.x > display.contentWidth + 65 or
                enemy.y > display.contentHeight + 20 )
            then
                display.remove( enemy )
                table.remove( enemiesTable, i )
                break
            end
            if (enemy.isAtirador) and (not died) then
                atirar(enemy)
            else
                verifyBecameShooter(enemy)
            end 
        end

        for i = #hostagesTable, 1, -1 do
            local refem = hostagesTable[i]        
            if  (refem.y > helicoptero.y - 20) and (refem.y < helicoptero.y + 20) then
                refem.isRescue = true
                score = score + 1
                scoreText.text = "Score: " .. score
                table.remove (hostagesTable, i)
                display.remove( refem )
            end
            verifyRescueHostage(refem)
            verifyPositionHostage(refem)
        end
    end
end

local function onCollision(event)
    if ( event.phase == "began" ) then 
        local obj1 = event.object1
        local obj2 = event.object2

        if ((obj1.myName == "helicopteroFire") and (obj2.myName == "piso")) or
            ((obj2.myName == "helicopteroFire") and (obj1.myName == "piso")) then
                helicopteroFire.angularVelocity = 0
                helicopteroFire:setLinearVelocity(0,0)
        end

        if ((obj1.myName == "helicoptero") and (obj2.myName == "bullet")) or
            ((obj2.myName == "helicoptero") and (obj1.myName == "bullet")) then
                life = life-10
                livesText.text = "Life: " .. life
                if (obj1.myName == "helicoptero") then
                    display.remove(obj2);
                    else display.remove(obj1);
                end
                if life <= 0 then
                    died = true
                end

        elseif ((obj1.myName == "laser") and (obj2.myName == "enemy")) or
        ((obj2.myName == "laser") and (obj1.myName == "enemy")) then
            for i = #enemiesTable, 1, -1 do
                local enemy = enemiesTable[i]
                if (enemy == obj1) or (enemy == obj2) then
                    table.remove( enemiesTable, i )
                end
            end
            display.remove(obj1)
            display.remove(obj2)
        elseif ((obj1.myName == "laser") and (obj2.myName == "piso")) or
    ((obj2.myName == "laser") and (obj1.myName == "piso")) then
            if (obj1.myName == "laser") then
                display.remove(obj1)
            else
                display.remove(obj2)
            end
        elseif ((obj1.myName == "laser") and (obj2.myName == "hostage")) or
        ((obj2.myName == "laser") and (obj1.myName == "hostage")) then 

        end
    end
end

function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    
    physics.pause()  -- Temporarily pause the physics engine
    
    local backGroup = display.newGroup()
    sceneGroup:insert( backGroup ) 
    local mainGroup = display.newGroup()  
    sceneGroup:insert( mainGroup ) 
    local uiGroup = display.newGroup()    
    sceneGroup:insert( uiGroup ) 
    
    local background = display.newImageRect( backGroup, "img/background.png", 500, 300)
    background.x = 0
    background.y = display.contentCenterY
    background.xScale = 2

    -- Load the ground
    local piso = display.newImageRect(backGroup,"img/piso.png",display.contentWidth*2,70)
    piso.x=0
    piso.y=display.contentHeight-60
    piso.myName="piso"
    physics.addBody(piso,"static",{friction= .1, })

    sequenceData =
    {
        name="driving",
        start=1,
        count=2,
        time=100,
        loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
        loopDirection = "bounce"    -- Optional ; values include "forward" or "bounce"
    }

    inimigos = {
        name = "enemy",
        start=1,
        count=2,
        time=500,
        loopCount = 0,
        loopDirection = "bounce"
    }

    helicoptero = display.newSprite( objectSheet, sequenceData)
    helicoptero.myName="helicoptero"
    helicoptero.y=80
    helicoptero.x=100
    helicoptero:rotate(20)
    helicoptero:scale(0.25,0.25)
    helicoptero:play()
    physics.addBody(helicoptero, "dynamic", { radius=30, bounce=0.3 })

    livesText = display.newText( uiGroup, "Life: " .. life, 40, 40, native.systemFont, 16 )
    scoreText = display.newText( uiGroup, "Score: " .. score, 130, 40, native.systemFont, 16 )

    local widget = require "widget"

    local leftButton = widget.newButton {
        id = "botao1",         -- Identificador do Botão
        left = 20,       -- Posição X que o botão aparecerá na tela
        top = display.contentHeight-70,             -- Posição Y que o botão aparecerá na tela
        defaultFile = "img/arrow-alt-circle-left.png",
        overFile, "left2.png",
        width = 35,           -- Largura do Botão
        height = 35,           -- Altura do Botão
        onEvent = BotaoLeft  -- Função que o botão irá chamar
    }

    local rightButton = widget.newButton {
        id = "botao2",         -- Identificador do Botão
        left = 65,       -- Posição X que o botão aparecerá na tela
        top = display.contentHeight-71,             -- Posição Y que o botão aparecerá na tela
        defaultFile = "img/arrow-alt-circle-right.png",
        overFile, "right2.png",
        width = 35,           -- Largura do Botão
        height = 35,           -- Altura do Botão
        onEvent = BotaoRight  -- Função que o botão irá chamar
    }

    local shootButton = widget.newButton {
        id = "botao3",         -- Identificador do Botão
        left = display.contentWidth-80,       -- Posição X que o botão aparecerá na tela
        top = display.contentHeight-75,             -- Posição Y que o botão aparecerá na tela
        defaultFile = "img/shoot-button.png",
        overFile, "left2.png",
        width = 45,           -- Largura do Botão
        height = 45,           -- Altura do Botão
        onEvent = BotaoLeft  -- Função que o botão irá chamar
    }
end

function scene:show( event )
    inicio = os.time()
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        physics.start()
        print('oi')
		Runtime:addEventListener( "collision", onCollision )
		gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
    end
end

-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        --timer.cancel( gameLoopTimer )
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        Runtime:removeEventListener( "collision", onCollision )
        physics.pause()
        composer.removeScene( "game" )
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene