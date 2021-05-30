GameManager = Class {}

audio = {
    ["normal"] = love.audio.newSource('audio/normal.wav', "static"),
    ["capture"] = love.audio.newSource('audio/capture.wav', "static")
}

function GameManager:init()
    Loader = Loader()
    Board = Board()
    Board:LoadStartPosition()
    -- Board.Square[16] = {bit.bor(Piece().White, Piece().Knight), true}
    Player = Player()
end

function GameManager:Update(dt)
    Player:Update(dt)
end

function GameManager:Render()
    CreateGraphicalBoard()
    if lastMove then
        Board:DisplayLastMoves()
    end
    Board:DisplayLegalMoves()
    Board:DisplayPieces()
end