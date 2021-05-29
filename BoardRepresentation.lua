function SquareToCordinate(square)
    square = square - 1
    -- local file = square % 7
    local file = FileIndex(square)
    local rank = RankIndex(square)
    print(file)
    local placeX = file * Loader.pieceSize
    local placeY = rank * Loader.pieceSize
    return placeX, placeY
end

function RankIndex(squareIndex)
    return 7 - bit.rshift(squareIndex, 3)
end

function FileIndex(squareIndex)
    return bit.band(squareIndex, 7)
end

function IndexFromCoord(fileIndex, rankIndex)
    return rankIndex * 8 + fileIndex - 1
end

function LightSquare(fileIndex, rankIndex)
    return (fileIndex + rankIndex) % 2 ~= 0
end
