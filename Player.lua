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
    if love.mouse.isDown(1) and not Game.promotionAvalible then
        if TryGetSquareUnderMouse(mousePos) then
            moves = GenerateMoves(selectedPieceSquare)
            moves = FilterMoves(moves, Game.turn)
            -- moves = GetAllMoves('w' == Game.turn and Piece().White or Piece().Black)
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

function TryMakeMove(startSquare, targetSquare, DEPUG)
    Game.promotionAvalible = false
    if startSquare ~= targetSquare then
        for i, v in ipairs(moves) do
            if targetSquare == v.TargetSquare then
                if Piece().IsColor(Game.Board.Square[startSquare][1], Piece().Black) then
                    Game.plyCount = Game.plyCount + 1
                end
                if Board.Square[targetSquare][1] ~= 0 then
                    if not DEPUG then
                        audio["capture"]:stop()
                        audio["capture"]:play()
                    end
                    Game.fiftyCounter = -1
                else
                    if not DEPUG then
                        audio["normal"]:stop()
                        audio["normal"]:play()
                    end
                end

                -- Handling En Passant
                if Piece().PieceType(Board.Square[startSquare][1]) == Piece().Pawn and
                    (RankIndex(targetSquare) - RankIndex(startSquare) == 2 or RankIndex(targetSquare) -
                        RankIndex(startSquare) == -2) then
                    Game.epFile = FileIndex(targetSquare) + 1
                else
                    Game.epFile = 0
                end
                if Piece().PieceType(Board.Square[startSquare][1]) == Piece().Pawn then
                    Game.fiftyCounter = 0
                    local index = (Game.turn == 'w' and 1) or -1
                    if Board.Square[targetSquare][1] == 0 and FileIndex(targetSquare) ~= FileIndex(startSquare) then
                        Board.Square[targetSquare - 8 * index] = {0, false, false}
                        if not DEPUG then
                            audio["enPassant"]:stop()
                            audio["enPassant"]:play()
                        end
                    end

                end
                if Piece().PieceType(Board.Square[startSquare][1]) == Piece().King then
                    -- Set Castling to false
                    if Piece().IsColor(Board.Square[startSquare][1], Piece().White) then
                        Game.wqcstl = false
                        Game.wkcstl = false
                    end
                    if Piece().IsColor(Board.Square[startSquare][1], Piece().Black) then
                        Game.bqcstl = false
                        Game.bkcstl = false
                    end

                    -- Left Castling
                    if (startSquare - targetSquare) > 1 then
                        if Piece.PieceType(Board.Square[startSquare - 4][1]) == Piece().Rook and
                            not Board.Square[startSquare - 4][3] and not Board.Square[startSquare][3] then
                            if RankIndex(targetSquare) == 0 or RankIndex(targetSquare) == 7 then
                                Board.Square[startSquare - 1] = Board.Square[startSquare - 4]
                                Board.Square[startSquare - 4] = {0, false, false}
                            end
                        end
                    end

                    -- Right Castling
                    if (targetSquare - startSquare) > 1 then
                        if Piece.PieceType(Board.Square[startSquare + 3][1]) == Piece().Rook and
                            not Board.Square[startSquare + 3][3] and not Board.Square[startSquare][3] then
                            if RankIndex(targetSquare) == 0 or RankIndex(targetSquare) == 7 then
                                Board.Square[startSquare + 1] = Board.Square[startSquare + 3]
                                Board.Square[startSquare + 3] = {0, false, false}
                            end
                        end
                    end
                end

                Board.Square[targetSquare] = Board.Square[startSquare]
                Board.Square[targetSquare][2] = true
                Board.Square[startSquare] = {0, false, false}
                Board.Square[targetSquare][3] = true
                if not DEPUG then
                    table.insert(oldMoves, Move(startSquare, targetSquare))
                    table.insert(moveHistory, CurrentFEN(Game.Board))
                end
                Game:NextTurn()
                Game.fiftyCounter = Game.fiftyCounter + 1

                if not DEPUG then
                    if RankIndex(targetSquare) == 0 or RankIndex(targetSquare) == 7 then
                        if Piece().PieceType(Board.Square[targetSquare][1]) == Piece().Pawn then
                            Game.promotionAvalible = true
                            Game.promotionColor = ((Piece().IsColor(Board.Square[targetSquare][1], Piece().White) )and Piece().Black) or Piece().White
                            Game.promotionSquare = targetSquare
                        end
                    end
                end
            end
        end

        if Board.Square[targetSquare] ~= Board.Square[startSquare] then
            Board.Square[startSquare][2] = true
        end

        if not DEPUG then
            moves = {}
            floatingPiece = nil
            currentState = "None"
        end
        return true
    else
        Board.Square[targetSquare][2] = true
        if not DEPUG then
            moves = {}
            floatingPiece = nil
            currentState = "None"
        end
        return false
    end
    if not DEPUG then
        moves = {}
        floatingPiece = nil
        currentState = "None"
    end
end
