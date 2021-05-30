GameManager = Class {}

audio = {
    ["normal"] = love.audio.newSource('audio/normal.wav', "static"),
    ["capture"] = love.audio.newSource('audio/capture.wav', "static"),
    ["enPassant"] = love.audio.newSource('audio/enPassant.wav', "static")
}

function GameManager:init()
    Loader = Loader()
    Board = Board()
    Game = Game(Board)
    Game.Board:LoadStartPosition()
    -- Board.Square[16] = {bit.bor(Piece().White, Piece().Knight), true}
    Player = Player()
end

function GameManager:Update(dt)
    Player:Update(dt)
end

function GameManager:Render()
    CreateGraphicalBoard()
    if #oldMoves > 0 then
        Board:DisplayLastMoves()
    end
    Game.Board:DisplayLegalMoves()
    Game.Board:DisplayPieces()
end

Game = Class {}

function Game:init(board, turn, wlcstl, wrcstl, blcstl, brcstl, epFile)
    self.Board = board
    self.turn = turn
    self.wkcstl = wlcstl
    self.wqcstl = wrcstl
    self.bkcstl = blcstl
    self.bqcstl = brcstl
    self.epFile = epFile
    self.moves = 0
end

function Game:NextTurn()
    if self.turn == 'w' then
        self.turn = 'b'
    else
        self.turn = 'w'
    end
end
