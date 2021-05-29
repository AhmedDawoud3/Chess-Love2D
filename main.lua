Class = require "utils/Class"
board = require "board"
piece = require "Piece"
loader = require 'loader'
require 'BoardRepresentation'
require 'FenUtility'
bit = require "bit"
WIDTH = 960
HEIGHT = 960
function love.load()
    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Chess")
    Loader = Loader()
    Board = Board()
    Board:LoadStartPosition()
end

function love.update(dt)
end

function love.draw()
    CreateGraphicalBoard()
    Board:DisplayPieces()
end

function love.keypressed(key)
    if key == 'escape' then
        love.window.close()
    end
end
