Move = Class {}
moves = {}
NumSquaresToEdge = {}
oldMoves = {}
moveHistory = {}

Flag = {
    None = 0,
    EnPassantCapture = 1,
    Castling = 2,
    PromoteToQueen = 3,
    PromoteToKnight = 4,
    PromoteToRook = 5,
    PromoteToBishop = 6,
    PawnTwoForward = 7
}

startSquareMask = 63
targetSquareMask = 4032
flagMask = 61440

function Move:init(moveValue, startSquare, targetSquare, flag)
    if moveValue then
        self.moveValue = moveValue
        return
    end
    if startSquare and targetSquare then
        if flag then
            self.moveValue = bit.lshift(bit.bor(bit.lshift(bit.bor(startSquare, targetSquare), 6), flag), 12)
            return
        end
        self.moveValue = bit.lshift(bit.bor(startSquare, targetSquare), 6)
    end
end

function Move:StartSquare()
    return bit.band(self.moveValue, startSquareMask)
end

function Move:TargerSquare()
    return bit.rshift(bit.band(self.moveValue, targetSquareMask), 6)
end

function Move:IsPromotion()
    flag = self:MoveFlag()
    return flag == Flag.PromoteToQueen or flag == Flag.PromoteToRook or flag == Flag.PromoteToKnight or flag ==
               Flag.PromoteToBishop
end

function Move:MoveFlag()
    return bit.rshift(moveValue, 12)
end

function Move.InvalidMove()
    return Move(0)
end

function Move.SameMove(a, b)
    return a.moveValue == b.moveValue
end

function Move:IsInvalid()
    return self.moveValue == 0
end

function Move:Name()
    return tostring(SquareNameFromIndex(Move:StartSquare())) .. '-' .. tostring(SquareNameFromIndex(Move:TargetSquare()))
end

function Move:PromotePeiceType()
    mvFlag = self:MoveFlag()
    if mvFlag == PromoteToRook then
        return Piece.Rook
    elseif mvFlag == PromoteToKnight then
        return Piece.Knight
    elseif mvFlag == PromoteToBishop then
        return Piece.Bishop
    elseif mvFlag == PromoteToQueen then
        return Piece.Queen
    end
    return Piece.None
end

function GenerateMoves(sq)

    _moves_ = {}
    local piece = Game.Board.Square[sq][1]
    local pieceType = Piece.PieceType(piece)
    local pieceCol = (Piece.IsColor(piece, Piece.White) and Piece.White) or Piece.Black
    local t = (pieceCol == Piece.White and 'w') or 'b'
    if Game.turn == t then
        if pieceType == Piece.Knight then
            _moves_ = CreateKnightMovement(sq, pieceCol)
        elseif pieceType == Piece.Pawn then
            _moves_ = CreatePawnMovement(sq, pieceCol)
        elseif pieceType == Piece.Bishop then
            _moves_ = CreateBishopMovement(sq, pieceCol)
        elseif pieceType == Piece.Rook then
            _moves_ = CreateRookMovement(sq, pieceCol)
        elseif pieceType == Piece.Queen then
            _moves_ = CreateQueenMovement(sq, pieceCol)
        elseif pieceType == Piece.King then
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
    if Game.promotionAvalible then
        Game.promotionAvalible = false
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
