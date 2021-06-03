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
require 'PlayerContrals'
bit = require "bit"
WIDTH = 1280
HEIGHT = 960
function love.load()
    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Chess 1.0")
    imageData = love.image.newImageData('Icons/512px.png')
    success = love.window.setIcon(imageData);
    GameManager = GameManager()
end

function love.update(dt)
    GameManager:Update(dt)
end

function love.draw()
    GameManager:Render()
end
