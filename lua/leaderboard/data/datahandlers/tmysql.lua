--tmysql4-- Bassed off Pointshops provider system

--[[

	tmysql4 is a module for garrys mod, Which can be downloaded from http://facepunch.com/showthread.php?t=1442438

	Make sure you allow remote access to your database from your Garrys Mod server Ip.

	Once downloaded and below config options are set, change LB.DefaultDataHandler value to "tmysql"

]]

-- Config Options, Change these to your database settings

local sql_hostname = "localhost" -- Your database server address
local sql_username = 'root' -- Your database username
local sql_password = ''  -- Your database password
local sql_database = 'leaderboard' -- Your database table name
local sql_port = 3306 -- Your database port, If unknown it's most likely 3306

-- End of Config options, Don't change anything below unless you know what you are doing.

--[[
	Because Sql is pulled on the fly we don't want the data to be live 
	other wise people can work out who the T's are, So we will store
	all data that needs to be pushed here. Then at round end push it.

	Structure  PlayerId -> [ Boardname -> Score ]
]]--

local todo = {}

require("tmysql4")
include( "leaderboard/config/lb_config.lua" )

DH.Fallback = "json"

local con, err = tmysql.initialize(sql_hostname, sql_username, sql_password, sql_database, sql_port)

if ( err ) then
	MsgN("Error connectiong to database:")
	ErrorNoHalt(err)
