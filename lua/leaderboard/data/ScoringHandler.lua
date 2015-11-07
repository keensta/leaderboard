include( "leaderboard/data/score.lua" )
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
	print("Picked up kill")
	--If round isn't active no score is counted (In Pre or End round)
	if ( countScore == false ) then return end
	
	--Banned users are no longer tracked - TODO
	--if ( isBanned(a:SteamID()) == true ) then return end

	if ( k == a ) then
		incrementScore(k:SteamID(), "Suicides", "false")
		incrementScore(k:SteamID(), "Suicides", "true")
	end

	if ( a:IsPlayer() == false ) then return end
	
	--If killed isn't a traitor and killer is a traitor 
	if ( k:IsTraitor() == false and a:IsTraitor() == true ) then

		--Checks if Killed is a Detective or Innocent and adds score accordingly 
		if ( k:IsDetective() == true ) then
			incrementScore(a:SteamID(), "Detective Kills", "false")
			incrementScore(a:SteamID(), "Detective Kills", "true")
		else
			incrementScore(a:SteamID(), "Innocent Kills", "false")
			incrementScore(a:SteamID(), "Innocent Kills", "true")
		end
		
		print("Is Traitor", " hitgroup ", k:LastHitGroup())
		--Checks if kill is headshot
		if ( k:LastHitGroup() == HITGROUP_HEAD ) then
			print("Traitor headshot")
			incrementScore(a:SteamID(), "Headshot Kills", "false")
			incrementScore(a:SteamID(), "Headshot Kills", "true")
		end

		--Knife kills by Traitor
		if ( i:GetClass() == "weapon_ttt_knife" or i:GetClass() == "ttt_knife_proj" ) then
			incrementScore(a:SteamID(), "Knife Kills", "false")
			incrementScore(a:SteamID(), "Knife Kills", "true")
		end

		--C4 Kills by Traitor
		if ( i:GetClass() == "ttt_c4" ) then
			incrementScore(a:SteamID(), "C4 Kills", "false")
			incrementScore(a:SteamID(), "C4 Kills", "true")
		end

		--If a traitor crowbars the innocent to death or kills him with it for final blow. 
		if ( i:GetClass() == "weapon_zm_improvised" or i:GetClass() == "weapon_crowbar" or string.find(i:GetClass(), "lightsaber") ) then
			incrementScore(a:SteamID(), "Crowbar Kills", "false")
			incrementScore(a:SteamID(), "Crowbar Kills", "true")
		end
		
		--Custom boards check
		for _, cBoard in pairs(CB) do
			if ( cBoard.isInnocent ) then

				local weapon = i:GetClass()

				if ( weapon == "player" ) then
					weapon = i:GetActiveWeapon():GetClass()
				end

				if ( doesContain(weapon, cBoard.class) ) then
					incrementScore(a:SteamID(), cBoard.boardname, "false")
					incrementScore(a:SteamID(), cBoard.boardname, "true")
				end
			end
		end
	end

	--If killed is a traitor and killer isn't a traitor
	if ( k:IsTraitor() == true and a:IsTraitor() == false ) then
		--Add's traitor kill against Innocents name
		incrementScore(a:SteamID(), "Traitor Kills", "false")
		incrementScore(a:SteamID(), "Traitor Kills", "true")

		print("Isn't traitor", " hitgroup ", k:LastHitGroup())
		--Checks if kill is headshot
		if ( k:LastHitGroup() == HITGROUP_HEAD ) then
			print("innocent headshot")
			incrementScore(a:SteamID(), "Headshot Kills", "false")
			incrementScore(a:SteamID(), "Headshot Kills", "true")
		end

		--If Innocent knifes a T they get a point
		if ( i:GetClass() == "weapon_ttt_knife" or i:GetClass() == "ttt_knife_proj" ) then
			incrementScore(a:SteamID(), "Knife Kills", "false")
			incrementScore(a:SteamID(), "Knife Kills", "true")
		end

		--If a Innocent c4's a traitor they get a point per T kill (Maybe negative for innocent kills???).
		if ( i:GetClass() == "ttt_c4" ) then
			incrementScore(a:SteamID(), "C4 Kills", "false")
			incrementScore(a:SteamID(), "C4 Kills", "true")
		end

		--If a Innocent crowbars the traitor to death or kills him with it for final blow. 
		if ( i:GetClass() == "weapon_zm_improvised" or  i:GetClass() == "weapon_crowbar") then
			incrementScore(a:SteamID(), "Crowbar Kills", "false")
			incrementScore(a:SteamID(), "Crowbar Kills", "true")
		end

		--Custom boards check
		for _, cBoard in pairs(CB) do
			if ( cBoard.isInnocent ) then

				local weapon = i:GetClass()

				if ( weapon == "player" ) then
					weapon = i:GetActiveWeapon():GetClass()
				end

				if ( doesContain(weapon, cBoard.class) ) then
					incrementScore(a:SteamID(), cBoard.boardname, "false")
					incrementScore(a:SteamID(), cBoard.boardname, "true")
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
		incrementScore(a:SteamID(), "Explosive Kills", "false")
		incrementScore(a:SteamID(), "Explosive Kills", "true")
	end
	
end )


--Total score

// hook.Add("Initialize", "totalScore", function()
//     local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
//     local time_left = math.max(0, ((GetGlobalInt("ttt_time_limit_minutes") or 60) * 60) - CurTime())

    
//     if ( rounds_left <= 0 or time_left <= 0 ) then
//     	for _, ply in pairs(player.GetAll()) do
//     		if ( ply:IsConnected() ) then
//     			updateScore(ply:SteamID(), ply:Frags(), "Total Score", "false", true)
//     			updateScore(ply:SteamID(), ply:Frags(), "Total Score", "true", true)
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