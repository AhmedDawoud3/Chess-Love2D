PlayerContrals = Class {}

local gameCopied = 0
local gamePasted = 0

function PlayerContrals:Render()
    love.graphics.clear(0.35, 0.35, 0.35, 1)
    love.graphics.setFont(Fonts['Secondary'])
    love.graphics.setColor(Game.turn == 'w' and 1 or 0, Game.turn == 'w' and 1 or 0, Game.turn == 'w' and 1 or 0, 1)
    love.graphics.printf((Game.turn == 'w' and 'White' or 'Black') .. " To Move", 980, 50, love.graphics.getWidth())

    -- Undo
    love.graphics.setColor(0.25, 0.25, 0.25, 1)
    if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 990, 750, 100, 40) then
        love.graphics.setColor(0.45, 0.45, 0.45, 1)
    end
    love.graphics.rectangle('fill', 990, 750, 100, 40)
    love.graphics.setFont(Fonts['small'])
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Undo', 1015, 755)

    -- Restart
    love.graphics.setColor(0.25, 0.25, 0.25, 1)
    if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 1150, 750, 100, 40) then
        love.graphics.setColor(0.45, 0.45, 0.45, 1)
    end
    love.graphics.rectangle('fill', 1150, 750, 100, 40)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Restart', 1165, 755)

    -- Copy Fen
    love.graphics.setColor(0.25, 0.25, 0.25, 1)
    if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 990, 750 - 430, 100, 40) then
        love.graphics.setColor(0.45, 0.45, 0.45, 1)
    end
    love.graphics.rectangle('fill', 990, 320, 120, 40)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Copy Game', 1000, 755 - 430)
    love.graphics.setColor(1, 0.5, 0.11, gameCopied)
    love.graphics.print('Game Copied', 990, 700 - 430 + gameCopied * 50)

    -- Paste Fen
    love.graphics.setColor(0.25, 0.25, 0.25, 1)
    if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 1130, 320, 130, 40) then
        love.graphics.setColor(0.45, 0.45, 0.45, 1)
    end
    
    love.graphics.rectangle('fill', 1130, 320, 130, 40)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Paste Game', 1140, 755 - 430)
    love.graphics.setColor(0.65, 0.75, 0.45, gamePasted)
    love.graphics.print('Game Pasted', 990 + 145, 750 - 430 - gamePasted * 50)

    -- Exit
    love.graphics.setColor(0.25, 0.25, 0.25, 1)
    if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 1080, 875, 130, 40) then
        love.graphics.setColor(0.45, 0.45, 0.45, 1)
    end
    love.graphics.rectangle('fill', 1080, 875, 80, 35)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Exit', 1100, 875)

    gameCopied = math.max(gameCopied - 0.02, 0)
    gamePasted = math.max(gamePasted - 0.02, 0)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then

        -- Undo
        if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 990, 750, 100, 40) then
            UndoMove()
        end

        -- Restart
        if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 1150, 750, 100, 40) then
            Game.Board:LoadStartPosition()
            moveHistory = {}
            oldMoves = {}
            lastMove = nil
            Game.promotionAvalible = nil
        end

        -- Copy Fen
        if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 990, 750 - 430, 100, 40) then
            love.system.setClipboardText(CurrentFEN(Game.Board))
            gameCopied = 1
        end

        -- Paste Fen
        if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 1130, 320, 130, 40) then
            gamePasted = 1
            local pastedFen = love.system.getClipboardText()
            if CheckFEN(pastedFen) then
                Game.Board:LoadPosition(pastedFen)
                oldMoves = {}
                lastMove = nil
                Game.promotionAvalible = nil
            end
        end

        -- Exit
        if CheckMouseCollision(love.mouse.getX(), love.mouse.getY(), 1080, 875, 130, 40) then
            love.event.quit()
        end
    end
end
