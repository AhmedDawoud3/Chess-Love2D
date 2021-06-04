Class = require "utils/class"
require "Board"
require "piece"
require 'loader'
require "gameManager"
require 'BoardRepresentation'
require 'Player'
require 'FenUtility'
require 'BoardUI'
require 'LegalMoves'
require 'Move'
require 'PlayerContrals'
require 'ComputerMoves'
bit = require "bit"
WIDTH = 1280
HEIGHT = 960
function love.load()
    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Chess 1.0")
    math.randomseed(os.clock())
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
