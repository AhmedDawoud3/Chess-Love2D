lightCol = {241 / 255, 217 / 255, 192 / 255, 1}
darkCol = {169 / 255, 122 / 255, 101 / 255, 1}
WIDTH = 960
HEIGHT = 960
squareTileWidth = WIDTH / 8
squareTileHeight = HEIGHT / 8

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
    -- love.graphics.print(IndexFromCoord(pos[1], pos[2]), pos[1] * squareTileWidth, pos[2] * squareTileHeight)
end
Board = Class {}
function Board:init()
    self.Square = {}
    for i = 1, 64 do
        self.Square[i] = {0, false, true}
    end
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
            -- print(FileIndex(v.TargetSquare), RankIndex(v.TargetSquare))
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
end

function Board:LoadStartPosition()
    Board:LoadPosition(startFen)
end

function Board:LoadPosition(fen)
    loadedPosition = PositionFromFen(fen)

    for squareIndex = 1, 64 do
        piece = loadedPosition.squares[squareIndex]
        Game.Board.Square[squareIndex][1] = piece
        Game.Board.Square[squareIndex][2] = true
        Game.Board.Square[squareIndex][3] = false
    end
    Game.turn = loadedPosition.turn
    Game.wkcstl = loadedPosition.whiteCastleKingside
    Game.wqcstl = loadedPosition.whiteCastleQueenside
    Game.bkcstl = loadedPosition.blackCastleKingside
    Game.bqcstl = loadedPosition.blackCastleQueenside
    Game.epFile = loadedPosition.epFile
end
