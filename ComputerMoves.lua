local socket = require 'socket'

function ChooseComputerMoves()
    local allMoves = GetAllLegalMoves(((Game.turn == 'w') and Piece().White) or Piece().Black)
    if #allMoves > 0 then
        local RandomMove = math.random(1, #allMoves)
        MakeComputerMove(allMoves[RandomMove].StartSquare, allMoves[RandomMove].TargetSquare)
    end
end

function MoveGenerationTest(depth)
    if depth == 0 then
        return 1
    end
    moves = GetAllLegalMoves(((Game.turn == 'w') and Piece().White) or Piece().Black)
    numPositions = 0

    for _, move in ipairs(moves) do
        MakeComputerMove(move.StartSquare, move.TargetSquare)
        numPositions = numPositions + MoveGenerationTest(depth - 1)
        UndoMove()
    end
    return numPositions
end
