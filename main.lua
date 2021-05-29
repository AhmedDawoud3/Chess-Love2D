Class = require "utils/Class"
board = require "board"
piece = require "Piece"
loader = require 'loader'
require "gameManager"
require 'BoardRepresentation'
require 'FenUtility'
bit = require "bit"
WIDTH = 960
HEIGHT = 960
function love.load()
    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Chess")
    GameManager = GameManager()
end

function love.update(dt)
end

function love.draw()
    GameManager:Render()
end

function love.keypressed(key)
    if key == 'escape' then
        love.window.close()
    end
end
