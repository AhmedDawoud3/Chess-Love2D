lightCol = {241 / 255, 217 / 255, 192 / 255, 1}
darkCol = {169 / 255, 122 / 255, 101 / 255, 1}
WIDTH = 960
HEIGHT = 960
squareTileWidth = WIDTH / 8
squareTileHeight = HEIGHT / 8
local queenShadow = 0
local rookShadow = 0
local knightShadow = 0
local bishopShadow = 0

function CreateGraphicalBoard()
    for file = 0, 7 do
        for rank = 0, 7 do
            isLightSquare = (file + rank) % 2 ~= 0
            squareColour = (isLightSquare and darkCol) or lightCol
            position = {file, rank}
            DrawSquare(squareColour, position)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function DrawSquare(col, pos)
    love.graphics.setColor(col[1], col[2], col[3], col[4])
    love.graphics.rectangle("fill", pos[1] * squareTileWidth, pos[2] * squareTileHeight, squareTileWidth,
        squareTileHeight)
    love.graphics.setColor(1, 1, 1, 1)
end
Board = Class {}
function Board:init()
    self.Square = {}
    for i = 1, 64 do
        self.Square[i] = {0, false, true}
    end
end

function Board:DisplayPieces()
    for i, v in ipairs(self.Square) do
        if v[1] ~= 0 then
            local p = Loader:GetPiece(v[1])
            if p ~= nil and v[2] then
                local x, y = SquareToCordinate(i)

                love.graphics.draw(Loader.piecesTexture, p, x, y)
            end
        end
    end
    if floatingPiece then
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(floatingPiece[1]), floatingPiece[2][1] - 60,
            floatingPiece[2][2] - 60)
    end
end

