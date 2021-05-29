lightCol = {241 / 255, 217 / 255, 192 / 255, 1}
darkCol = {169 / 255, 122 / 255, 101 / 255, 1}
WIDTH = 960
HEIGHT = 960
squareTileWidth = WIDTH / 8
squareTileHeight = HEIGHT / 8

function CreateGraphicalBoard()
    for file = 0, 8 do
        for rank = 0, 8 do
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
end
Board = Class {}
function Board:init()
    self.Square = {}
    for i = 1, 64 do
        self.Square[i] = 0
    end
end

function Board:DisplayPieces()
    for i, v in ipairs(self.Square) do
        if v ~= 0 then
            local p = Loader:GetPiece(v)
            if p ~= nil then
                x, y = SquareToCordinate(i)
                love.graphics.draw(Loader.piecesTexture, p, x, y)
            end
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
        self.Square[squareIndex] = piece
    end
end