else

	--Why java templates are needed in lua :P
	function DH:LoadData()
	end

	function DH:SaveData()
		
		for k, v in pairs(todo) do
			local qs = "UPDATE `leaderboarddata` SET"
			for board, score in pairs(v) do
				qs = qs .. " `" .. board .. "`=" .. score .. ","
			end

			qs = string.sub(qs, 1, -2) .. " WHERE `uuid`=" .. k
		
			con:Query(qs, function(res)
				local result = res[1]
				local status = result.status

				if ( not status ) then ErrorNoHalt("[Leaderboard] tmysql4 Error: " .. result.error ) end

				Msg("[Leaderboard] ", k, " data has been saved")

			end )
		end
		
	end

	function DH:GetTable(boardname, temp, live)
		local qs = "SELECT `uuid`, `" .. boardname .. "` FROM `leaderboarddata` ORDER BY `" .. boardname .. "` DESC"
		local data = {}

		con:Query(qs, function(res)
			local result = res[1]
			local status = result.status

			if ( not status ) then 
				ErrorNoHalt("[Leaderboard] tmsql4 failed to get table " .. boardname .. "\n" ..  "Error: " .. result.error )
				data = nil
			else
				data = result.data[boardname]
			end
			
		end )

		return data
	end

	function DH:GetScore(userid, boardname, temp)
		
		if ( temp == "true" ) then
			boardname = boardname .. "-M"
		end

		local qs = "SELECT `uuid`, `" .. boardname .. "` FROM `leaderboarddata` WHERE `uuid`=" .. userid
		local data = 0

		con:Query(qs, function(res)
			local result = res[1]
			local status = result.status

			if ( not status ) then 
				ErrorNoHalt("[Leaderboard] tmsql4 failed to load " .. userid .. " score for " boardname .. "\n" .. "Error: " .. result.error ) 
				return 0
			else
				data = result.data[boardname]
			end

		end )
	end

	function DH:SetScore(userid, score, useScore, boardname, temp)

		local cScore = fif(useScore, self:GetScore(userid, boardname, temp) or 0, 0)

		--Check our todo doesn't already contain some score

		if ( contains(todo, userid)  && contains(todo[userid], boardname) ) then
			cScore = tonumber(cScore) + tonumber(todo[userid][boardname])
		end

		if ( todo[userid] ~= nil ) then
			todo[userid][boardname] = tonumber(score) + tonumber(cScore)
		else
			todo[userid] = { [boardname] = tonumber(score) + tonumber(cScore) }
		end

	end

	function DH:GetAllData(userid)
		local qs = "SELECT * FROM `leaderboarddata` WHERE `uuid`=" .. userid
		local data = {}

		con:Query(qs, function()
			local result = res[1]
			local status = result.status

			if ( not status ) then
				ErrorNoHalt("[Leaderboard] Unable to get user data for " .. userid .. " . \n Reason: " .. result.error )
			else

				for dataN, dataV in pairs(result.data) do
					data[dataN] = dataV
				end
				
			end
		end )

		return data
	end

	local function DH:CreateBoard(boardname)
		local qs = "ALTER TABLE leaderboarddata ADD " .. boardname .. " int "

		con:Query(qs, function()
			local result = res[1]
			local status = result.status

			if ( not status ) then
				ErrorNoHalt("[Leaderboard] Unable to create a new board for " .. boardname ..  ". \n Reason: " .. result.error )
			end
		end )
	end

	function DH:ResetData(boardname, temp)
		if ( temp == "true" ) then
			boardname = boardname .. "-M"
		end

		local qs = "ALTER TABLE `leaderboarddata` DROP COLUMN `" .. boardname .. "`"

		con:Query(qs, function()
			local result = res[1]
			local status = result.status

			if ( not status ) then
				ErrorNoHalt("[Leaderboard] Either the column doesn't exist or something has went wrong. \n Reason: " .. result.error )
			else
				Msg("[Leaderboard] Column " .. boardname .. " has been reset.")
			end
		end )

		self:CreateBoard(boardname)

	end

	function DH:IsBanned(userid)
		local qs = "SELECT `uuid`, `banned` FROM `leaderboarddata` WHERE `uuid`=" .. userid
		local isBanned = false

		con:Query(qs, function()
			local result = res[1]
			local status = result.status

			if ( not status ) then 
				ErrorNoHalt("[Leaderboard] Failed ban check on " .. userid .. ". \n Reason Error: " .. result.error )
				return false --We will give them the benefit of the doubt
			else
				local oc = result.data[c]

				if ( oc == 0 ) then
					isBanned = false
				else
					isBanned = true
				end

			end

		end )

		return isBanned
	end

	function DH:AddBan(userid, reason)
		local data = { ["banned"] = true, ["banReason"] = reason}

		updateData(userid, data)
	end

	function DH:RemoveBan(userid)
		local data = { ["banned"] = false, ["banReason"] = ""}

		updateData(userid, data)
	end

	function DH:GetBanList()
		local banReasons = getAllData("uuid", "banReason")
		local banList = {}

		for k, _ in pairs(getAllData("uuid", "banned")) do
			banList[k] = banReasons[k]	
		end

		return banList
	end


	function DH:SetNickname(userid, nickname)
		local data = { ["nickname"] = nickname }

		updateData(userid, data)
	end
	
	function DH:GetNickname(userid)
		return getData(userid, "nickname")
	end

	function DH:GetNicknames()
		return getAllData("nickname")
	end

	function DH:GetId(nickname)
		local qs = "SELECT `uuid` FROM `leaderboarddata` WHERE `nickname`=" .. nickname
		local rData = nil

		con:Querry(qs, function(res)
			local result = res[1]
			local status = result.status

			if ( not status ) then
				ErrorNoHalt("[Leaderboard] Unable to get data for " .. userid .. ". Data required " .. "uuid")
			else
				rData = result.data["uuid"]
			end
		end )

		return rData
	end



	function DH:CreatePlayer(userid)
		--BuildQuery String board part
		local boardString = "( `uuid`, " --What coloums need filling
		local dataString = "( " .. userid .. ", " --What values we are using
		for boardname, v in pairs(LB.boardRef) do
			boardString = boardString .. "`" .. boardname .. "`, "
			dataString = dataString .. "`0`, " 
		end

		boardString = string.sub(boardString, 1, -3) .. ")" --Taking the extra ', ' off and finishing it
		dataString = string.sub(dataString, 1, -3) .. ")" --Taking the extra ', ' off and finishing it

		local qs = "INSERT INTO `leaderboarddata` " .. boardString .. " VALUES " .. dataString

		con:Query(qs, function(res)
			local result = res[1]
			local status = result.status

			if ( not status ) then 
				ErrorNoHalt("[Leaderboard] tmysql4 Error: " .. result.error ) 
			else
				Msg("[Leaderboard] ", k:SteamID64(), " player data created.")
			end

		end )
	end

	--This function will instantly push data to the database
	function updateData(userid, data)
		local qs = "UPDATE `leaderboarddata` SET "

		for c, v in pairs(data) do
			qs = qs .. "`" .. c .. "`=" .. v ..", "
		end

		qs = string.sub(qs, 1, -3) .. " WHERE `uuid`=" .. userid

		con:Query(qs, function(res)
			local result = res[1]
			local status = result.status

			if ( not status ) then
				ErrorNoHalt("[Leaderboard] Unable to add data for " .. userid .. ". Data table: " .. PrintTable(data) )
			end

		end )
	end 

	--This gets one bit of information for one user
	function DH:GetData(userid, board, temp)
		if ( temp == "true" ) then
			board = board .. "-M"
		end

		local qs = "SELECT `" .. board .. "` FROM `leaderboarddata` WHERE `uuid`=" .. userid
		local rData = nil

		con:Query(qs, function(res)
			local result = res[1]
			local status = result.status

			if ( not status ) then
				ErrorNoHalt("[Leaderboard] Unable to get data for " .. userid .. ". Data required " .. board)
			else
				rData = result.data[board]
			end
		end )

		return rData
	end

	--Get's everyones data for the one coloum and a key, in a table. Key -> [board]
	function getAllData(key, board)
		local qs = "SELECT `" .. key .. "`, `" .. board .. "` FROM `leaderboarddata` "
		local rData = {}

		con:Query(qs, function(res)

			for i=1,getTableSize(res) do
				local result = res[i]
				local status = result.status

				if ( not status ) then
					ErrorNoHalt("[Leaderboard] Unable to get all data for " .. uuid .. ". Data required " .. board)
				else
					rData[result.data[key]] = result.data[board]
				end
			end

		end )

		return rData
	end

	function contains(t, element)
		return fif(t[element] ~= nil, true, false)
	end

	function fif(condition, if_true, if_false)
		if condition then return if_true else return if_false end
	end

	function getTableSize(t)
		local i = 0

		for _, _ in pairs(t) do
			i = i + 1	
		end

		return i
	end
end




