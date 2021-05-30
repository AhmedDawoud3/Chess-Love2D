lightCol = {241 / 255, 217 / 255, 192 / 255, 1}
darkCol = {169 / 255, 122 / 255, 101 / 255, 1}
WIDTH = 960
HEIGHT = 960
squareTileWidth = WIDTH / 8
squareTileHeight = HEIGHT / 8

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
    DrawSquare({0.78, 0.78, 0.24, 0.5}, {FileIndex(lastMove.StartSquare), RankIndex(lastMove.StartSquare)})
    DrawSquare({0.78, 0.78, 0.24, 0.7}, {FileIndex(lastMove.TargetSquare), RankIndex(lastMove.TargetSquare)})
end

function Board:DisplayLegalMoves()
    for i, v in ipairs(moves) do
        -- print(FileIndex(v.TargetSquare), RankIndex(v.TargetSquare))
        DrawSquare({0.8, 0.1, 0.2, 0.7}, {FileIndex(v.TargetSquare), RankIndex(v.TargetSquare)})
    end
end

function Board:LoadStartPosition()
    Board:LoadPosition(startFen)
end

function Board:LoadPosition(fen)
    loadedPosition = PositionFromFen(fen)

    for squareIndex = 1, 64 do
        piece = loadedPosition.squares[squareIndex]
        self.Square[squareIndex][1] = piece
        self.Square[squareIndex][2] = true
        self.Square[squareIndex][3] = false
    end
end
