Move = Class {}
moves = {}
NumSquaresToEdge = {}
oldMoves = {}
moveHistory = {}

function Move:init(StartSquare, TargetSquare)
    self.StartSquare = StartSquare
    self.TargetSquare = TargetSquare
end

function GenerateMoves(sq)
    sq = sq or selectedPieceSquare
    _moves_ = {}
    for file = 0, 7 do
        for rank = 0, 7 do
            numNorth = 7 - rank
            numSouth = rank
            numWest = file
            numEast = 7 - file

            squareIndex = rank * 8 + file

            NumSquaresToEdge[squareIndex] = {numNorth, numSouth, numWest, numEast, math.min(numNorth, numWest),
                                             math.min(numSouth, numEast), math.min(numNorth, numEast),
                                             math.min(numSouth, numWest)}
        end
    end
    local piece = Board.Square[sq][1]
    local pieceType = Piece.PieceType(piece)
    local pieceCol = (Piece().IsColor(piece, Piece().White) and Piece().White) or Piece().Black
    local t = (pieceCol == Piece().White and 'w') or 'b'
    if Game.turn == t then
        if pieceType == Piece().Knight then
            _moves_ = CreateKnightMovement(sq, pieceCol)
        elseif pieceType == Piece().Pawn then
            _moves_ = CreatePawnMovement(sq, pieceCol)
        elseif pieceType == Piece().Bishop then
            _moves_ = CreateBishopMovement(sq, pieceCol)
        elseif pieceType == Piece().Rook then
            _moves_ = CreateRookMovement(sq, pieceCol)
        elseif pieceType == Piece().Queen then
            _moves_ = CreateQueenMovement(sq, pieceCol)
        elseif pieceType == Piece().King then
            _moves_ = CreateKingMovement(sq, pieceCol)
        end
    else
        _moves_ = {}
    end
    return _moves_
end

function UndoMove()
    if #moveHistory < 2 then
        Game.Board:LoadStartPosition()
        moves = {}
        NumSquaresToEdge = {}
        oldMoves = {}
        moveHistory = {}
    else
        Game.Board:LoadPosition(moveHistory[#moveHistory - 1])
        table.remove(moveHistory, #moveHistory)
        table.remove(oldMoves, #oldMoves)
        Game:NextTurn()
    end
end

function DistanceBetweenSquares(square1, square2, dist)
    local sqX1, sqY1 = SquareToCordinate(square1)
    local sqX2, sqY2 = SquareToCordinate(square2)
    return Dist(sqX1, sqY1, sqX2, sqY2) < dist
end

function Dist(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
