Class = require "utils/Class"
Board = require "Board"
WIDTH = 960
HEIGHT = 960

function love.load()
    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Chess")
end

function love.update(dt)

end

function love.draw()
    CreateGraphicalBoard()
end

function love.keypressed(key)
    if key == 'escape' then
        love.window.close()
    end
end
