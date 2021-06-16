local socket = require 'socket'

function ChooseComputerMoves()
    -- local allMoves = GetAllLegalMoves(((Game.turn == 'w') and Piece().White) or Piece().Black)
    -- if #allMoves > 0 then
    -- local RandomMove = math.random(1, #allMoves)
    local begin = os.clock()
    searchedMove = Search(1, -100000000000, 100000000000, false)[2]
    print("Search " ..string.format("Time: %.2f milliseconds\n", ((os.clock() - begin) * 1000)))
    if searchedMove then
        MakeComputerMove(searchedMove.StartSquare, searchedMove.TargetSquare)
    end
    -- end
end

function MoveGenerationTest(depth)
    if depth == 0 then
        return 1
    end
    moves = GetAllLegalMoves(((Game.turn == 'w') and Piece().White) or Piece().Black)
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
