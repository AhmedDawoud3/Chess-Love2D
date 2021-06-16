local eval = Evaluate
function Search(depth, alpha, beta, maximizingPlayer)
    if depth == 0 then
        return {eval(), nil}
    end

    -- if #moves_ == 0 then
    --     if IsCheck(Piece().Black) then
    --         return {-10000000000000, nil}
    --     end
    --     return {0, nil}
    -- end

    local moves_ = GetAllLegalMoves(maximizingPlayer and Piece().White or Piece().Black)
    local bestMove = moves_[math.random(1, #moves_)]

    if maximizingPlayer then
        local maxEval = -100000000000
        local moves_ = GetAllLegalMoves(Piece().White)
        for _, v in ipairs(moves_) do
            local originalFen = CurrentFEN()
            MakeComputerMove(v.StartSquare, v.TargetSquare)
            local eval = Search(depth - 1, alpha, beta, false)[1]
            if maxEval < eval then
                maxEval = eval
                bestMove = v
            end
            alpha = math.max(alpha, eval)
            if beta <= alpha then
                break
            end
            Game.Board:LoadPosition(originalFen)
        end
        return {maxEval, bestMove}
    else
        local minEval = 100000000000
        local moves_ = GetAllLegalMoves(Piece().Black)
        for _, v in ipairs(moves_) do
            local originalFen = CurrentFEN()
            MakeComputerMove(v.StartSquare, v.TargetSquare)
            local eval = Search(depth - 1, alpha, beta, true)[1]
            if minEval > eval then
                minEval = eval
                bestMove = v
            end
            beta = math.min(beta, eval)
            Game.Board:LoadPosition(originalFen)
        end
        return {minEval, bestMove}
    end

end

function table.add(this, other)
    for j = 1, #other do
        this[#this + 1] = other[j]
    end
    return this
end
