function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function idump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in ipairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function getTableSize(table)
    if(type(table) ~= 'table') then
        return 0
    end

    local count = 0

    for _ in pairs(table) do count = count + 1 end

    return count
end