function Board:DisplayLastMoves()
    DrawSquare({0.78, 0.78, 0.24, 0.5},
        {FileIndex(oldMoves[#oldMoves].StartSquare), RankIndex(oldMoves[#oldMoves].StartSquare)})
    DrawSquare({0.78, 0.78, 0.24, 0.7},
        {FileIndex(oldMoves[#oldMoves].TargetSquare), RankIndex(oldMoves[#oldMoves].TargetSquare)})
end

function Board:DisplayLegalMoves()
    for i, v in ipairs(moves) do
        if v then
            DrawSquare({0.8, 0.1, 0.2, 0.7}, {FileIndex(v.TargetSquare), RankIndex(v.TargetSquare)})
        end
    end
    if selectedPieceSquare and #moves > 0 then
        DrawSquare({1, 0.65, 0.2, 0.8}, {FileIndex(selectedPieceSquare), RankIndex(selectedPieceSquare)})
    end
end

function Board:DisplayChecks()
    if IsCheck(Piece().Black) then
        DrawSquare({0.4, 0.8, 0.2, 0.7}, {FileIndex(IsCheck(Piece().Black)[2]), RankIndex(IsCheck(Piece().Black)[2])})
    end
    if IsCheck(Piece().White) then
        DrawSquare({0.4, 0.8, 0.2, 0.7}, {FileIndex(IsCheck(Piece().White)[2]), RankIndex(IsCheck(Piece().White)[2])})
    end
end

function Board:GetPiecePromotion()
    if Game.promotionAvalible == true then
        local col = Game.promotionColor == Piece().White and Piece().Black or Piece().White
        local mouseX = love.mouse.getX()
        local mouseY = love.mouse.getY()
        love.mouse.setCursor()
        love.graphics.setColor(0.1, 0.1, 0.1, 0.7)
        love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)

        -- Queen
        love.graphics.setColor(((241 + 168) / 2) / 255 + queenShadow / 50, ((217 + 122) / 2) / 255 + queenShadow / 50,
            ((192 + 101) / 2) / 255 + queenShadow / 100, 1)
        love.graphics.rectangle("fill", 1 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Queen, col)),
            1 * squareTileWidth + squareTileWidth / 4 - queenShadow,
            2 * squareTileHeight + squareTileHeight / 4 + queenShadow, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Queen, col)),
            1 * squareTileWidth + squareTileWidth / 4, 2 * squareTileHeight + squareTileHeight / 4, 0, 1.5, 1.5)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 1 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        if CheckMouseCollision(mouseX, mouseY, squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2) then
            queenShadow = math.min(queenShadow + 1, 10)
            love.mouse.setCursor((love.mouse.getSystemCursor("hand")))
            if love.mouse.isDown(1) then
                love.mouse.setCursor()
                Piece().Promote(bit.bor(Piece().Queen, col))
                queenShadow = 0
            end
        else
            queenShadow = math.max(queenShadow - 1, 0)
        end

        -- Rook
        love.graphics.setColor(((241 + 168) / 2) / 255 + rookShadow / 50, ((217 + 122) / 2) / 255 + rookShadow / 50,
            ((192 + 101) / 2) / 255 + rookShadow / 100, 1)
        love.graphics.rectangle("fill", 5 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Rook, col)),
            5 * squareTileWidth + squareTileWidth / 4 - rookShadow,
            2 * squareTileHeight + squareTileHeight / 4 + rookShadow, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Rook, col)),
            5 * squareTileWidth + squareTileWidth / 4, 2 * squareTileHeight + squareTileHeight / 4, 0, 1.5, 1.5)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 5 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        if CheckMouseCollision(mouseX, mouseY, 5 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2) then
            rookShadow = math.min(rookShadow + 1, 10)
            love.mouse.setCursor((love.mouse.getSystemCursor("hand")))
            if love.mouse.isDown(1) then
                love.mouse.setCursor()
                Piece().Promote(bit.bor(Piece().Rook, col))
                rookShadow = 0
            end
        else
            rookShadow = math.max(rookShadow - 1, 0)
        end

        -- Bishop
        love.graphics.setColor(((241 + 168) / 2) / 255 + bishopShadow / 50, ((217 + 122) / 2) / 255 + bishopShadow / 50,
            ((192 + 101) / 2) / 255 + bishopShadow / 100, 1)
        love.graphics.rectangle("fill", 1 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Bishop, col)),
            1 * squareTileWidth + squareTileWidth / 4 - bishopShadow,
            5 * squareTileHeight + squareTileHeight / 4 + bishopShadow, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Bishop, col)),
            1 * squareTileWidth + squareTileWidth / 4, 5 * squareTileHeight + squareTileHeight / 4, 0, 1.5, 1.5)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 1 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        if CheckMouseCollision(mouseX, mouseY, squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2) then
            bishopShadow = math.min(bishopShadow + 1, 10)
            love.mouse.setCursor((love.mouse.getSystemCursor("hand")))
            if love.mouse.isDown(1) then
                love.mouse.setCursor()
                bishopShadow = 0
                Piece().Promote(bit.bor(Piece().Bishop, col))
            end
        else
            bishopShadow = math.max(bishopShadow - 1, 0)
        end

        -- Knight
        love.graphics.setColor(((241 + 168) / 2) / 255 + knightShadow / 50, ((217 + 122) / 2) / 255 + knightShadow / 50,
            ((192 + 101) / 2) / 255 + knightShadow / 100, 1)
        love.graphics.rectangle("fill", 5 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Knight, col)),
            5 * squareTileWidth + squareTileWidth / 4 - knightShadow,
            5 * squareTileHeight + squareTileHeight / 4 + knightShadow, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Knight, col)),
            5 * squareTileWidth + squareTileWidth / 4, 5 * squareTileHeight + squareTileHeight / 4, 0, 1.5, 1.5)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 5 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setLineWidth(1)
        if CheckMouseCollision(mouseX, mouseY, 5 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2) then
            knightShadow = math.min(knightShadow + 1, 10)
            love.mouse.setCursor((love.mouse.getSystemCursor("hand")))
            if love.mouse.isDown(1) then
                love.mouse.setCursor()
                Piece().Promote(bit.bor(Piece().Knight, col))
                knightShadow = 0
            end
        else
            knightShadow = math.max(knightShadow - 1, 0)
        end

    end
end

function Board:LoadStartPosition()
    Board:LoadPosition(startFen)
end

function Board:LoadPosition(fen)
    loadedPosition = PositionFromFen(fen)

    for squareIndex = 1, 64 do
        piece = loadedPosition.squares[squareIndex]
        Game.Board.Square[squareIndex][1] = piece
        Game.Board.Square[squareIndex][2] = true
        Game.Board.Square[squareIndex][3] = false
    end
    Game.turn = loadedPosition.turn
    Game.wkcstl = loadedPosition.whiteCastleKingside
    Game.wqcstl = loadedPosition.whiteCastleQueenside
    Game.bkcstl = loadedPosition.blackCastleKingside
    Game.bqcstl = loadedPosition.blackCastleQueenside
    Game.epFile = loadedPosition.epFile
end

function CheckMouseCollision(x, y, x2, y2, width, height)
    if x < x2 + width and x > x2 and y < y2 + height and y > y2 then
        return true
    end
    return false
end
