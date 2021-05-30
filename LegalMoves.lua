-- NumSquaresToEdge = {}
-- function PrecomputedMoveData()
--     for file = 0, 7 do
--         for rank = 0, 7 do
--             numNorth = 7 - rank
--             numSouth = rank
--             numWest = file
--             numEast = 7 - file
--             squareIndex = rank * 8 + file + 1
--             NumSquaresToEdge[squareIndex] = {numNumber, numSouth, numWest, numEast, math.min(numNorth, numWest),
--                                              math.min(numSouth, numEast),
--                                               math.min(numNorth, numEast),
--                                              math.min(numSouth, numWest)}
--         end
--     end
-- end
function CreatePawnMovement(square, pieceCol)
    local moves_ = {}
    local _moves_ = {}
    local index = (((pieceCol == Piece().White) and 1) or -1)
    if RankIndex(square) >= 0 and RankIndex(square) < 7 then
        if IsClearSquare(square + 8 * index) then
            if not IsMoved(square) then
                if Board.Square[square + 16 * index][1] == 0 then
                    table.insert(moves_, Move(square, square + 16 * index))
                end
            end
            table.insert(moves_, Move(square, square + 8 * index))
        end
        if IsSquare(square + 9 * index) then
            if not Piece.SameColor(square, square + 9 * index) and not IsClearSquare(square + 9 * index) and
                (DistanceBetweenSquares(square + 9 * index, square, 200)) then
                table.insert(moves_, Move(square, square + 9 * index))
            end
        end
        if IsSquare(square + 7 * index) then
            if not Piece.SameColor(square, square + 7 * index) and not IsClearSquare(square + 7 * index) and
                (DistanceBetweenSquares(square + 7 * index, square, 200)) then
                table.insert(moves_, Move(square, square + 7 * index))
            end
        end
        for i, v in ipairs(moves_) do
            table.insert(_moves_, v)
        end
    end
    return _moves_
end

function GenerateSlidingMove(startSquare, piece)
    startDirIndex = ((Piece().PieceType(piece) == Piece().Bishop) and 4) or 0
    endDirIndex = ((Piece().PieceType(piece) == Piece().Rook) and 4) or 8
    for directionIndex = startDirIndex, 7 do
        print(NumSquaresToEdge[startSquare + 1][directionIndex])
        for n = endDirIndex, NumSquaresToEdge[startSquare + 1][directionIndex + 1] do
            local targetSquare = startSquare + DirectionOffsets[directionIndex + 1] * (n + 1)
            pieceOnTargetSquare = Board.Square[targetSquare + 1]

            if (Piece().IsColor(pieceOnTargetSquare, Piece().White)) then
                break
            end

            table.insert(moves, Move(startSquare, targetSquare))

            if (Piece().IsColor(pieceOnTargetSquare, Piece().Black)) then
                break
            end

        end
    end
end

function CreateKnightMovement(square, pieceCol)
    local moves_ = {}
    local _moves_ = {}
    table.insert(moves_, Move(square, square + 6))
    table.insert(moves_, Move(square, square + 10))
    table.insert(moves_, Move(square, square + 15))
    table.insert(moves_, Move(square, square + 17))
    table.insert(moves_, Move(square, square - 6))
    table.insert(moves_, Move(square, square - 10))
    table.insert(moves_, Move(square, square - 15))
    table.insert(moves_, Move(square, square - 17))
    for i, v in ipairs(moves_) do
        if v.TargetSquare >= 0 and v.TargetSquare <= 64 then
            local sqX1, sqY1 = SquareToCordinate(v.TargetSquare)
            local sqX2, sqY2 = SquareToCordinate(v.StartSquare)
            if Dist(sqX1, sqY1, sqX2, sqY2) < 400 then
                if not Piece().IsColor(Board.Square[v.TargetSquare][1], pieceCol) then
                    table.insert(_moves_, v)
                end
            end
        end
    end
    return _moves_
end

