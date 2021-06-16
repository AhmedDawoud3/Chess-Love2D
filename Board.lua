lightCol = {241 / 255, 217 / 255, 192 / 255, 1}
darkCol = {169 / 255, 122 / 255, 101 / 255, 1}
WIDTH = 960
HEIGHT = 960
squareTileWidth = WIDTH / 8
squareTileHeight = HEIGHT / 8
local queenShadow = 0
local rookShadow = 0
local knightShadow = 0
local bishopShadow = 0

function CreateGraphicalBoard()
    for file = 0, 7 do
        for rank = 0, 7 do
            isLightSquare = (file + rank) % 2 ~= 0
            squareColour = (isLightSquare and darkCol) or lightCol
            position = {file, rank}
            DrawSquare(squareColour, position)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function DrawSquare(col, pos)
    love.graphics.setColor(col[1], col[2], col[3], col[4])
    love.graphics.rectangle("fill", pos[1] * squareTileWidth, pos[2] * squareTileHeight, squareTileWidth,
        squareTileHeight)
    love.graphics.setColor(1, 1, 1, 1)
end

Board = Class {}
whiteCastleKingsideMask = 65534
whiteCastleQueensideMask = 65533
blackCastleKingsideMask = 65531
blackCastleQueensideMask = 65527

whiteCastleMask = bit.band(whiteCastleKingsideMask, whiteCastleQueensideMask)
blackCastleMask = bit.band(blackCastleKingsideMask, blackCastleQueensideMask)

function Board:init()

    self.WhiteIndex = 1
    self.BlackIndex = 2

    self.Square = {}
    for i = 1, 64 do
        self.Square[i] = {0, false, true}
    end

    self.LightPieces = {}
    self.DarkPieces = {}
    self.WhiteToMove = 0
    self.ColorToMove = 0
    self.OpponentColor = 0
    self.ColorToMoveIndex = 0

    self.gameStateHistory = {}
    self.currentState = nil

    self.plyCount = 0
    self.fiftyMoveCounter = 0

    self.ZobristKey = nil

    self.RepetitionPositionHistory = {}

    self.KingSquare = CreateTable(2)

    self.rooks = {PieceList(10), PieceList(10)}
    self.bishops = {PieceList(10), PieceList(10)}
    self.queens = {PieceList(9), PieceList(9)}
    self.knights = {PieceList(10), PieceList(10)}
    self.pawns = {PieceList(8), PieceList(8)}
    local emptyList = PieceList(0)

    self.alPieceLists = {
        emptyList,
        emptyList,
        self.pawns[self.WhiteIndex],
        self.knights[self.WhiteIndex],
        emptyList,
        self.bishops[self.WhiteIndex],
        self.rooks[self.WhiteIndex],
        self.queens[self.WhiteIndex],
        emptyList,
        emptyList,
        self.pawns[self.BlackIndex],
        self.knights[self.BlackIndex],
        emptyList,
        self.bishops[self.BlackIndex],
        self.rooks[self.BlackIndex],
        self.queens[self.BlackIndex],
    }

end

function Board:GetPieceList(pieceType, colorIndex)
    return self.allPieceList.occupiedSquares[colorIndex * 8 + pieceType]
end

