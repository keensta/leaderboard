--Data conversion script for https://scriptfodder.com/scripts/view/446
include( "score.lua" )

oldLeaderboard = false -- Converts HandsomeMatts old leaderboard data to my new system
oldData = false  --Converts all old SteamIDS to steamid64, new system now uses steamid64 so it may never clash on ids :)
convert = false -- If convert is true and oldData & oldLeaderboard are false then it converts Tommys Modification so the below files to new file
		-- system. 

local files = { ["m16.txt"] = "M16 Kills", }


beenDone = false --Don't touch

function convertData()

	if ( convert == false ) then return end
 	
 	if ( oldLeaderboard == false && oldData == false && beenDone == false) then
 		beenDone = true
 		timer.Simple(3, function()
 			for key, val in pairs(files) do
				MsgN("Key: ", key, " Value: ", val)

				if ( file.Exists("leaderboardData/"..key, "DATA") == true ) then
					tableData = util.JSONToTable(file.Read("leaderboardData/"..key))

					for pos, data in pairs(tableData) do
						updateScore(data["SteamID"], data["score"], val, "false", true)
						MsgN("Id: ", data["SteamID"], " Score: ", data["score"])
					end
				end
			end
			forceSave()
 		end )
 	end
	
	
 	if ( oldData == true ) then
	 
	 	MsgN("Doing OldData Converstion")
 		
 		if ( beenDone == false ) then
 			dataTable = {}

			if ( file.Exists("leaderboardata/leaderboard.txt", "DATA") ) then
				dataTable = util.JSONToTable(file.Read("leaderboarddata/leaderboard.txt"))
			end

			if ( dataTable != nil  ) then
				for board, _ in pairs(dataTable) do
					for tmp, _ in pairs(dataTable[board]) do
						for userid, score in pairs(dataTable[board][tmp]) do
							dataTable[board][tmp][userid] = score
						end
					end
				end
				
				file.Write("leaderboarddata/leaderbaoard.txt", util.TableToJSON(datatable))
			end

			MsgN("Old Converstion been done")
			beenDone = true

			resetLoadData()
			loadData(nil)
 		end

 	end

	if ( oldLeaderboard == true ) then
		Msg(tostring(sql.TableExists("playerlbdata")), "\n")
	
		if ( beenDone == false ) then
			beenDone = true
			timer.Simple(3, function()
				if ( sql.TableExists("playerlbdata") ) then
					local db = sql.Query("SELECT * FROM playerlbdata")

					local tableS = db
					local currentSteamId = ""
					local dataTable = {}

					Msg("Got data \n")
					for k, v in pairs(tableS) do
						MsgN("Key: ", k,  " Value: ", v)

						for k1, v1 in pairs(v) do
							MsgN("Key1: ", k1,  " Value1: ", v1)

							if ( k1 == "SteamID" ) then
								currentSteamId = v1
							end

							local newName = getConversion(k1)
							MsgN("Name: ", newName)

							if ( newName ~= nil ) then
								dataTable[newName] = v1

								MsgN("Data: ", tostring(dataTable[newName]))
							end
						end

						if ( dataTable ~= nil ) then
							for k2, v2 in pairs(dataTable) do
								MsgN("ID: ", currentSteamId, " V2: ", v2, " K2: ", k2)
								updateScore(util.SteamIDFrom64(currentSteamId), v2, k2, "false", true)
							end
						end

						currentSteamId = ""
						dataTable = {}
					end
				end
				forceSave()
			end )
		end
	end
	
	

end

function getConversion(dataName)
	local conv = { ["InnocentKills"] = "Innocent Kills", ["TraitorKills"] = "Traitor Kills", ["BombKills"] = "C4 Kills", ["KnifeKills"] = "Knife Kills", ["HeadShots"] = "Headshot Kills", ["TimePlayed"] = "TimePlayed"}

	return conv[dataName]
end

hook.Add("PlayerInitialSpawn", "ConvertData", convertData)