LB = LB or {}

if SERVER then
	AddCSLuaFile()

	include( "leaderboard/sv_init.lua")
else
	include( "leaderboard/cl_init.lua" )
end