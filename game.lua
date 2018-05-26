local composer = require( "composer" )
 
local scene = composer.newScene()

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

audio.reserveChannels( 4 )
audio.setVolume( 0.2, { channel=1 } )
audio.setVolume( 0.3, { channel=2 } )
audio.setVolume( 0.2, { channel=3 } )


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
local helicopterRescueSheet = graphics.newImageSheet( "helicopter2-spritesheet.png", sheetOptions )

local score = 0
local life = 100
died = false
local helicopteroChanged = false
local paused = false
rescueButtonCreated = false

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

local helicopterSound
local helicopter2Sound
local helicopterShotSound

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

    audio.play(helicopterShotSound, { channel=2 })
    
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
        if diff / (#hostagesTable + 1 + score) > 5 then
            newHostage = display.newSprite( refensSheet, inimigos)
            physics.addBody(newHostage, "dynamic", { friction = 0, radius=5, bounce=0.2, isSensor = true })
            newHostage.myName = "hostage"
            newHostage.isRescue = false
            newHostage.x = -20
            newHostage.y = display.contentHeight - 100
            --newHostage:setLinearVelocity(40,0)

            transition.to( newHostage, { time=5500, x=math.random(100,display.contentCenterX), y=(display.contentHeight - 100), 
                onComplete=trocaSpritRefem } )
            newHostage:scale(0.5,0.5)
            newHostage:play()
            newHostage.waiting = false
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
    newEnemy:setLinearVelocity(math.random(-40,-20),0)
    --transition.to( newEnemy, { time=math.random(4500,5500), x=math.random(display.contentCenterX+100,display.contentWidth-50), y=(display.contentHeight - 102), 
    --            onComplete=becameShooter } )
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
    if (math.random() > 0.9) or (shooter.x < display.contentCenterX+20) then
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

function trocaSpritRefem(hostage)
    print('trocando hostage')
    print(hostage.myName)
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
    newHostage.isRescue = false
    newHostage.x = x
    newHostage.y = y
    newHostage:scale(0.75,0.75)
    newHostage:play()
    table.insert(hostagesTable, newHostage)
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

function chamarHelicoptero()
    display.remove(callHelicopterButton)
    helicoptero2 = display.newSprite( helicopterRescueSheet, sequenceData)
    helicoptero2.myName="helicoptero2"
    helicoptero2.y=140
    helicoptero2.x=-10
    helicoptero2:rotate(10)
    helicoptero2:scale(0.20,0.20)
    helicoptero2:play()
    physics.addBody(helicoptero2, "dynamic", { radius=30, bounce=0 })
    audio.play(helicopter2Sound, { channel=3, loops=-1 })
    
    --helicoptero2:setLinearVelocity(50,0)
    resgatarRefens()
end

function resgatarRefens()
    local refens = {}
    for i = #hostagesTable, 1, -1 do
        local refem = hostagesTable[i]
        if refem.waiting then
            table.insert(refens,refem.x)
        end
    end
    table.sort(refens)
    a(refens)
end

function tamanhoCorda()
    display.remove(rope)
    rope = display.newImageRect( backGroup, "img/rope.png", 4, -140+ref.y)
    rope.x = ref.x
    rope.y = (140 + ref.y)/2
end

function a(refensTable)
    transition.to( helicoptero2, { x=refensTable[1], y=140, time=1000,
    onComplete = function()
        
        rope = display.newImageRect( backGroup, "img/rope.png", 4, 100)
        rope.x = helicoptero2.x
        rope.y = 200
        for z = #hostagesTable, 1, -1 do
            if hostagesTable[z].x == refensTable[1] then
                ref = hostagesTable[z]
                local ropeTimer = timer.performWithDelay( 50, tamanhoCorda, 200 )
                transition.to( ref, { x=ref.x, y=140, time=2000,
                    onComplete = function()
                        timer.cancel(ropeTimer) 
                        score = score + 1
                        scoreText.text = "Score: " .. score
                        table.remove (hostagesTable, z)
                        display.remove(ref)
                        display.remove(rope)
                        table.remove(refensTable,1)
                        if (#refensTable > 0) then
                            a(refensTable)
                        else
                            helicoptero2:setLinearVelocity(100,0)
                        end
                    end
                })
                local ropeTimer = timer.performWithDelay( 50, tamanhoCorda(rope, ref), 200 )
                    
            end
        end    
    end
    } )
end

local function verificaRefem()
    for i = #hostagesTable, 1, -1 do
        local refem = hostagesTable[i]        
        if (refem.waiting == true) then
            if ((hostage.x > helicoptero2.x - 20 and hostage.x < helicoptero2.x + 20) and (hostage.isRescue == false)) then
                hostage.isRescue = true
                helicoptero2:setLinearVelocity(0,0)
                hostage:setLinearVelocity(0,-20)
            end
        end
    end
    if (helicoptero2.x > display.contentWidth + 50) then
        timer.cancel(verificaRefemTimer)
        display.remove(helicopter2)
    end
end

function createRescueButton() 
    rescueButtonCreated = true
    callHelicopterButton = widget.newButton {
        id = "botao4",         -- Identificador do Botão
        left = display.contentWidth-130,       -- Posição X que o botão aparecerá na tela
        top = display.contentHeight-78,             -- Posição Y que o botão aparecerá na tela
        defaultFile = "img/call-helicopter.png",
        width = 50,           -- Largura do Botão
        height = 50,           -- Altura do Botão
        onEvent = handleRescueButtonEvent  -- Função que o botão irá chamar
    }
end

local function gameLoop()
    if (not paused) then
        if (not died) then
            if helicoptero2 ~= nil then
                if helicoptero2.x > display.contentWidth + 100 then
                    rescueButtonCreated = false
                    display.remove(helicoptero2)
                    helicoptero2 = nil
                    audio.stop(3)
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
            local refensWaiting = 0
            for i = #hostagesTable, 1, -1 do
                local refem = hostagesTable[i]
                if (refem.waiting) then
                    refensWaiting = refensWaiting + 1
                end
            end
            if (refensWaiting > 0) and (not rescueButtonCreated) then
                createRescueButton()
            end        
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
    end
end

function gameOver(event)
    composer.removeScene("game")
    composer.gotoScene("end", { time=800, effect="crossFade" } )
end

local function onCollision(event)
    if ( event.phase == "began" ) then 
        local obj1 = event.object1
        local obj2 = event.object2

        if ((obj1.myName == "helicopteroFire") and (obj2.myName == "piso")) or
            ((obj2.myName == "helicopteroFire") and (obj1.myName == "piso")) then
                helicopteroFire.angularVelocity = 0
                helicopteroFire:setLinearVelocity(0,0)
                gameOver()
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
        elseif ((obj1.myName == "laser") and (obj2.myName == "piso")) then
            display.remove(obj1)
        elseif ((obj2.myName == "laser") and (obj1.myName == "piso")) then
                display.remove(obj2)
        elseif ((obj1.myName == "laser") and (obj2.myName == "helicoptero2")) then 
            display.remove(obj1)
            obj2.angularVelocity = 40
            obj2:setLinearVelocity(10,80)
            --gameOver()
        elseif ((obj2.myName == "laser") and (obj1.myName == "helicoptero2")) then 
            display.remove(obj2)
            obj1.angularVelocity = 40
            obj1:setLinearVelocity(10,80)
            --gameOver()
        elseif ((obj1.myName == "helicoptero2") and (obj2.myName == "piso")) or
            ((obj2.myName == "helicoptero2") and (obj1.myName == "piso")) then 
                gameOver()
        elseif ((obj1.myName == "helicoptero2") and (obj2.myName == "enemy")) or
            ((obj2.myName == "helicoptero2") and (obj1.myName == "enemy")) then 
                gameOver()
        end

    end
end

function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    
    physics.pause()  -- Temporarily pause the physics engine
    
    backGroup = display.newGroup()
    sceneGroup:insert( backGroup ) 
    mainGroup = display.newGroup()  
    sceneGroup:insert( mainGroup ) 
    uiGroup = display.newGroup()    
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

    widget = require "widget"

    leftButton = widget.newButton {
        id = "botao1",         -- Identificador do Botão
        left = 20,       -- Posição X que o botão aparecerá na tela
        top = display.contentHeight-70,             -- Posição Y que o botão aparecerá na tela
        defaultFile = "img/arrow-alt-circle-left.png",
        overFile, "left2.png",
        width = 35,           -- Largura do Botão
        height = 35,           -- Altura do Botão
        onEvent = BotaoLeft  -- Função que o botão irá chamar
    }
    
    rightButton = widget.newButton {
        id = "botao2",         -- Identificador do Botão
            left = 65,       -- Posição X que o botão aparecerá na tela
            top = display.contentHeight-71,             -- Posição Y que o botão aparecerá na tela
            defaultFile = "img/arrow-alt-circle-right.png",
            overFile, "right2.png",
            width = 35,           -- Largura do Botão
            height = 35,           -- Altura do Botão
            onEvent = BotaoRight  -- Função que o botão irá chamar
    }
                
    shootButton = widget.newButton {
        id = "botao3",         -- Identificador do Botão
        left = display.contentWidth-80,       -- Posição X que o botão aparecerá na tela
        top = display.contentHeight-75,             -- Posição Y que o botão aparecerá na tela
        defaultFile = "img/shoot-button.png",
        overFile, "left2.png",
        width = 45,           -- Largura do Botão
        height = 45,           -- Altura do Botão
        onEvent = handleShootButtonEvent  -- Função que o botão irá chamar
    }

    helicopterSound = audio.loadSound( "sounds/helicopter.wav" )
    helicopter2Sound = audio.loadSound( "sounds/helicopter2.wav" )
    helicopterShotSound = audio.loadSound( "sounds/helicopter-shot.wav" )

end

function handleShootButtonEvent( event ) 
    if ( "ended" == event.phase ) then
        tiroHelicoptero()
    end
end

function handleRescueButtonEvent( event ) 
    if ( "ended" == event.phase ) then
        chamarHelicoptero()
    end
end

function scene:show( event )
    inicio = os.time()
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)


        audio.play(helicopterSound, { channel=1, loops=-1 })
        
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        physics.start()
        
		Runtime:addEventListener( "collision", onCollision )
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
        enemyTimer = timer.performWithDelay( 1500, verifyCreateEnemy, 0 )
        refemTimer = timer.performWithDelay( 1500, createHostage, 0 )
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

function scene:destroy( event )
    local sceneGroup = self.view
    physics.pause()
    display.remove(background)
    display.remove(piso)
    display.remove(shootButton)
    display.remove(rightButton)
    display.remove(leftButton)
    display.remove(helicopteroFire)
    display.remove(helicoptero)
    helicoptero = nil
    display.remove(helicoptero2)
    helicoptero2 = nil
    if (rescueButtonCreated) then 
        display.remove(callHelicopterButton)
    end
    for i = #enemiesTable, 1, -1 do
        local enemy = enemiesTable[i]
        table.remove( enemiesTable, i )
        display.remove(enemy)
    end
    for i = #hostagesTable, 1, -1 do
        local enemy = hostagesTable[i]
        table.remove( hostagesTable, i )
        display.remove(enemy)
    end
    timer.cancel(gameLoopTimer)
    timer.cancel(enemyTimer)
    timer.cancel(refemTimer)
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