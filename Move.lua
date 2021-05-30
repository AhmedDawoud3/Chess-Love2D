Move = Class {}
moves = {}
NumSquaresToEdge = {}

function Move:init(StartSquare, TargetSquare)
    self.StartSquare = StartSquare
    self.TargetSquare = TargetSquare
end

function GenerateMoves()
    moves = {}
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
    local piece = Board.Square[selectedPieceSquare][1]
    local pieceType = Piece.PieceType(piece)
    local pieceCol = (Piece().IsColor(piece, Piece().White) and Piece().White) or Piece().Black
    if pieceType == Piece().Knight then
        moves = CreateKnightMovement(selectedPieceSquare, pieceCol)
    elseif pieceType == Piece().Pawn then
        moves = CreatePawnMovement(selectedPieceSquare, pieceCol)
    elseif pieceType == Piece().Bishop then
        moves = CreateBishopMovement(selectedPieceSquare, pieceCol)
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
