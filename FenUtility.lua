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

function CurrentFEN(Board)
    local fen = ''
    for rank = 7, 0, -1 do
        numEmptyFiles = 0
        for file = 0, 7 do
            local i = rank * 8 + file + 1
            local piece = Game.Board.Square[i][1]
            if piece ~= 0 then
                if numEmptyFiles ~= 0 then
                    fen = fen .. tostring(numEmptyFiles)
                    numEmptyFiles = 0
                end
                isBlack = Piece().IsColor(piece, Piece().Black)
                pieceType = Piece().PieceType(piece)
                pieceChar = " "
                if pieceType == Piece().Rook then
                    pieceChar = 'R'
                elseif pieceType == Piece().Knight then
                    pieceChar = 'N'
                elseif pieceType == Piece().Bishop then
                    pieceChar = 'B'
                elseif pieceType == Piece().Queen then
                    pieceChar = 'Q'
                elseif pieceType == Piece().King then
                    pieceChar = 'K'
                elseif pieceType == Piece().Pawn then
                    pieceChar = 'P'
                end
                fen = fen .. ((isBlack and string.lower(pieceChar)) or pieceChar)
            else
                numEmptyFiles = numEmptyFiles + 1
            end
        end
        if numEmptyFiles ~= 0 then
            fen = fen .. tostring(numEmptyFiles)
        end
        if rank ~= 0 then
            fen = fen .. '/'
        end
    end
    fen = fen .. ' '
    fen = fen .. ((Game.turn == 'w' and 'w') or 'b')

    -- Castling
    whiteKingSide = Game.wkcstl
    whiteQueenSide = Game.wqcstl
    blackKingSide = Game.bkcstl
    blackQueenSide = Game.bqcstl
    fen = fen .. ' '
    if whiteKingSide then
        fen = fen .. 'K'
    end
    if whiteQueenSide then
        fen = fen .. 'Q'
    end
    if blackKingSide then
        fen = fen .. 'k'
    end
    if blackQueenSide then
        fen = fen .. 'q'
    end
    if whiteKingSide or whiteQueenSide or blackKingSide or blackQueenSide then
    else
        fen = fen .. "-"
    end

    -- En-Passant
    fen = fen .. " "
    epFile = Game.epFile
    if epFile then
        if epFile == 0 then
            fen = fen .. '-'
        else
            fileName = fileNames:sub(epFile, epFile)
            epRank = (Game.turn == 'w') and 6 or 3
            fen = fen .. fileName .. tostring(epRank)
        end
    else
        fen = fen .. '-'
    end
    --  50 Move Counter
    fen = fen .. " "
    fen = fen .. tostring(Game.fiftyCounter)

    -- Play Counter
    fen = fen .. " "
    fen = fen .. tostring(math.floor(Game.plyCount / 2) + 1)
    return fen
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

function CheckFEN(fen)
    -- 81/5k1p/1p1pRp2/p2P4/P1P3Pp/1P4bP/6K1/8 w - -
    local sections = Split(fen, ' ')
    if #sections < 2 then
        return false
    end
    for i = 1, #sections[1] do
        local symbol = sections[1]:sub(i, i)
        if tonumber(symbol) ~= nil then
            if tonumber(symbol) > 8 then
            end
        else
            if symbol ~= '/' and symbol ~= 'k' and symbol ~= 'K' and symbol ~= 'b' and symbol ~= 'B' and symbol ~= 'p' and
                symbol ~= 'P' and symbol ~= 'r' and symbol ~= 'R' and symbol ~= 'q' and symbol ~= 'Q' and symbol ~= 'n' and
                symbol ~= 'N' then
                return false
            end
        end
    end
    return true
end
