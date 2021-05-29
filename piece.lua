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
    print(bit.band(piece, colorMask) == color)
end
