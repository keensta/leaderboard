--Nickname Start
util.AddNetworkString("LB_SendNickname")

local nickNames = {}
local nickLoaded = false

function SaveNicknames(nicknames)
	if ( isEmpty(nicknames) == true or nickLoaded == false ) then 
		nickNames = LoadNicknames()
		nickLoaded = true
		return 
	end

	local tableString = util.TableToJSON(nicknames)
	file.Write("leaderboardData/nicknames.txt", tableString)
end

function LoadNicknames()
	if ( file.Exists("leaderboardData/nicknames.txt", "DATA") == true ) then
		nickname = util.JSONToTable(file.Read("leaderboardData/nicknames.txt"))
		return nickname
	else
		nickname = {}

		return nickname
	end
end

function GetNicknames()
	return nickNames
end

local function grabNickname(ply)
	if ( nickLoaded == false ) then
		nickNames = LoadNicknames()
		nickLoaded = true
		
		local tableNick = GetNicknames()
		local nickString = util.TableToJSON(tableNick)
		local nickCompressed = util.Compress(nickString)
		net.Start("LB_SendNickname")
			net.WriteUInt(#nickCompressed, 32)
			net.WriteData(nickCompressed, #nickCompressed)
		net.Broadcast()
	end

	nickNames[ply:SteamID()] = ply:Nick()

	local tableNick = GetNicknames()
	local nickString = util.TableToJSON(tableNick)
	local nickCompressed = util.Compress(nickString)
	net.Start("LB_SendNickname")
		net.WriteUInt(#nickCompressed, 32)
		net.WriteData(nickCompressed, #nickCompressed)
	net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "GrabNickname", grabNickname)

--Get's steam id of user if they exist in nickname table
function getSteamId(user)
	local steamid = "STEAM:0:20323023"

	for k,v in pairs(nickNames) do
		if ( v == user ) then
			return k
		end
	end

	return steamid
end

--Get's there nickname from the nickNames table using there steamid
function getNickname(steamid)
	if ( nickNames ~= nil ) then
		if ( nickNames[steamid] ~= nil ) then
			return nickNames[steamid]
		end
	end

	return "John Doe"
end

local function changeIds(tableList)
	local names = {}

	for k,v in pairs(tableList) do
		if ( nickNames[k] ~= nil ) then
			names[nickNames[k]] = v
		end
	end

	return names
end

--Nickname End

--Ban's Start
util.AddNetworkString("LB_RequestBanlist")
util.AddNetworkString("LB_SendBanlist")
util.AddNetworkString("LB_AddBan")
util.AddNetworkString("LB_RemoveBan")

local banlist = {}
local bansLoaded = false

function SaveBanlist()
	if ( bansLoaded == false ) then return end

	local tableString = util.TableToJSON(banlist)
	file.Write("leaderboardData/banlist.txt", tableString)
end

function LoadBanlist()
	if ( file.Exists("leaderboardData/banlist.txt", "DATA") == true ) then
		banList = util.JSONToTable(file.Read("leaderboardData/banlist.txt"))
		return banList
	else
		banList = {}
		return banList
	end
end

function IsBanned(steamid)
	return doesContain(steamdid, banlist)
end

--Bans net Start

net.Receive("LB_RequestBanlist", function(le, client)
	if ( bansLoaded == false ) then
		banlist = LoadBanlist()
		bansLoaded = true
	end

	if ( banlist ~= nil ) then
		net.Start("LB_SendBanlist")
			net.WriteTable(changeIds(banlist))
		net.Send(client)
	end

end )

net.Receive("LB_AddBan", function(le, client)
	local userToAdd = net.ReadString()
	local reason = net.ReadString()

	banlist[userToAdd] = reason

	SaveBanlist()
end )

net.Receive("LB_RemoveBan", function(le, client)
	local userToRemove = net.ReadString()
	local userPos = net.ReadInt(32)
	local steamId = getSteamId(userToRemove)

	for k, v in pairs(banlist) do
		if ( k == steamId ) then
			banlist[k] = nil
		end
	end

	SaveBanlist()
end )
--Bans net End
--Ban's End

--Leaderboard Start

function SaveLeaderboard(sb)
	if ( isEmpty(sb) == true ) then return end

	local tableString = util.TableToJSON(sb)
	file.Write("leaderboardData/leaderboard.txt", tableString)
end

function ReadLeaderboard()
	if ( file.Exists("leaderboardData/leaderboard.txt", "DATA") == true ) then
		local scoreboard = util.JSONToTable(file.Read("leaderboardData/leaderboard.txt"))

		return scoreboard
	else 
		local sb = {}

		return sb
	end
end

--Leaderboard End

--Misc Methods Start

function isEmpty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end

function doesContain(element, self)
	for k, v in pairs(self) do
		if ( k == element ) then
			return true
		end
	end
	return false
end

--Misc Methods End