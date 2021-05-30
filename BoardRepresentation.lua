function SquareToCordinate(square)
    square = square
    -- local file = square % 7
    local file = FileIndex(square)
    local rank = RankIndex(square)
    local placeX = file * Loader.pieceSize
    local placeY = rank * Loader.pieceSize
    return placeX, placeY
end

function RankIndex(squareIndex)
    return 7 - bit.rshift(squareIndex - 1, 3)
end

function FileIndex(squareIndex)
    return bit.band(squareIndex - 1, 7)
end

function IndexFromCoord(fileIndex, rankIndex)
    return rankIndex * 8 + fileIndex + 1
end

function LightSquare(fileIndex, rankIndex)
    return (fileIndex + rankIndex) % 2 ~= 0
end

function IsClearSquare(squareIndex)
    if IsSquare(squareIndex) then
        if Board.Square[squareIndex][1] == 0 then
            return true
        end
    end
    return false
end

function IsMoved(squareIndex)
    return Board.Square[squareIndex][3]
end

function IsSquare(squareIndex)
    return squareIndex > 0 and squareIndex <= 64
end
