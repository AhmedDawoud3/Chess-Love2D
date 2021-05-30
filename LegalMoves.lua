function PrecomputedMoveData()
    NumSquaresToEdge = {}
    for file = 0, 7 do
        for rank = 0, 7 do
            numNorth = 7 - rank
            numSouth = rank
            numWest = file
            numEast = 7 - file
            squareIndex = rank * 8 + file + 1
            NumSquaresToEdge[squareIndex] = {numNumber, numSouth, numWest, numEast, math.min(numNorth, numWest),
                                             math.min(numSouth, numEast), math.min(numNorth, numEast),
                                             math.min(numSouth, numWest)}
        end
    end
    return NumSquaresToEdge
end

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
    local moves_ = {}
    startDirIndex = ((Piece().PieceType(piece) == Piece().Bishop) and 5) or 1
    endDirIndex = ((Piece().PieceType(piece) == Piece().Rook) and 5) or 9
    for directionIndex = startDirIndex, 7 do
        for n = endDirIndex, NumSquaresToEdge[startSquare][directionIndex] do
            local targetSquare = startSquare + DirectionOffsets[directionIndex] * (n + 1)
            pieceOnTargetSquare = Board.Square[targetSquare]

            if (Piece().IsColor(pieceOnTargetSquare, Piece().White)) then
                break
            end
            table.insert(moves_, Move(startSquare, targetSquare))
            if (Piece().IsColor(pieceOnTargetSquare, Piece().Black)) then
                break
            end
        end
    end
    return moves_
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

function CreateBishopMovement(square, pieceCol)
    local moves_ = {}
    local _moves_ = {}
    for i = -1, 1, 2 do
        for j = 1, 8 do
            if IsSquare(square + i * j * 9) then
                if Piece.SameColor(square, square + i * j * 9) then
                    break
                else
                    table.insert(moves_, Move(square, square + i * j * 9))
                    if not Piece.SameColor(square, square + i * j * 9) and not IsClearSquare(square + i * j * 9) then
                        break
                    end
                end
            else
                break
            end
        end
        for j = 1, 8 do
            if IsSquare(square + i * j * 7) then
                if Piece.SameColor(square, square + i * j * 7) then
                    break
                else
                    table.insert(moves_, Move(square, square + i * j * 7))
                    if not Piece.SameColor(square, square + i * j * 7) and not IsClearSquare(square + i * j * 7) then
                        break
                    end
                end
            else
                break
            end
        end
    end

    for i, v in ipairs(moves_) do
        if DarkSquare(v.StartSquare) == DarkSquare(v.TargetSquare) then
            table.insert(_moves_, v)
        end
    end
    return _moves_
end

function CreateRookMovement(square, pieceCol)
    local moves_ = {}
    local _moves_ = {}
    local pRank = RankIndex(square)
    local pFile = FileIndex(square)
    for i = -1, 1, 2 do
        for k = 1, 7 do
            local sq = square + i * k
            if RankIndex(sq) == pRank and IsSquare(sq) then
                if Piece().IsColor(Board.Square[sq][1], pieceCol) and IsPiece(sq) then
                    break
                end
                table.insert(moves_, Move(square, sq))
                if Piece().IsColor(Board.Square[sq][1], Piece.ReverseColor(pieceCol)) and IsPiece(sq) then
                    break
                end
            end
        end
        for k = 1, 7 do
            local sq = square + i * (k * 8)
            if FileIndex(sq) == pFile and IsSquare(sq) then
                if Piece().IsColor(Board.Square[sq][1], pieceCol) and IsPiece(sq) then
                    break
                end
                table.insert(moves_, Move(square, sq))
                if Piece().IsColor(Board.Square[sq][1], Piece.ReverseColor(pieceCol)) and IsPiece(sq) then
                    break
                end
            end
        end
    end

    return moves_
end

function CreateQueenMovement(square, pieceCol)
    local moves_ = {}
    local moves_D = {}
    local pRank = RankIndex(square)
    local pFile = FileIndex(square)

    for i = -1, 1, 2 do
        for k = 1, 7 do
            local sq = square + i * k
            if RankIndex(sq) == pRank and IsSquare(sq) then
                if Piece().IsColor(Board.Square[sq][1], pieceCol) and IsPiece(sq) then
                    break
                end
                table.insert(moves_, Move(square, sq))
                if Piece().IsColor(Board.Square[sq][1], Piece.ReverseColor(pieceCol)) and IsPiece(sq) then
                    break
                end
            end
        end
        for k = 1, 7 do
            local sq = square + i * (k * 8)
            if FileIndex(sq) == pFile and IsSquare(sq) then
                if Piece().IsColor(Board.Square[sq][1], pieceCol) and IsPiece(sq) then
                    break
                end
                table.insert(moves_, Move(square, sq))
                if Piece().IsColor(Board.Square[sq][1], Piece.ReverseColor(pieceCol)) and IsPiece(sq) then
                    break
                end
            end
        end
    end

    for i = -1, 1, 2 do
        for j = 1, 8 do
            if IsSquare(square + i * j * 9) then
                if Piece.SameColor(square, square + i * j * 9) then
                    break
                else
                    table.insert(moves_D, Move(square, square + i * j * 9))
                    if not Piece.SameColor(square, square + i * j * 9) and not IsClearSquare(square + i * j * 9) then
                        break
                    end
                end
            else
                break
            end
        end
        for j = 1, 8 do
            if IsSquare(square + i * j * 7) then
                if Piece.SameColor(square, square + i * j * 7) then
                    break
                else
                    table.insert(moves_D, Move(square, square + i * j * 7))
                    if not Piece.SameColor(square, square + i * j * 7) and not IsClearSquare(square + i * j * 7) then
                        break
                    end
                end
            else
                break
            end
        end
    end

    for i, v in ipairs(moves_D) do
        if DarkSquare(v.StartSquare) == DarkSquare(v.TargetSquare) then
            table.insert(moves_, v)
        end
    end

    return moves_
end
