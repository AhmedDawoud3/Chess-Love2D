function Search(depth)
    if depth == 0 then
        return {Evaluate(), nil}
    end
    local moves_ = GetAllLegalMoves(Piece().Black)

    -- if #moves_ == 0 then
    --     if IsCheck(Piece().Black) then
    --         return {-10000000000000, nil}
    --     end
    --     return {0, nil}
    -- end

    bestEvaluation = 100000000000

    local originalFen = CurrentFEN()
    for _, v in ipairs(moves_) do
        MakeComputerMove(v.StartSquare, v.TargetSquare)
        evaluation = Evaluate()
        if IsCheck(Piece().White) then
            evaluation = evaluation - 2
        end
        if IsCheck(Piece().Black) then
            evaluation = 1000
        end
        print(evaluation)
        if evaluation < bestEvaluation then
            bestMove = v
            bestEvaluation = evaluation
        end
        Game.Board:LoadPosition(originalFen)
    end

    return {bestEvaluation, bestMove}
end
