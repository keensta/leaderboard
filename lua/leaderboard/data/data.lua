--Data conversion script for https://scriptfodder.com/scripts/view/446
include( "score.lua" )


beenDone = false
oldLeaderboard = false
convert = false

local files = {  }

function convertData()

	if ( convert == false ) then return end
 	
 	if ( oldLeaderboard == false && beenDone == false) then
 		beenDone = true
 		timer.Simple(3, function()
 			for key, val in pairs(files) do
				MsgN("Key: ", key, " Value: ", val)

				if ( file.Exists("leaderboardData/"..key, "DATA") == true ) then
					tableData = util.JSONToTable(file.Read("leaderboardData/"..key))

					for pos, data in pairs(tableData) do
						updateScore(util.SteamIDFrom64(data["SteamID"]), data["score"], val, "false", true)
						MsgN("Id: ", util.SteamIDFrom64(data["SteamID"]), " Score: ", data["score"])
					end
				end
			end
			forceSave()
 		end )
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