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
    loadedPositionInfo.turn = sections[2]
    castlingRights = (#sections > 2 and sections[3]) or "KQkq"
    loadedPositionInfo.whiteCastleKingside = false
    loadedPositionInfo.whiteCastleQueenside = false
    loadedPositionInfo.blackCastleKingside = false
    loadedPositionInfo.blackCastleQueenside = false
    for i = 1, #castlingRights do
        local c = castlingRights:sub(i, i)
        if c == "K" then
            loadedPositionInfo.whiteCastleKingside = true
        elseif c == 'Q' then
            loadedPositionInfo.whiteCastleQueenside = true
        elseif c == 'k' then
            loadedPositionInfo.blackCastleKingside = true
        elseif c == 'q' then
            loadedPositionInfo.blackCastleQueenside = true
        end
    end
    if #sections > 3 then
        enPassantFileName = sections[4]:sub(1, 1)
        for i = 1, #fileNames do
            local c = fileNames:sub(i, i)
            if c == enPassantFileName then
                loadedPositionInfo.epFile = i
                break
            end
        end
    end

    if #sections > 4 then
        loadedPositionInfo.plyCount = tonumber(sections[5])
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
    self.turn = 0
    self.plyCount = 0

    for i = 1, 64 do
        self.squares[i] = 0
    end
end

function Split(s, delimiter)
    result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result
end
