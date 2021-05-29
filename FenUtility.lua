pieceTypeFromSymbol = {
    ['k'] = Piece().King,
    ['p'] = Piece().Pawn,
    ['n'] = Piece().Knight,
    ['b'] = Piece().Bishop,
    ['r'] = Piece().Rook,
    ['q'] = Piece().Queen
}

startFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

function PositionFromFen(fen)
    loadedPositionInfo = LoadedPositionInfo()
    local sections = Split(fen, ' ')
    local file = 0
    local rank = 7
    for i = 1, #sections[1] do
        local symbol = sections[1]:sub(i, i)
        if symbol == '/' then
            file = 0
            rank = rank - 1
        else
            if tonumber(symbol) ~= nil then
                file = file + tonumber(symbol)
            else
                pieceColour = ((string.upper(symbol) == symbol) and Piece().White) or Piece().Black
                pieceType = pieceTypeFromSymbol[string.lower(symbol)]
                loadedPositionInfo.squares[rank * 8 + file + 1] = bit.bor(pieceColour, pieceType)
                file = file + 1
            end
        end
    end
    return loadedPositionInfo
end
LoadedPositionInfo = Class {}

function LoadedPositionInfo:init()
    self.squares = {}
    self.whiteCastleKingside = nil
    self.whiteCastleQueenside = nil
    self.blackCastleKingside = nil
    self.blackCastleQueenside = nil
    self.epFile = nil
    self.whiteToMove = nil
    self.plyCount = nil

    for i = 1, 64 do
        self.squares[i] = 0
    end
end

function Split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result
end