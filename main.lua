Class = require "utils/Class"
require "board"
require "Piece"
require 'loader'
require "gameManager"
require 'BoardRepresentation'
require 'Player'
require 'FenUtility'
require 'BoardUI'
require 'LegalMoves'
require 'Move'
bit = require "bit"
WIDTH = 960
HEIGHT = 960
function love.load()
    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Chess")
    GameManager = GameManager()
end

function love.update(dt)
    GameManager:Update(dt)
end

function love.draw()
    GameManager:Render()
end

function love.keypressed(key)
    if key == 'escape' then
        love.window.close()
    elseif key == 'z' then
        UndoMove()
    end
end
