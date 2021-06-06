local pawnValue = 100
local knightValue = 300
local bishopValue = 320
local rookValue = 500
local queenValue = 900
local endgameMaterialStart = rookValue * 2 + bishopValue + knightValue;

function Evaluate()
    whiteEval = 0
    blackEval = 0

    whiteMaterial = CountMaterial(Piece().White)[1]
    blackMaterial = CountMaterial(Piece().Black)[1]

    -- whiteMaterialWithoutPawns = whiteMaterial - CountMaterial(Piece().White)[2]
    -- blackMaterialWithoutPawns = blackMaterial - CountMaterial(Piece().Black)[2]

    -- whiteEndgamePhaseWeight = EndgamePhaseWeight(whiteMaterialWithoutPawns)
    -- blackEndgamePhaseWeight = EndgamePhaseWeight(blackMaterialWithoutPawns)

    whiteEval = whiteEval + whiteMaterial
    blackEval = blackEval + blackMaterial

    eval = whiteEval - blackEval

    perspective = Game.turn == 'w' and 1 or -1

    return eval  / 100
end

function EndgamePhaseWeight(materialCountWithoutPawns)
    multiplier = 1 / endgameMaterialStart
    return 1 - math.min(1, materialCountWithoutPawns * multiplier)
end

-- function MopUpEval(friendlyIndex, opponentIndex, myMaterial, opponentMaterial, endgameWeight)
--     mopUpScore = 0
--     if myMaterial > opponentMaterial + pawnValue * 2 and endgameWeight > 0 then
--         friendlyKingSquare = Game.Board.kingSquare[friendlyIndex]
--         opponentKingSquare = Game.Board.kingSquare[opponentIndex]
--         mopUpScore = mopUpScore + 
--     end
-- end

function CountMaterial(col)
    local material = 0
    local pawnMaterial = 0
    local pec = Piece()
    local pType = pec.PieceType
    local gmBoard = Game.Board.Square
    local isCLR = Piece().IsColor
    for i, v in ipairs(Game.Board.Square) do
        if isCLR(v[1], col) then
            if pType(v[1]) == pec.Pawn then
                material = material + pawnValue
                pawnMaterial = pawnMaterial + pawnValue
            elseif pType(v[1]) == pec.Knight then
                material = material + knightValue
            elseif pType(v[1]) == pec.Bishop then
                material = material + bishopValue
            elseif pType(v[1]) == pec.Rook then
                material = material + rookValue
            elseif pType(v[1]) == pec.Queen then
                material = material + queenValue
            end
        end
    end
    -- print("material " .. material)
    return {material, pawnValue}
end
