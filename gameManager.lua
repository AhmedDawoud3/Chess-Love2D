GameManager = Class {}
time = 0

audio = {
    ["normal"] = love.audio.newSource('audio/normal.wav', "static"),
    ["capture"] = love.audio.newSource('audio/capture.wav', "static"),
    ["enPassant"] = love.audio.newSource('audio/enPassant.wav', "static")
}
Fonts = {
    ["main"] = love.graphics.newFont('Fonts/font0.ttf', 35),
    ["Big"] = love.graphics.newFont('Fonts/font0.ttf', 100),
    ["small"] = love.graphics.newFont('Fonts/font0.ttf', 20),
    ["smallest"] = love.graphics.newFont('Fonts/font0.ttf', 15),
    ["Secondary"] = love.graphics.newFont('Fonts/font1.ttf', 60),
    ["SecondarySmall"] = love.graphics.newFont('Fonts/font1.ttf', 35)
}
function GameManager:init()
    Loader = Loader()
    Board = Board()
    Game = Game(Board)
    Game.Board:LoadStartPosition()
    -- Board.Square[16] = {bit.bor(Piece().White, Piece().Knight), true}
    Player = Player()
    -- for i = 1, 1 do
    --     local begin = os.clock()
    --     print("Depth: " .. i .. " ply  " .. "Results : " .. (MoveGenerationTest(i)) .. " Positions  " ..
    --               string.format("Time: %.2f milliseconds\n", ((os.clock() - begin) * 1000)))
    -- end
    -- 1 20 0
    -- 2 400 0
    -- 3 8902 0
    -- 4 197281 11
    -- 5 4865609 259
    -- 6 119060324 6502

end

function GameManager:Update(dt)
    time = time + dt
    Player:Update(dt)
    if Game.turn == 'b' and not Game.promotionAvalible then
        ChooseComputerMoves()
    end
    if selectedPieceSquare and currentState == 'DraggingPiece' then
        Game.Board.Square[selectedPieceSquare][2] = false
    end
    -- print("White Pieces = " .. #Game.Board.LightPieces, "Dark Pieces = " .. #Game.Board.DarkPieces)
end

function GameManager:Render()
    PlayerContrals:Render()
    CreateGraphicalBoard()
    if #oldMoves > 0 then
        Board:DisplayLastMoves()
    end
    Game.Board:DisplayLegalMoves()
    Game.Board:DisplayChecks()
    Game.Board:DisplayPieces()
    Game.Board:GetPiecePromotion()
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
    self.plyCount = 1
    self.fiftyCounter = 0
    self.promotionAvalible = false
    self.promotionColor = nil
    self.promotionSquare = nil
end

function Game:NextTurn()
    if Game.turn == 'w' then
        Game.turn = 'b'
    else
        Game.turn = 'w'
    end
end