function Board:MakeMove(move, inSearch)
    inSearch = inSearch or false

    self.oldEnPassantFile = bit.band(bit.rshift(self.currentState, 4), 15)
    self.originalCastleState = bit.band(self.currentState, 15)
    self.newCastleState = self.originalCastleState
    self.currentState = 0

    self.opponentColorIndex = 1 - self.colorToMoveIndex
    self.moveFrom = move.StartSquare
    self.moveTo = move.TargetSquare

    self.capturedPieceType = Piece.PieceType(self.Square[self.moveTo])
    self.movePiece = self.Square[self.moveFrom]
    self.movePieceType = Piece.PieceType(self.movePiece)

    self.moveFlag = move:MoveFlag()
    self.isPromotion = move:IsPromotion()
    self.isEnPassant = self.moveFlag == Flag.EnPassantCapture

    self.currentGameState = bit.bor(self.currentGameState, bit.lshift(self.capturedPieceType, 8))

    if self.capturedPieceType ~= 0 and not self.isEnPassant then
        self:GetPieceList(self.capturedPieceType, self.opponentColorIndex):RemovePieceAtSquare(self.moveTo)
    end

    if self.movePieceType == Piece.King then
        self.KingSquare[self.colorToMoveIndex] = self.moveTo
        self.newCastleState = bit.band(self.newCastleState, self.WhiteToMove and whiteCastleMask or blackCastleMask)
    else
        GetPieceList(self.movePieceType, self.colorToMoveIndex):MovePiece(self.moveFrom, self.moveTo)
    end

    self.pieceOnTargetSquare = self.movePiece

    if self.isPromotion then
        self.promoteType = 0
        if self.moveFlag == Flag.PromoteToQueen then
            self.promoteType = Piece.Queen
            self.queens[self.ColorToMoveIndex]:AddPieceAtSquare(self.moveTo)
        elseif self.moveFlag == Flag.PromoteToRook then
            self.promoteType = Piece.Rook
            self.rooks[self.ColorToMoveIndex]:AddPieceAtSquare(self.moveTo)
        elseif self.moveFlag == Flag.PromoteToBishop then
            self.promoteType = Piece.Bishop
            self.bishops[self.ColorToMoveIndex]:AddPieceAtSquare(self.moveTo)
        elseif self.moveFlag == Flag.PromoteToKnight then
            self.promoteType = Piece.Rook
            self.knights[self.ColorToMoveIndex]:AddPieceAtSquare(self.moveTo)
        end
        self.pieceOnTargetSquare = bit.bor(self.promoteType, self.ColorToMove)
        pawns[self.ColorToMoveIndex]:RemovePieceAtSquare(self.moveTo)
    else
        if self.moveFlag == Flag.EnPassantCapture then
            self.epPawnSquare = self.moveTo + self.ColorToMove == Piece.White and -8 or 8
            self.currentGameState = bit.bor(self.currentGameState, bit.lshift(self.Square[self.epSquare], 8))
            self.Square[self.epPawnSquare] = {0, false, true}
            self.pawns[self.opponentColorIndex]:RemovePieceAtSquare(self.epPawnSquare)
        elseif self.moveFlag == Flag.Castling then
            self.kingSide = self.moveTo == BoardRepresentation.g1 or self.moveTo == BoardRepresentation.g8
            self.castlingRookFromIndex = self.kingSide and self.moveTo + 1 or self.moveTo - 2
            self.castlingRookToIndex = self.kingSide and self.moveTo - 1 or self.moveTo + 1

            self.Square[self.castlingRookFromIndex] = {0, false, true}
            self.Square[self.castlingRookToIndex] = {bit.bor(Piece.Rook, self.ColorToMove), true, false}

            self.rooks[self.colorToMoveIndex]:MovePiece(self.castlingRookFromIndex, self.castlingRookToIndex)
        end
    end

    self.Square[self.moveTo] = {self.pieceOnTargetSquare, true, true}
    self.Square[self.moveFrom] = {0, false, true}

    if self.moveFlag == Flag.PawnTwoForward then
        self.file = FileIndex(self.moveFrom) + 1
        self.currentGameState = bit.bor(self.currentGameState, bit.lshift(self.file, 4))
    end

    if self.originalCastleState ~= 0 then
        if self.moveTo == BoardRepresentation.h1 or self.moveFrom == BoardRepresentation.h1 then
            self.newCastleState = bit.band(self.newCastleState, self.whiteCastleKingsideMask)
        elseif self.moveTo == BoardRepresentation.a1 or self.moveFrom == BoardRepresentation.a1 then
            self.newCastleState = bit.band(self.newCastleState, self.whiteCastleQueensideMask)
        end
        if self.moveTo == BoardRepresentation.h8 or self.moveFrom == BoardRepresentation.h8 then
            self.newCastleState = bit.band(self.newCastleState, self.blackCastleKingsideMask)
        elseif self.moveTo == BoardRepresentation.a8 or self.moveFrom == BoardRepresentation.a8 then
            self.newCastleState = bit.band(self.newCastleState, self.blackCastleQueensideMask)
        end
    end

    self.currentGameState = bit.bor(self.currentGameState, self.newCastleState)
    self.currentGameState = bit.lshift(bit.bor(self.currentGameState, self.fiftyCounter), 14)

    table.insert(self.gameStateHistory, self.currentGameState)

    self.WhiteToMove = not self.WhiteToMove
    self.ColorToMove = self.WhiteToMove and Piece.White or Piece.Black
    self.OpponentColor = self.WhiteToMove and Piece.Black or Piece.White
    self.ColorToMoveIndex = 1 - self.colorToMoveIndex

    self.plyCount = self.plyCount + 1
    self.fiftyCounter = self.fiftyCounter + 1
