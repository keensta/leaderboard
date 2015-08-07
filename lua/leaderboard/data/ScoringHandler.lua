include( "score.lua" )
include( "DataHandler.lua" )
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

		--Checks if kill is headshot
		if ( k.lastHitGroup == HITGROUP_HEAD ) then
			incrementScore(a:SteamID(), "Headshot Kills", "false")
			incrementScore(a:SteamID(), "Headshot Kills", "true")
		end

		--Knife kills by Traitor
		if ( i:GetClass() == "weapon_ttt_knife" or i:GetClass() == "ttt_knife_proj" ) then
			incrementScore(a:SteamID(), "Knife Kills", "false")
			incrementScore(a:SteamID(), "Knife Kills", "true")
		end


		--If a traitor crowbars the innocent to death or kills him with it for final blow. 
		if ( i:GetClass() == "weapon_zm_improvised" or i:GetClass() == "weapon_crowbar" or i:GetClass() == "weapon_ttt_fists" or string.find(i:GetClass(), "lightsaber") ) then
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

		--Checks if kill is headshot
		if ( k.lastHitGroup == HITGROUP_HEAD ) then
			incrementScore(a:SteamID(), "Headshot Kills", "false")
			incrementScore(a:SteamID(), "Headshot Kills", "true")
		end

		--If Innocent knifes a T they get a point
		if ( i:GetClass() == "weapon_ttt_knife" or i:GetClass() == "ttt_knife_proj" ) then
			incrementScore(a:SteamID(), "Knife Kills", "false")
			incrementScore(a:SteamID(), "Knife Kills", "true")
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
	
	if ( dmginfo:IsDamageType(DMG_CRUSH) and a ~= nil and a:IsPlayer()) then
		incrementScore(a:SteamID(), "Prop Kills", "false")
		incrementScore(a:SteamID(), "Prop Kills", "true")
	end

	if ( dmginfo:IsDamageType(DMG_BURN) and a ~= nil and a:IsPlayer()) then
		incrementScore(a:SteamID(), "Incendiary Kills", "false")
		incrementScore(a:SteamID(), "Incendiary Kills", "true")
	end

end )

--Two hooks below unused untill I have the features to use them

hook.Add("ScalePlayerDamage", "ScalePlayerDamage_BeforeDeath", function(ply, hitGroup, dmgInfo)
	--Listens to *ScalePlayerDamage* which calls apon player being damaged

	if ( IsValid(dmgInfo:GetInflictor()) and dmgInfo:GetInflictor():GetClass() == "weapon_ttt_push" ) then
		ply.wasNewton = true
	else
		ply.wasNewton = false
	end

	--Sets the last serverside hitGroup(Where they hit you) to be used in *PlayerDeath*
	ply.lastHitGroup = hitGroup 
end )

--Hook for fall damage ONLY
hook.Add("EntityDamage", "EntityDamage_FallDamage", function(ent, dmgInfo)
	local att = dmgInfo:GetAttacker()

	if ( !IsValid(dmgInfo:GetInflictor()) ) then return end

	if ( ent:IsPlayer() and att == game.GetWorld() and dmgInfo:GetDamageType() == DMG_FALL and ply.wasNewton == true) then
		local pushed = ent.was_pushed 
		--This is set to true by TTT if the player was 
		--pushed by crowbar, Should we award the newton launcher guy or not?

		--This is a 100% it's a newton kill, As we checked newton was last damaging object in "ScalePlayerDamage" then check if they die form falling damage
		ent.newtonKilled = true
	end

end )

--Total time played part

startTime = {}

--Make sure we get when they first enter the server and store the time they started
hook.Add("PlayerInitialSpawn", "PlayerTimeStart", function(ply)
	startTime[ply:SteamID()] = CurTime()
end )

--At end of each round check online players and update there time played
hook.Add("TTTEndRound", "PlayerUpdateTime", function(result)
	for _,ply in pairs(player.GetAll()) do
		if ( ply:IsConnected() ) then
			updatePlayerTime(ply:SteamID(), getStartTime(ply:SteamID()), "true")
			updatePlayerTime(ply:SteamID(), getStartTime(ply:SteamID()), "false")
		end
	end
end )

--Returns the starting time of the player
function getStartTime(steamid)

	if ( startTime[steamid] ~= nil ) then
		return startTime[steamid]
	end

	return 0
end

--Misc Methods

function doesContain(element, tab)
	for k, v in pairs(tab) do
		if ( v == element ) then
			return true
		end
	end
	return false
end