Loader = Class {}
function Loader:init()
    self.piecesTexture = love.graphics.newImage("pieces.png")
    self.pieceSize = 120
    self.pieces = {
        {bit.bor(Piece().Black, Piece().King),love.graphics.newQuad(self.pieceSize * 0, self.pieceSize * 1, self.pieceSize, self.pieceSize, self.piecesTexture)}, 
        {bit.bor(Piece().White, Piece().King),love.graphics.newQuad(self.pieceSize * 0, self.pieceSize * 0, self.pieceSize, self.pieceSize, self.piecesTexture)}, 
        {bit.bor(Piece().White, Piece().Queen),love.graphics.newQuad(self.pieceSize * 1, self.pieceSize * 0, self.pieceSize, self.pieceSize, self.piecesTexture)}, 
        {bit.bor(Piece().Black, Piece().Queen),love.graphics.newQuad(self.pieceSize * 1, self.pieceSize * 1, self.pieceSize, self.pieceSize, self.piecesTexture)}, 
        {bit.bor(Piece().White, Piece().Bishop),love.graphics.newQuad(self.pieceSize * 2, self.pieceSize * 0, self.pieceSize, self.pieceSize, self.piecesTexture)},
        {bit.bor(Piece().Black, Piece().Bishop),love.graphics.newQuad(self.pieceSize * 2, self.pieceSize * 1, self.pieceSize, self.pieceSize, self.piecesTexture)},
        {bit.bor(Piece().White, Piece().Knight),love.graphics.newQuad(self.pieceSize * 3, self.pieceSize * 0, self.pieceSize, self.pieceSize, self.piecesTexture)}, 
        {bit.bor(Piece().Black, Piece().Knight),love.graphics.newQuad(self.pieceSize * 3, self.pieceSize * 1, self.pieceSize, self.pieceSize, self.piecesTexture)}, 
        {bit.bor(Piece().White, Piece().Rook),love.graphics.newQuad(self.pieceSize * 4, self.pieceSize * 0, self.pieceSize, self.pieceSize, self.piecesTexture)}, 
        {bit.bor(Piece().Black, Piece().Rook),love.graphics.newQuad(self.pieceSize * 4, self.pieceSize * 1, self.pieceSize, self.pieceSize, self.piecesTexture)}, 
        {bit.bor(Piece().White, Piece().Pawn),love.graphics.newQuad(self.pieceSize * 5, self.pieceSize * 0, self.pieceSize, self.pieceSize, self.piecesTexture)}, 
        {bit.bor(Piece().Black, Piece().Pawn),love.graphics.newQuad(self.pieceSize * 5, self.pieceSize * 1, self.pieceSize, self.pieceSize, self.piecesTexture)}
    }
end

function Loader:GetPiece(id)
    for i, v in ipairs(self.pieces) do
        if id == v[1] then 
            return v[2]
        end
    end
end