end

function Board:UnmakeMove(move, inSearch)
    inSearch = inSearch or false

    self.opponentColorIndex = self.ColorToMoveIndex
    self.undoingWhiteMove = self.OpponentColor == Piece.White
    self.ColorToMove = self.OpponentColor
    self.OpponentColor = self.undoingWhiteMove and Piece.Black or Piece.White
    self.ColorToMoveIndex = 1 - self.ColorToMoveIndex
    self.WhtieToMove = not self.WhtieToMove

    self.originalCastleState = bit.band(self.currentGameState, 15)

    self.capturedPieceType = bit.band(bit.rshift(self.currentGameState, 8), 63)
    self.capturedPiece = self.capturedPieceType == 0 and 0 or bit.bor(self.capturedPieceType, self.OpponentColor)

    self.movedFrom = move:StartSquare()
    self.movedTo = move:TargetSquare()
    self.moveFlags = move:MoveFlag()
    self.isEnPassant = self.moveFlags == Flags.EnPassantCapture
    self.isPromotion = move:IsPromotion()

    self.toSquarePieceType = Piece.PieceType(self.Square[self.movedTo][1])
    self.movedPieceType = self.isPromotion and Piece.Pawn or self.toSquarePieceType

    self.oldEnPassantFile = bit.band(bit.rshift(self.currentGameState, 4), 15)

    if self.capturedPieceType ~= 0 and not self.isEnPassant then
        self:GetPieceList(self.capturedPieceType, self.opponentColorIndex).AddPieceAtSquare(self.movedTo)
    end

    if self.movedPieceType == Piece.King then
        self.KingSquare[colorToMoveIndex] = self.movedFrom
    elseif not self.isPromotion then
        self.GetPieceList(self.movedPieceType, self.colorToMoveIndex).MovePiece(self.moveTo, self.moveFrom)
    end

    self.Square[self.movedFrom] = {bit.bor(self.movedPieceType, self.ColorToMove), true, true}
    self.Square[self.movedTo] = {self.capturedPiece, true, true}

    if self.isPromotion then
        self.pawns[self.colorToMoveIndex].AddPieceAtSquare(self.movedFrom)
        if self.moveFlags == Flag.PromoteToQueen then
            self.queens[self.colorToMoveIndex].RemovePieceAtSquare(self.movedTo)
        elseif self.moveFlags == Flag.PromoteToKnight then
            self.knights[self.colorToMoveIndex].RemovePieceAtSquare(self.movedTo)
        elseif self.moveFlags == Flag.PromoteToRook then
            self.rooks[self.colorToMoveIndex].RemovePieceAtSquare(self.movedTo)
        elseif self.moveFlags == Flag.PromoteToBishop then
            self.bishops[self.colorToMoveIndex].RemovePieceAtSquare(self.movedTo)
        end
    elseif self.isEnPassant then
        self.epIndex = self.movedTo + ((self.ColorToMove == Piece.White) and -8 or 8)
        self.Square[self.movedTo] = {0, false, true}
        self.Square[self.epIndex] = {self.capturedPiece, true, true}
        self.pawns[self.opponentColorIndex].AddPieceAtSquare(self.epIndex)
    elseif self.moveFlags == Flag.Castling then
        self.kingSide = self.movedTo == 7 or self.moveTo == 63
        self.castlingRookFromIndex = self.kingSide and self.movedTo + 1 or self.moveTo - 2
        self.castlingRookToIndex = self.kingSide and self.movedTo - 1 or self.movedTo + 1

        self.Square[self.castlingRookToIndex] = {0, false, true}
        self.Square[self.castlingRookFromIndex] = {bit.bor(Piece.Rook, self.ColorToMove), true, true}

        self.rooks[self.ColorToMove].MovePiece(self.castlingRookToIndex, self.castlingRookFromIndex)
    end
    table.remove(self.gameStateHistory, #self.gameStateHistory)

    self.currentGameState = self.gameStateHistory[#self.gameStateHistory]

    self.fiftyCounter = vir.rshift(bit.band(self.currentGameState and 4294950912), 14)

    self.plyCount = self.plyCount - 1

end

function Board:DisplayPieces()
    for i, v in ipairs(self.Square) do
        if v[1] ~= 0 then
            local p = Loader:GetPiece(v[1])
            if p ~= nil and v[2] then
                local x, y = SquareToCordinate(i)

                love.graphics.draw(Loader.piecesTexture, p, x, y)
            end
        end
    end
    if floatingPiece then
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(floatingPiece[1]), floatingPiece[2][1] - 60,
            floatingPiece[2][2] - 60)
    end
end

function Board:DisplayLastMoves()
    DrawSquare({0.78, 0.78, 0.24, 0.5},
        {FileIndex(oldMoves[#oldMoves].StartSquare), RankIndex(oldMoves[#oldMoves].StartSquare)})
    DrawSquare({0.78, 0.78, 0.24, 0.7},
        {FileIndex(oldMoves[#oldMoves].TargetSquare), RankIndex(oldMoves[#oldMoves].TargetSquare)})
end

function Board:DisplayLegalMoves()
    for i, v in ipairs(moves) do
        if v then
            DrawSquare({0.8, 0.1, 0.2, 0.7}, {FileIndex(v.TargetSquare), RankIndex(v.TargetSquare)})
        end
    end
    if selectedPieceSquare and #moves > 0 then
        DrawSquare({1, 0.65, 0.2, 0.8}, {FileIndex(selectedPieceSquare), RankIndex(selectedPieceSquare)})
    end
end

function Board:DisplayChecks()
    if IsCheck(Piece().Black) then
        DrawSquare({0.4, 0.8, 0.2, 0.7}, {FileIndex(IsCheck(Piece().Black)[2]), RankIndex(IsCheck(Piece().Black)[2])})
    end
    if IsCheck(Piece().White) then
        DrawSquare({0.4, 0.8, 0.2, 0.7}, {FileIndex(IsCheck(Piece().White)[2]), RankIndex(IsCheck(Piece().White)[2])})
    end
    -- _x__ = GetAllLegalMoves(Piece().Black)
    -- print(#_x__)
    -- for _, a in ipairs(_x__) do
    --     -- DrawSquare({0.4, 0.6, 0.2, 0.7}, {FileIndex(a.TargetSquare), RankIndex(a.TargetSquare)})
    --     DrawSquare({0.4, 0.2, 0.2, 0.7}, {FileIndex(a.StartSquare), RankIndex(a.StartSquare)})
    -- end
end

function Board:GetPiecePromotion()
    if Game.promotionAvalible == true then
        local col = Game.promotionColor == Piece().White and Piece().Black or Piece().White
        local mouseX = love.mouse.getX()
        local mouseY = love.mouse.getY()
        love.mouse.setCursor()
        love.graphics.setColor(0.1, 0.1, 0.1, 0.7)
        love.graphics.rectangle("fill", 0, 0, 960, 960)

        -- Queen
        love.graphics.setColor(((241 + 168) / 2) / 255 + queenShadow / 50, ((217 + 122) / 2) / 255 + queenShadow / 50,
            ((192 + 101) / 2) / 255 + queenShadow / 100, 1)
        love.graphics.rectangle("fill", 1 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Queen, col)),
            1 * squareTileWidth + squareTileWidth / 4 - queenShadow,
            2 * squareTileHeight + squareTileHeight / 4 + queenShadow, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Queen, col)),
            1 * squareTileWidth + squareTileWidth / 4, 2 * squareTileHeight + squareTileHeight / 4, 0, 1.5, 1.5)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 1 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        if CheckMouseCollision(mouseX, mouseY, squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2) then
            queenShadow = math.min(queenShadow + 1, 10)
            love.mouse.setCursor((love.mouse.getSystemCursor("hand")))
            if love.mouse.isDown(1) then
                love.mouse.setCursor()
                Piece().Promote(bit.bor(Piece().Queen, col))
                queenShadow = 0
            end
        else
            queenShadow = math.max(queenShadow - 1, 0)
        end

        -- Rook
        love.graphics.setColor(((241 + 168) / 2) / 255 + rookShadow / 50, ((217 + 122) / 2) / 255 + rookShadow / 50,
            ((192 + 101) / 2) / 255 + rookShadow / 100, 1)
        love.graphics.rectangle("fill", 5 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Rook, col)),
            5 * squareTileWidth + squareTileWidth / 4 - rookShadow,
            2 * squareTileHeight + squareTileHeight / 4 + rookShadow, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Rook, col)),
            5 * squareTileWidth + squareTileWidth / 4, 2 * squareTileHeight + squareTileHeight / 4, 0, 1.5, 1.5)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 5 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        if CheckMouseCollision(mouseX, mouseY, 5 * squareTileWidth, 2 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2) then
            rookShadow = math.min(rookShadow + 1, 10)
            love.mouse.setCursor((love.mouse.getSystemCursor("hand")))
            if love.mouse.isDown(1) then
                love.mouse.setCursor()
                Piece().Promote(bit.bor(Piece().Rook, col))
                rookShadow = 0
            end
        else
            rookShadow = math.max(rookShadow - 1, 0)
        end

        -- Bishop
        love.graphics.setColor(((241 + 168) / 2) / 255 + bishopShadow / 50, ((217 + 122) / 2) / 255 + bishopShadow / 50,
            ((192 + 101) / 2) / 255 + bishopShadow / 100, 1)
        love.graphics.rectangle("fill", 1 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Bishop, col)),
            1 * squareTileWidth + squareTileWidth / 4 - bishopShadow,
            5 * squareTileHeight + squareTileHeight / 4 + bishopShadow, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Bishop, col)),
            1 * squareTileWidth + squareTileWidth / 4, 5 * squareTileHeight + squareTileHeight / 4, 0, 1.5, 1.5)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 1 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        if CheckMouseCollision(mouseX, mouseY, squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2) then
            bishopShadow = math.min(bishopShadow + 1, 10)
            love.mouse.setCursor((love.mouse.getSystemCursor("hand")))
            if love.mouse.isDown(1) then
                love.mouse.setCursor()
                bishopShadow = 0
                Piece().Promote(bit.bor(Piece().Bishop, col))
            end
        else
            bishopShadow = math.max(bishopShadow - 1, 0)
        end

        -- Knight
        love.graphics.setColor(((241 + 168) / 2) / 255 + knightShadow / 50, ((217 + 122) / 2) / 255 + knightShadow / 50,
            ((192 + 101) / 2) / 255 + knightShadow / 100, 1)
        love.graphics.rectangle("fill", 5 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Knight, col)),
            5 * squareTileWidth + squareTileWidth / 4 - knightShadow,
            5 * squareTileHeight + squareTileHeight / 4 + knightShadow, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Loader.piecesTexture, Loader:GetPiece(bit.bor(Piece().Knight, col)),
            5 * squareTileWidth + squareTileWidth / 4, 5 * squareTileHeight + squareTileHeight / 4, 0, 1.5, 1.5)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 5 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2, 50, 50)
        love.graphics.setLineWidth(1)
        if CheckMouseCollision(mouseX, mouseY, 5 * squareTileWidth, 5 * squareTileHeight, squareTileWidth * 2,
            squareTileHeight * 2) then
            knightShadow = math.min(knightShadow + 1, 10)
            love.mouse.setCursor((love.mouse.getSystemCursor("hand")))
            if love.mouse.isDown(1) then
                love.mouse.setCursor()
                Piece().Promote(bit.bor(Piece().Knight, col))
                knightShadow = 0
            end
        else
            knightShadow = math.max(knightShadow - 1, 0)
        end

    end
