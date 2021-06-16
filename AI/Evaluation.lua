local pawnValue = 100
local knightValue = 300
local bishopValue = 320
local rookValue = 500
local queenValue = 900
local endgameMaterialStart = rookValue * 2 + bishopValue + knightValue;
local pec = Piece
function Evaluate()
    whiteEval = 0
    blackEval = 0

    whiteMaterial = CountMaterial(pec.White)[1]
    blackMaterial = CountMaterial(pec.Black)[1]

    -- whiteMaterialWithoutPawns = whiteMaterial - CountMaterial(pec.White)[2]
    -- blackMaterialWithoutPawns = blackMaterial - CountMaterial(pec.Black)[2]

    -- whiteEndgamePhaseWeight = EndgamePhaseWeight(whiteMaterialWithoutPawns)
    -- blackEndgamePhaseWeight = EndgamePhaseWeight(blackMaterialWithoutPawns)

    whiteEval = whiteEval + whiteMaterial
    blackEval = blackEval + blackMaterial

    if IsCheck(pec.White) then
        whiteEval = whiteEval - 400
    end
    if IsCheck(pec.Black) then
        blackEval = blackEval - 400
    end

    eval = whiteEval - blackEval

    perspective = Game.turn == 'w' and 1 or -1

    return eval / 100
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
    local pec = pec
    local pType = pec.PieceType
    local gmBoard = Game.Board.Square
    local isCLR = pec.IsColor
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
            elseif pType(v[1]) == pec.King then
                material = material + 100000
            end
        end
    end
    -- print("material " .. material)
    return {material, pawnValue}
end
