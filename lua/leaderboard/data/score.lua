--DO NOT SAVE DURING GAME

include("leaderboard/config/lb_config.lua")

local path = "leaderboard/data/datahandlers/" .. LB.DefaultDataHandler .. ".lua"

if not ( file.Exists(path, "LUA") ) then
	MsgN("Leaderboards data provider not found. " .. path)
end

DH = {}

include(path)

--Registar All network strings - Need to Go through these and make them more efficient
util.AddNetworkString("LB_SendNickname")

util.AddNetworkString("LB_ResetData")

util.AddNetworkString("LB_GetUserData")
util.AddNetworkString("LB_SendUserData")

util.AddNetworkString("LB_CopyBoard")
util.AddNetworkString("LB_SendBoard")

util.AddNetworkString("LB_ToggleMenu")

util.AddNetworkString("LB_GetTable")
util.AddNetworkString("LB_GetOldTable")
util.AddNetworkString("LB_SendTable")

util.AddNetworkString("LB_UpdatePlayerScore")
util.AddNetworkString("LB_RequestPlayerScore")
util.AddNetworkString("LB_SendPlayerScore")

util.AddNetworkString("LB_RequestPlayTime")
util.AddNetworkString("LB_SendPlayTime")

util.AddNetworkString("LB_RequestBanlist")
util.AddNetworkString("LB_SendBanlist")

--[[
	Todo:
		Reset Player Data - Not Done

		Copy Board
]]--

--Data section

isLoaded = false --Check to see if anything is loaded

local function forceSave()
	DH:SaveData()
end

function resetLoadData()
	isLoaded = false
end

function loadData(ply)
	if ( not isLoaded ) then
		DH:LoadData()
		updateData()
		isLoaded = true
	end
end

hook.Add("PlayerInitialSpawn", "LB_LoadData", loadData)

local function saveData()
	timer.Simple("2", function()
		
		if ( isLoaded ) then
			DH:SaveData()
		end
		
	end )
end

if ( LB.UseTimer ) then
	timer.Create( "SaveData", LB.TimerTime, 0, saveData)
else
	hook.Add("TTTEndRound", "LB_SaveData", saveData)
end

function updateData()
	local tableNick = DH:GetNicknames()
	local stringNick = util.TableToJSON(tableNick)
	local compressedNick = util.Compress(stringNick)

	net.Start("LB_SendNickname")
		net.WriteUInt(#compressedNick, 32)
		net.WriteData(compressedNick, #compressedNick)
	net.Broadcast()
end

hook.Add("TTTPrepareRound", "LB_UpdateData", updateData)

local function resetData()
	local boardname = net.ReadString()
	local temp = convertBit(net.ReadBit())

	DH:ResetData(boardname, temp)
end

net.Receive("LB_ResetData", resetData)

local function getBanList(len, client)
	local banlist = DH:GetBanList()

	net.Start("LB_SendBanlist")
		net.WriteTable(banlist)
	net.Send(client)
end

net.Receive("LB_RequestBanlist", getBanList)

--END Data section

--User Data section

local function resetPlayerData()
end

local function getUserData(len, client)
	local userData = {}
	local userid = net.ReadString()

	userData = DH:GetAllData(userid)

	udString = util.TableToJSON(userData)
	udCompressed = util.Compress(udString)

	net.Start("LB_SendUserData")
		net.WriteUInt(#udCompressed, 32)
		net.WriteData(udCompressed, #udCompressed)
	net.Send(client)

end

net.Receive("LB_GetUserData", getUserData)

--END User Data section

--Score section

function getOldBoard(boardname, tmp)
	return DH:GetTable(boardname, tmp, false)
end

net.Receive("LB_GetTable", function(len, client) 
	boardname = net.ReadString()
	tmp = convertBit(net.ReadBit())

	board = getOldBoard(boardname, tmp)

	if ( board == nil  ) then
		net.Start("LB_SendTable")
			net.WriteString("tableNil")
		net.Send(client)
		return
	end

	local boardString = util.TableToJSON(board)
	local boardCompressed = util.Compress(boardString)

	net.Start("LB_SendTable")
		net.WriteString("tableFine")
		net.WriteUInt(#boardCompressed, 32)
		net.WriteData(boardCompressed, #boardCompressed)
	net.Send(client)
end )

local function getScore(userid, boardname, tmp)
	return DH:GetScore(userid, boardname, tmp)
end

net.Receive("LB_RequestPlayerScore", function(len, client)
	userid = net.ReadString()
	boardname = net.ReadString()
	tmp = convertBit(net.ReadBit())

	net.Start("LB_SendPlayerScore")
		net.WriteInt(getScore(userid, boardname, tmp), 16)
	net.Send(client)
end )

local function setScore(userid, score, useScore, boardname, tmp)
	DH:SetScore(userid, score, useScore, boardname, tmp)
end

net.Receive("LB_UpdatePlayerScore", function(len, client)
	userid = net.ReadString()
	score = net.ReadString()
	boardname = net.ReadString()
	tmp = convertBit(net.ReadBit())

	setScore(userid, score, false, boardname, tmp)

end)

function incrementScore(userid, boardname, tmp)
	DH:SetScore(userid, 1, true, boardname, tmp)
end

--END Score section

--Time section
--This is a temp table only used to store start times.
playerStartTime = {}

function updatePlayerTime(userid, tmp)
	local time = getCurrentPlaytime(userid, tmp)
	local newTime = time + RealTime() - getStartTime(userid)

	DH:SetScore(userid, newTime, false, "TimePlayed", tmp)
end

function getCurrentPlaytime(userid, tmp)
	return DH:GetData(userid, "TimePlayed", tmp)
end

function startTime(userid, time)
	playerStartTime[userid] = time
end

local function getStartTime(userid)
	return playerStartTime[userid]
end

--END Time section

function convertBit(bitD)
	if ( bitD ==  1 ) then
		return "true"
	else
		return "false"
	end
end