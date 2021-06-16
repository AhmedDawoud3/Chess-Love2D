PieceList = Class {}

function PieceList:init(maxPieceCount)
    self.occupiedSquares = CreateTable(maxPieceCount)
    self.map = CreateTable(64)
    self.numPieces = 1
end

function PieceList:Count()
    return self.numPieces
end

function PieceList:AddPieceAtSquare(square)
    self.occupiedSquares[self.numPieces] = square
    self.map[square] = self.numPieces
    self.numPieces = self.numPieces + 1
end

function PieceList:RemovePieceAtSquare(square)
    local pieceIndex = self.map[square]
    self.occupiedSquares[pieceIndex] = self.occupiedSquares[self.numPieces]
    self.map[self.occupiedSquares[pieceIndex]] = pieceIndex
    self.numPieces = self.numPieces - 1
end

function PieceList:MovePiece(startSquare, targetSquare)
    local pieceIndex = self.map[startSquare]
    self.occupiedSquares[pieceIndex] = targetSquare
    self.map[targetSquare] = pieceIndex
end

-- PieceList = Class {
    
-- }

-- occupiedSquares = {}
-- map = {}
-- numPieces = 0

-- function PieceList:init(maxPieceCount)
--     occupiedSquares = CreateTable(maxPieceCount)
--     map = CreateTable(64)
-- end

-- function PieceList:Count()
--     return numPieces
-- end

-- function PieceList:AddPieceAtSquare(square)
--     occupiedSquares[numPieces] = square
--     map[square] = numPieces
--     numPieces = numPieces + 1
-- end

-- function PieceList:RemovePieceAtSquare(square)
--     local pieceIndex = map[square]
--     occupiedSquares[pieceIndex] = occupiedSquares[numPieces]
--     map[occupiedSquares[pieceIndex]] = pieceIndex
--     numPieces = numPieces - 1
-- end

-- function PieceList:movePiece(startSquare, targetSquare)
--     local pieceIndex = map[startSquare]
--     occupiedSquares[pieceIndex] = targetSquare
--     map[targetSquare] = pieceIndex
-- end
