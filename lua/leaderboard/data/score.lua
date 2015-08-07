--DO NOT SAVE DURING GAME ONLY FILE NOT ALLOWED TO BE SAVED

include( "leaderboard/data/DataHandler.lua" )

--Registar all network strings
util.AddNetworkString("LB_CopyBoard")
util.AddNetworkString("LB_ToggleMenu")
util.AddNetworkString("LB_SendBoard")
util.AddNetworkString("LB_GetTable")
util.AddNetworkString("LB_GetOldTable")
util.AddNetworkString("LB_SendTable")
util.AddNetworkString("LB_UpdatePlayerScore")
util.AddNetworkString("LB_RequestPlayerScore")
util.AddNetworkString("LB_SendPlayerScore")
util.AddNetworkString("LB_RequestPlayTime")
util.AddNetworkString("LB_SendPlayTime")
util.AddNetworkString("LB_GetRefName")
util.AddNetworkString("LB_SendRefName")
util.AddNetworkString("LB_GetUserData")
util.AddNetworkString("LB_SendUserData")
util.AddNetworkString("LB_ResetTmpBoard")
util.AddNetworkString("LB_ResetData")

--[[ TODO:
	- Move refName into config file
	- Comment code into some sort of readable state if thats even possible
]]
--[[ Adding new board:
	Todo
]]--

--This is the main data holder.
sb = sb or {}

--We have this so we can send players this data and not have it show live data
tmpSb = tmpSb or {}

--Check's to see if it's been loaded yet
isLoaded = false

function createBoard(tableN)
	sb[tableN] = { ["true"] = {}, ["false"] = {}, }
end

function forceSave()
	SaveLeaderboard(sb)
	SaveNicknames(GetNicknames())
	MsgN( "SAVED DATA" )
end

--Event/Hook Start
local function loadLeaderboard(ply)
	if ( isLoaded == false ) then
		sb = ReadLeaderboard()
		tmpSb = table.Copy(sb)
		isLoaded = true
	end
end


hook.Add("PlayerInitialSpawn", "LoadScoreboard", loadLeaderboard)

local function openBoard(ply)
	net.Start("LB_ToggleMenu")
	net.Send(ply)
end

concommand.Add("openLeaderboard", openBoard)
--hook.Add("ShowSpare2", "LB_ShowBoard", openBoard)