end

function Board:LoadStartPosition()
    Board:LoadPosition(startFen)
end

function Board:LoadPosition(fen)
    loadedPosition = PositionFromFen(fen)
    Game.Board.LightPieces = {}
    Game.Board.DarkPieces = {}
    local pec = Piece
    local isCLR = pec.IsColor
    local pTYPE = pec.PieceType
    for squareIndex = 1, 64 do
        piece = loadedPosition.squares[squareIndex]
        Game.Board.Square[squareIndex][1] = piece
        Game.Board.Square[squareIndex][2] = true
        Game.Board.Square[squareIndex][3] = false
        if piece ~= 0 then
            if isCLR(piece, pec.White) then
                table.insert(Game.Board.LightPieces, squareIndex)
                if pTYPE(piece) == pec.King then
                    Game.Board.KingSquare['w'] = squareIndex
                end
            else
                table.insert(Game.Board.DarkPieces, squareIndex)
                if pTYPE(piece) == pec.King then
                    Game.Board.KingSquare['b'] = squareIndex
                end
            end
        end
    end
    Game.turn = loadedPosition.turn
    Game.wkcstl = loadedPosition.whiteCastleKingside
    Game.wqcstl = loadedPosition.whiteCastleQueenside
    Game.bkcstl = loadedPosition.blackCastleKingside
    Game.bqcstl = loadedPosition.blackCastleQueenside
    Game.epFile = loadedPosition.epFile
end

function CheckMouseCollision(x, y, x2, y2, width, height)
    if x < x2 + width and x > x2 and y < y2 + height and y > y2 then
        return true
    end
    return false
end
