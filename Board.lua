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
        end
    end
end

function DrawSquare(col, pos)
    love.graphics.setColor(col[1], col[2], col[3], col[4])
    love.graphics.rectangle("fill", pos[1] * squareTileWidth, pos[2] * squareTileHeight, squareTileWidth,
        squareTileHeight)
end