local function saveBoards()
	local tableNick = GetNicknames()
	local nickString = util.TableToJSON(tableNick)
	local nickCompressed = util.Compress(nickString)
	
	net.Start("LB_SendNickname")
		net.WriteUInt(#nickCompressed, 32)
		net.WriteData(nickCompressed, #nickCompressed)
	net.Broadcast()

	if ( isLoaded == true ) then
		SaveNicknames(tableNick)
	end
end

hook.Add("TTTPrepareRound", "LB_SaveBoard", saveBoards)

local function updateBoards(result)
	timer.Simple("2", function()
		tmpSb = table.Copy(sb)

		if ( isLoaded == true ) then
			SaveLeaderboard(sb)
		end
	end )
end

hook.Add("TTTEndRound", "LB_UpdateBoard", updateBoards)


--Event/Hook End

--Net Area Start

net.Receive("LB_CopyBoard", function(len, client)
	local boardToCopy = net.ReadString()
	local boardToCopyTmp = convertBit(net.ReadBit())
	local boardToGetData = net.ReadString()
	local boardToGetDataTmp = convertBit(net.ReadBit())
	local shouldDelete = convertBit(net.ReadBit())

	if ( sb[boardToCopy] ~= nil or sb[boardToCopy][boardToCopyTmp] ~= nil ) then
		
		if ( sb[boardToGetData] == nil ) then
			createBoard(boardToGetData)
		end
		
		sb[boardToGetData][boardToGetDataTmp] = sb[boardToCopy][boardToCopyTmp]
		if ( shouldDelete == "true" ) then
			sb[boardToCopy][boardToCopyTmp] = {}
		end 
	end
end )

function getTable(tableName, tmp)

	if ( sb == nil ) then
		return nil
	end

	if ( sb[tableName] ~= nil and sb[tableName][tmp] ~= nil ) then
	 	return sb[tableName][tmp]
	end

 	return nil

end

--Gets the none live version of the table. So people can't use it to work out traitors
function getOldTable(tableName, tmp)

	if ( tmpSb == nil ) then
		return nil
	end

	if ( tmpSb[tableName] ~= nil and tmpSb[tableName][tmp] ~= nil ) then
	 	return tmpSb[tableName][tmp]
	end

 	return nil

end

net.Receive("LB_GetTable", function(len, client)
	tableName = net.ReadString()
	tmp = convertBit(net.ReadBit())
	tableScore = getOldTable(tableName, tmp)

	if ( tableScore == nil ) then
		net.Start("LB_SendTable")
			net.WriteString("tableNil")
		net.Send(client)
		return
	end

	local tableScore = tableScore
	local scoreString = util.TableToJSON(tableScore)
	local scoreCompressed = util.Compress(scoreString)
	
	net.Start("LB_SendTable")
		net.WriteString("tableFine")
		net.WriteUInt(#scoreCompressed, 32)
		net.WriteData(scoreCompressed, #scoreCompressed)
	net.Send(client)

end )


--Get's the players current score for selected table and if it's a monthly table
function getScore(t, userId, selectedTable, tmp)
	local t = t or getTable(selectedTable, tmp)

	if ( t[userId] ~= nil ) then
		return t[userId]
	else
		return 0
	end
end

net.Receive("LB_RequestPlayerScore", function(len, client) 
		userId = net.ReadString()
		selectedTable = net.ReadString()
		tmp = convertBit(net.ReadBit())

		net.Start("LB_SendPlayerScore")
			net.WriteInt(getScore(userId, selectedTable, tmp), 32)
		net.Send(client)
end )


--This will SET the players score to the supplied score not there current score plus new one.
function updateScore(userId, score, selectedTable, tmp, useCurrentScore)
	local t = getTable(selectedTable, tmp)

	if ( t == nil ) then
		createBoard(selectedTable)
		updateScore(userId, score, selectedTable, tmp, useCurrentScore)
	end
	
	if ( useCurrentScore ) then
		if ( t ~= nil ) then
			if ( t[userId] ~= nil ) then
				score = score + tonumber(t[userId])
				t[userId] = tonumber(score)
			else
				t[userId] = tonumber(score)
			end
		end
	else
		if ( t ~= nil ) then
			t[userId] = tonumber(score)
		end
	end
end

net.Receive("LB_UpdatePlayerScore", function(len, client) 
	userId = net.ReadString()
	score = net.ReadString()
	selectedTable = net.ReadString()
	tmp = convertBit(net.ReadBit())

	updateScore(userId, score, selectedTable, tmp, false)
end )


--This will increment the players score by 1
function incrementScore(userId, selectedTable, tmp)
	local t = getTable(selectedTable, tmp)

	if ( t == nil ) then
		createBoard(selectedTable)
		incrementScore(userId, selectedTable, tmp)
	end

	if ( t ~= nil ) then
		if ( t[userId] ~= nil ) then
			t[userId] = getScore(t, userId, selectedTable, tmp) + 1
		else
			t[userId] = 1
		end
	end
end


--Set's the players total time into the leaderboard
function updatePlayerTime(userId, startTime, tmp)
	local t = getTable("TimePlayed", tmp)

	if ( t == nil ) then
		createBoard("TimePlayed")
		updatePlayerTime(userId, startTime, tmp)
	end
		
	if ( t ~= nil ) then 
		local totalTime = getTotalTime(t, userId, startTime, tmp)
		t[userId] = totalTime
	end
end


--Works out the players current total time playing on the server and returns it
function getTotalTime(t, userId, startTime, tmp)
	local totalTime = 0

	if ( t[userId] ~= nil ) then
		totalTime = t[userId] 
	end

	return totalTime + CurTime() - startTime
end

net.Receive("LB_RequestPlayTime", function(len, client)
	userid = net.ReadString()
	tmp = convertBit(net.ReadBit())
	startTime = getStartTime(userid)

	net.Start("LB_SendPlayTime")
		net.WriteInt(math.floor(getTotalTime(userid, startTime, tmp)), 64)
	net.Send(client)
end )

--Grabs All data for ONE player
local function getUserData(userId)
	local userData = {}

	for board, _ in pairs(sb) do
		userData[board] = sb[board]["false"][userId] or 0
		userData[board .. " - M"] = sb[board]["true"][userId] or 0
	end

	return userData
end

net.Receive("LB_GetUserData", function(len, client)
	userid = net.ReadString()

	net.Start("LB_SendUserData")
		net.WriteTable(getUserData(userid))
	net.Send(client)
end)

--Resets the "Monthly" data only (ToDo: Make automatic)
local function resetTempBoard()
	for board, _ in pairs(sb) do
		sb[board]["true"] = {}
	end

	SaveLeaderboard(sb)
end

net.Receive("LB_ResetTmpBoard", resetTempBoard)


--Resets all the data in the leaderboard so like new
local function resetAllData()
	for board, _ in pairs(sb) do
		sb[board] = { ["true"] = {}, ["false"] = {}, }	
	end

	SaveLeaderboard(sb)
end

net.Receive("LB_ResetData", resetAllData)

--Net Area End

--Misc method - Allows copying of table without linking them.
function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

--Misc method - Read's the bit and send's back the data
function convertBit(bitD)
	if ( bitD ==  1 ) then
		return "true"
	else
		return "false"
	end
end
