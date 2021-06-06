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
    local begin = os.clock()
    moves = GetAllLegalMoves(((Game.turn == 'w') and Piece().White) or Piece().Black)
    -- print("Legal Moves in " ..string.format("Time: %.2f milliseconds\n", ((os.clock() - begin) * 1000)))
    numPositions = 0
    local mkMove = MakeComputerMove
    local undoMV = UndoMove
    for _, move in ipairs(moves) do
        mkMove(move.StartSquare, move.TargetSquare)
        numPositions = numPositions + MoveGenerationTest(depth - 1)
        undoMV()
    end
    return numPositions
end
