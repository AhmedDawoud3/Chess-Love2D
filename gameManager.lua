GameManager = Class {}
function GameManager:init()
    Loader = Loader()
    Board = Board()
    Board:LoadStartPosition()
end

function GameManager:Render()
    CreateGraphicalBoard()
    Board:DisplayPieces()
end