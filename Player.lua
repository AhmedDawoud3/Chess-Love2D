Player = Class {}

function Player:init(board)
    self.board = board
    currentState = "None"
end

function Player:Update()
    HandleInput()
end

function HandleInput()
    mousePos = {love.mouse.getX(), love.mouse.getY()}
    if currentState == "None" then
        HandlePieceSelection(mousePos)
    elseif currentState == "DraggingPiece" then
        HandleDragMovement(mousePos)
        -- elseif 
    end
end

function HandlePieceSelection(mousePos)
    if love.mouse.isDown(1) then
        if TryGetSquareUnderMouse(mousePos) then
            GenerateMoves()
            currentState = "DraggingPiece"
        end
    end
end

function HandleDragMovement(mousePos)
    if Board.Square[selectedPieceSquare][1] ~= 0 then
        DragPiece(selectedPieceSquare, mousePos)
        if not love.mouse.isDown(1) then
            HandlePiecePlacement(mousePos)
        end
    else
        currentState = "None"
    end
end

function HandlePiecePlacement(mousePos)
    targetSquare = GetPieceSquare(mousePos)
    targetIndex = IndexFromCoord(FileIndex(targetSquare), RankIndex(targetSquare))
    TryMakeMove(selectedPieceSquare, targetSquare)
end

function TryMakeMove(startSquare, targetSquare)
    if startSquare ~= targetSquare then
        for i, v in ipairs(moves) do
            if targetSquare == v.TargetSquare then
                if Board.Square[targetSquare][1] ~= 0 then
                    audio["capture"]:stop()
                    audio["capture"]:play()
                else
                    audio["normal"]:stop()
                    audio["normal"]:play()
                end

                -- Left Castling
                if Piece().PieceType(Board.Square[startSquare][1]) == Piece().King then
                    if (startSquare - targetSquare) > 1 then
                        if Piece.PieceType(Board.Square[startSquare - 4][1]) == Piece().Rook and
                            not Board.Square[startSquare - 4][3] and not Board.Square[startSquare][3] then
                            Board.Square[startSquare - 1] = Board.Square[startSquare - 4]
                            Board.Square[startSquare - 4] = {0, false, false}
                        end
                    end
                end

                -- Right Castling
                if Piece().PieceType(Board.Square[startSquare][1]) == Piece().King then
                    if (targetSquare - startSquare) > 1 then
                        if Piece.PieceType(Board.Square[startSquare + 3][1]) == Piece().Rook and
                            not Board.Square[startSquare + 3][3] and not Board.Square[startSquare][3] then
                            Board.Square[startSquare + 1] = Board.Square[startSquare + 3]
                            Board.Square[startSquare + 3] = {0, false, false}
                        end
                    end
                end

                Board.Square[targetSquare] = Board.Square[startSquare]
                Board.Square[targetSquare][2] = true
                Board.Square[startSquare] = {0, false, false}
                Board.Square[targetSquare][3] = true
                lastMove = Move(startSquare, targetSquare)
            end
        end
        if Board.Square[targetSquare] ~= Board.Square[startSquare] then
            Board.Square[startSquare][2] = true
        end
    else
        Board.Square[targetSquare][2] = true
    end
    moves = {}
    floatingPiece = nil
    currentState = "None"
end
