--FlatFile-- Bassed off Pointshops provider system

--Leaderboard data
local sb = {}
local tempsb = {}

--Ban data
local banlist = {}

--Nickname data
local nicknames = {}


function DH:LoadData() 
	
	--Load Leaderboard data

	if ( file.Exists("leaderboarddata/leaderboard.txt", "DATA") ) then
		sb = util.JSONToTable(file.Read("leaderboarddata/leaderboard.txt"))
		tempsb = table.Copy(sb)
	end

	--Load Banlist data

	if ( file.Exists("leaderboarddata/banlist.txt", "DATA") ) then
		banlist = util.JSONToTable(file.Read("leaderboarddata/banlist.txt"))
	end

	--Load Nickname data

	if ( file.Exists("leaderboarddata/nicknames.txt", "DATA") ) then
		nicknames = util.JSONToTable(file.Read("leaderboarddata/nicknames.txt"))
	end

end

function DH:SaveData()

	--Save Leaderboard data
	file.Write("leaderboarddata/leaderboard.txt", util.TableToJSON(sb))

	--Save Banlist data
	file.Write("leaderboarddata/banlist.txt", util.TableToJSON(banlist))

	--Save Nicknames data
	file.Write("leaderboarddata/nicknames.txt", util.TableToJSON(nicknames))

end

--Live means if it want's upto date, data which you don't want when showing leaderboards in middle of game
function DH:GetTable(boardname, temp, live)

	local data = fif(live, sb, tempsb)

	if ( data == nil) then
		return nil
	end

	if ( data[boardname] ~= nil and data[boardname][temp] ~= nil ) then
		return data[boardname][temp]
	end

	return nil

end

function DH:GetScore(userid, boardname, temp)

	local data = self:GetTable(boardname, temp, true)

	if ( data == nil ) then
		return 0
	end

	return data[boardname][temp][userid] or 0

end

function DH:SetScore(userid, score, useScore, boardname, temp)
	
	local data = self:GetTable(boardname, temp, true)

	if ( data == nil ) then
		self:CreateBoard(boardname)
		self:SetScore(userid, score, useScore, boardname, temp)
		return
	end

	local cScore = fif(useScore, data[userid] or 0, 0)

	data[userid] = tonumber(score) + tonumber(cScore)

end

function DH:GetAllData(userid)
	local userData = {}

	for board, _ in pairs(sb) do
		userData[board] = sb[board]["false"][userid] or 0
		userData[board .. " - M"] = sb[board]["true"][userid] or 0
	end

	return userData
end

function DH:CreateBoard(boardname)
	sb[boardname] = { ["true"] = {}, ["false"] = {} }
end

function DH:ResetData(boardname, temp)
	sb[boardname][temp] = {}

	self:SaveData()
end

function DH:IsBanned(userid)
	return contains(banlist, userid)
end

function DH:AddBan(userid, reason)
	banlist[userid] = reason
end

function DH:RemoveBan(userid)
	banlist[userid] = nil
end

function DH:GetBanList()
	return banlist
end

function DH:SetNickName(userid, nickname)
	nicknames[userid] = nickname
end

function DH:GetNickname(userid)
	return fif(contains(nicknames, userid), nicknames[userid], userid)
end

function DH:GetNicknames()
	return nicknames
end

function DH:GetId(userName)

	for k,v in pairs(nicknames) do
		if ( v == userName ) then
			return k
		end
	end

	return userName
	
end

function DH:CreatePlayer(userid)
end

function contains(t, element)
	return fif(t[element] ~= nil, true, false)
end

function fif(condition, if_true, if_false)
	if condition then return if_true else return if_false end
end