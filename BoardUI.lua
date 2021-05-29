function TryGetSquareUnderMouse(mouseWolrd)
    local file = math.floor(mouseWolrd[1] / 120)
    local rank = 7 - math.floor(mouseWolrd[2] / 120)
    selectedPieceSquare = IndexFromCoord(file, rank)
    return file >= 0 and file < 8 and rank >= 0 and rank < 8
end

function DragPiece(pieceCoord, mousePos)
    Board.Square[pieceCoord][2] = false
    local piece = Board.Square[pieceCoord][1]
    floatingPiece = {piece, mousePos}
end

function GetPieceSquare(mosuePos)
    local file = math.floor(mosuePos[1] / 120)
    local rank = 7 - math.floor(mosuePos[2] / 120)
    return IndexFromCoord(file, rank)
end
