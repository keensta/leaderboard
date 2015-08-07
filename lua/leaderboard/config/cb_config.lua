CB = CB or {} -- Don't touch

CB["LightSaber"] = {
	boardname = "Lightsaber Kills", --Name of the board to save the data to, Must match the one you have in LB.boardRef in lb_config.lua
	class = {"weapon_ttt_lightsaber_red", "weapon_ttt_lightsaber_green", "weapon_ttt_lightsaber_blue"}, --Weapon classes so we can id what you are looking for 
	isInnocent = true, --If innocents should get points as they get kills with the weapon
	isTraitor = true, --If traitors should get points as they get kills with the weapon
}


