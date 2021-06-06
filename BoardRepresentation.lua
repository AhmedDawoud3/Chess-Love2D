fileNames = "abcdefgh"
rankNames = "12345678"

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

function LightSquare(squareIndex)
    return (FileIndex(squareIndex) + RankIndex(squareIndex)) % 2 ~= 0
end

function DarkSquare(squareIndex)
    return (FileIndex(squareIndex) + RankIndex(squareIndex)) % 2 == 0
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

function IsCheck(col)
    local eCol = Piece().ReverseColor(col)
    local t = (col == Piece().White and 'w') or 'b'
    local changedTurn = false
    local gamTurn = Game.turn
    local pType = Piece().PieceType
    local pCol = Piece.IsColor
    local gen_moves = GenerateMoves
    local gmBoard =Game.Board 

    for i, v in ipairs(gmBoard.Square) do
        if v[1] ~= 0 then
            if pCol(v[1], eCol) then
                local aMoves = gen_moves(i)
                for j, o in ipairs(aMoves) do
                    if pType(gmBoard.Square[o.TargetSquare][1]) == Piece().King then
                        return {true, o.TargetSquare}
                    end
                end
            end
        end
    end
    Game.NextTurn()
    for i, v in ipairs(gmBoard.Square) do
        if v[1] ~= 0 then
            if pCol(v[1], eCol) then
                local aMoves = gen_moves(i)
                for j, o in ipairs(aMoves) do
                    if pType(gmBoard.Square[o.TargetSquare][1]) == Piece().King then
                        Game.NextTurn()
                        return {true, o.TargetSquare}
                    end
                end
            end
        end
    end
    Game.NextTurn()

    return false
end

function CurrentlyInCheck(col)
    local pType = Piece().PieceType
    local eCol = Piece().ReverseColor(col)
    local pCol = Piece.IsColor
    Game.NextTurn()
    for i, v in ipairs(Game.Board.Square) do
        if v[1] ~= 0 and pType(v[1]) ~= Piece().King then
            if pCol(v[1], eCol) then
                local aMoves = GenerateMoves(i)
                for j, o in ipairs(aMoves) do
                    if pType(Game.Board.Square[o.TargetSquare][1]) == Piece().King then
                        Game.NextTurn()
                        return {true, o.TargetSquare}
                    end
                end
            end
        end
    end
    Game.NextTurn()
end
