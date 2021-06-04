function ChooseComputerMoves()
    local allMoves = GetAllLegalMoves(((Game.turn == 'w') and Piece().White) or Piece().Black)
    if #allMoves > 0 then
        local RandomMove = math.random(1, #allMoves)
        MakeComputerMove(allMoves[RandomMove].StartSquare, allMoves[RandomMove].TargetSquare)
    end
end
