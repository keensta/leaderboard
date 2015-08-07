include( "score.lua" )
include( "leaderboard/config/cb_config.lua" )

 --Stop's score being counted in PreRound/AfterRound
local countScore = false

--PreRound Check Start - If while the round isn't active so pre and after round are active don't track scores
hook.Add("TTTEndRound", "LB_EndRound", function(result) 
	countScore = false
end )

hook.Add("TTTBeginRound", "LB_BeginRound", function()
	countScore = true
end )
--PreRound Check END

hook.Add("PlayerDeath", "LB_TrackScore", function(k, i, a)
	--[[
		k = Killed/Victim, i = Inflictor, a = attacker

		Using short names to save time with recode.
	]]--

	--If round isn't active no score is counted (In Pre or End round)
	if ( countScore == false ) then return end
	
	--Banned users are no longer tracked - TODO
	--if ( isBanned(a:SteamID64()) == true ) then return end

	if ( k == a ) then
		incrementScore(k:SteamID64(), "Suicides", "false")
		incrementScore(k:SteamID64(), "Suicides", "true")
	end

	if ( a:IsPlayer() == false ) then return end
	
	--If killed isn't a traitor and killer is a traitor 
	if ( k:IsTraitor() == false and a:IsTraitor() == true ) then

		--Checks if Killed is a Detective or Innocent and adds score accordingly 
		if ( k:IsDetective() == true ) then
			incrementScore(a:SteamID64(), "Detective Kills", "false")
			incrementScore(a:SteamID64(), "Detective Kills", "true")
		else
			incrementScore(a:SteamID64(), "Innocent Kills", "false")
			incrementScore(a:SteamID64(), "Innocent Kills", "true")
		end

		--Checks if kill is headshot
		if ( k.lastHitGroup == HITGROUP_HEAD ) then
			incrementScore(a:SteamID64(), "Headshot Kills", "false")
			incrementScore(a:SteamID64(), "Headshot Kills", "true")
		end

		--Knife kills by Traitor
		if ( i:GetClass() == "weapon_ttt_knife" or i:GetClass() == "ttt_knife_proj" ) then
			incrementScore(a:SteamID64(), "Knife Kills", "false")
			incrementScore(a:SteamID64(), "Knife Kills", "true")
		end

		--C4 Kills by Traitor
		if ( i:GetClass() == "ttt_c4" ) then
			incrementScore(a:SteamID64(), "C4 Kills", "false")
			incrementScore(a:SteamID64(), "C4 Kills", "true")
		end

		--If a traitor crowbars the innocent to death or kills him with it for final blow. 
		if ( i:GetClass() == "weapon_zm_improvised" or i:GetClass() == "weapon_crowbar" or string.find(i:GetClass(), "lightsaber") ) then
			incrementScore(a:SteamID64(), "Crowbar Kills", "false")
			incrementScore(a:SteamID64(), "Crowbar Kills", "true")
		end
		
		--Custom boards check
		for _, cBoard in pairs(CB) do
			if ( cBoard.isInnocent ) then

				local weapon = i:GetClass()

				if ( weapon == "player" ) then
					weapon = i:GetActiveWeapon():GetClass()
				end

				if ( doesContain(weapon, cBoard.class) ) then
					incrementScore(a:SteamID64(), cBoard.boardname, "false")
					incrementScore(a:SteamID64(), cBoard.boardname, "true")
				end
			end
		end
	end

	--If killed is a traitor and killer isn't a traitor
	if ( k:IsTraitor() == true and a:IsTraitor() == false ) then
		--Add's traitor kill against Innocents name
		incrementScore(a:SteamID64(), "Traitor Kills", "false")
		incrementScore(a:SteamID64(), "Traitor Kills", "true")

		--Checks if kill is headshot
		if ( k.lastHitGroup == HITGROUP_HEAD ) then
			incrementScore(a:SteamID64(), "Headshot Kills", "false")
			incrementScore(a:SteamID64(), "Headshot Kills", "true")
		end

		--If Innocent knifes a T they get a point
		if ( i:GetClass() == "weapon_ttt_knife" or i:GetClass() == "ttt_knife_proj" ) then
			incrementScore(a:SteamID64(), "Knife Kills", "false")
			incrementScore(a:SteamID64(), "Knife Kills", "true")
		end

		--If a Innocent c4's a traitor they get a point per T kill (Maybe negative for innocent kills???).
		if ( i:GetClass() == "ttt_c4" ) then
			incrementScore(a:SteamID64(), "C4 Kills", "false")
			incrementScore(a:SteamID64(), "C4 Kills", "true")
		end

		--If a Innocent crowbars the traitor to death or kills him with it for final blow. 
		if ( i:GetClass() == "weapon_zm_improvised" or  i:GetClass() == "weapon_crowbar") then
			incrementScore(a:SteamID64(), "Crowbar Kills", "false")
			incrementScore(a:SteamID64(), "Crowbar Kills", "true")
		end

		--Custom boards check
		for _, cBoard in pairs(CB) do
			if ( cBoard.isInnocent ) then

				local weapon = i:GetClass()

				if ( weapon == "player" ) then
					weapon = i:GetActiveWeapon():GetClass()
				end

				if ( doesContain(weapon, cBoard.class) ) then
					incrementScore(a:SteamID64(), cBoard.boardname, "false")
					incrementScore(a:SteamID64(), cBoard.boardname, "true")
				end
			end
		end
	end

	--Negative points for bad things done (Innocent on Innocent kills)

end )

hook.Add("DoPlayerDeath", "DmgInfo Death", function(ply, attacker, dmginfo)

	k = ply
	a = attacker

	--No need to log Innocent and Traitor kills will be logged by other handler

	if ( dmginfo:IsDamageType(DMG_BLAST) and a ~= nil and a:IsPlayer()) then
		incrementScore(a:SteamID64(), "Explosive Kills", "false")
		incrementScore(a:SteamID64(), "Explosive Kills", "true")
	end
	
end )


--Make sure we get when they first enter the server and store the time they started
hook.Add("PlayerInitialSpawn", "PlayerTimeStart", function(ply)
	startTime( ply:SteamID64(), RealTime() )
end )

--At end of each round check online players and update there time played
hook.Add("TTTEndRound", "PlayerUpdateTime", function(result)
	for _,ply in pairs(player.GetAll()) do
		if ( ply:IsConnected() ) then
			updatePlayerTime(ply:SteamID64(), "false")
			updatePlayerTime(ply:SteamID64(), "true")
		end
	end
end )

--Total score

// hook.Add("Initialize", "totalScore", function()
//     local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
//     local time_left = math.max(0, ((GetGlobalInt("ttt_time_limit_minutes") or 60) * 60) - CurTime())

    
//     if ( rounds_left <= 0 or time_left <= 0 ) then
//     	for _, ply in pairs(player.GetAll()) do
//     		if ( ply:IsConnected() ) then
//     			updateScore(ply:SteamID64(), ply:Frags(), "Total Score", "false", true)
//     			updateScore(ply:SteamID64(), ply:Frags(), "Total Score", "true", true)
//     		end
//     	end
//     end
// end )

--Misc Methods

function doesContain(element, tab)
	for k, v in pairs(tab) do
		if ( v == element ) then
			return true
		end
	end
	return false
end