Piece = Class {}

whiteMask = 8
blackMask = 16
colorMask = bit.bor(whiteMask, blackMask)
function Piece:init()
    self.None = 0
    self.King = 1
    self.Pawn = 2
    self.Knight = 3
    self.Bishop = 4
    self.Rook = 5
    self.Queen = 6

    self.White = 8
    self.Black = 16
end

function Piece.IsColor(piece, color)
    return bit.band(piece, colorMask) == color
end

function Piece.IsSlidingPiece(piece)
    return (bit.band(piece, 4) ~= 0)
end

function Piece.PieceType(piece)
    return bit.band(piece, 7)
end

function Piece.SameColor(square1, square2)
    piece1 = Board.Square[square1][1]
    piece2 = Board.Square[square2][1]
    if piece1 ~= 0 and piece2 ~= 0 then
        return (Piece.IsColor(piece1, Piece().White) == Piece.IsColor(piece2, Piece().White))
    end
    return false
end

function IsPiece(squareIndex)
    if IsSquare(squareIndex) then
        if Board.Square[squareIndex][1] ~= 0 then
            return true
        end
    end
    return false
end

function Piece.ReverseColor(color)
    if color == Piece().White then
        return Piece().Black
    end
    return Piece().White
end

function Piece.Promote(promotion)
    Game.Board.Square[Game.promotionSquare][1] = promotion
    Game.promotionAvalible = false
end