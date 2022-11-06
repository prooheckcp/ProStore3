local function CompareTables(table1, table2)
    local equal : boolean = true

    for key1, value1 in pairs(table1) do
        if typeof(value1) == "table" then
            equal = CompareTables(value1, table2[key1])
            if not equal then
                break
            end
        elseif value1 ~= table2[key1] then
            equal = false
            break
        end
    end

    return equal
end

return CompareTables