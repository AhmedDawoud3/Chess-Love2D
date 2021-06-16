function CreateTable(size)
    local t = {}
    for i = 1, size do
        table.insert(t, 0)
    end
    return t
end
