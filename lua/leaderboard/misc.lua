function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
        return keys[i], t[keys[i]]
        end
    end
end

function contains(t, value)
    if ( t == nil ) then return false end

    for k, v in pairs(t) do
        if ( k == value or v ==  value ) then
            return true
        end
    end

    return false
end

function MakeCirclePoly(originX,originY,radius,thick,startAng,distAng,iter)
    startAng = math.rad(startAng)
    distAng = math.rad(distAng)
    if (not iter) or iter <= 1 then
        iter = 8
    else
        iter = math.Round(iter)
    end
    
    local stepAng = math.abs(distAng)/iter
    
    if thick then //The circle is hollow (Outline)
        if distAng > 0 then
            for i = 0, iter-1 do
                local eradius = radius + thick
                local cur1 = stepAng*i+startAng
                local cur2 = cur1+stepAng
                local points = {
                    {
                        x=math.cos(cur2)*radius+originX,
                        y=-math.sin(cur2)*radius+originY,
                        u=0,
                        v=0,
                    },
                    {
                        x=math.cos(cur2)*eradius+originX,
                        y=-math.sin(cur2)*eradius+originY,
                        u=1,
                        v=0,
                    },
                    {
                        x=math.cos(cur1)*eradius+originX,
                        y=-math.sin(cur1)*eradius+originY,
                        u=1,
                        v=1,
                    },
                    {
                        x=math.cos(cur1)*radius+originX,
                        y=-math.sin(cur1)*radius+originY,
                        u=0,
                        v=1,
                    },
                }
                
                return points;
            end
        else
            for i = 0, iter-1 do
                local eradius = radius + thick
                local cur1 = stepAng*i+startAng
                local cur2 = cur1+stepAng
                local points = {
                    {
                        x=math.cos(cur1)*radius+originX,
                        y=math.sin(cur1)*radius+originY,
                        u=0,
                        v=0,
                    },
                    {
                        x=math.cos(cur1)*eradius+originX,
                        y=math.sin(cur1)*eradius+originY,
                        u=1,
                        v=0,
                    },
                    {
                        x=math.cos(cur2)*eradius+originX,
                        y=math.sin(cur2)*eradius+originY,
                        u=1,
                        v=1,
                    },
                    {
                        x=math.cos(cur2)*radius+originX,
                        y=math.sin(cur2)*radius+originY,
                        u=0,
                        v=1,
                    },
                }
                
                return points;
            end
        end
    else
        if distAng > 0 then
            local points = {}
            
            if math.abs(distAng) < 360 then
                points[1] = {
                    x = originX,
                    y = originY,
                    u = .5,
                    v = .5,
                }
                iter = iter + 1
            end
            
            for i = iter-1,0,-1 do
                local cur1 = stepAng*i+startAng
                local cur2 = cur1+stepAng
                table.insert(points,{
                    x=math.cos(cur1)*radius+originX,
                    y=-math.sin(cur1)*radius+originY,
                    u=(1+math.cos(cur1))/2,
                    v=(1+math.sin(-cur1))/2,
                })
            end
            
            return points;
        else
            local points = {}
            
            if math.abs(distAng) < 360 then
                points[1] = {
                    x = originX,
                    y = originY,
                    u = .5,
                    v = .5,
                }
                iter = iter + 1
            end
            
            for i = 0,iter-1 do
                local cur1 = stepAng*i+startAng
                local cur2 = cur1+stepAng
                table.insert(points,{
                    x=math.cos(cur1)*radius+originX,
                    y=math.sin(cur1)*radius+originY,
                    u=(1+math.cos(cur1))/2,
                    v=(1+math.sin(cur1))/2,
                })
            end
            
            return points;
        end
    end
end

function timeToStr( time )

    local s = time % 60
    time = math.floor( time / 60 )
    local m = time % 60
    time = math.floor( time / 60 )
    local h = time % 24
    time = math.floor( time / 24 )
    local d = time

    return string.format( "%02id %02ih %02im %02is", d, h, m, s )
end

--Hold nickname data
nickNames = {}

net.Receive("LB_SendNickname", function(le)
    local dataLength = net.ReadUInt(32)
    local tableDecompressed = util.Decompress(net.ReadData(dataLength))
    nickNames = util.JSONToTable(tableDecompressed)
end )

--Grabs there nickname based of steamid
function getNickname(steamid)
    if ( nickNames[steamid] ~= nil ) then
        return nickNames[steamid]
    else
        return steamid
    end
end


