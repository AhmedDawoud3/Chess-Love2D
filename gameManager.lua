GameManager = Class {}
function GameManager:init()
    Loader = Loader()
    Board = Board()
    Board:LoadStartPosition()
    Player = Player()
end

function GameManager:Update(dt)
    Player:Update(dt)
end

function GameManager:Render()
    CreateGraphicalBoard()
    Board:DisplayPieces()
end