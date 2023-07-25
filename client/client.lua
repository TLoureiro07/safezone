local notifIn = false
local notifOut = false
local closestZone = 1

Citizen.CreateThread(function()
	for k,zone in pairs(Config.CircleZones) do

		CreateBlipCircle(zone.coords, zone.name, zone.radius, zone.color, zone.sprite)
	end
end)

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #Config.zones, 1 do
			dist = Vdist(Config.zones[i].x, Config.zones[i].y, Config.zones[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
		Citizen.Wait(15000)
	end
end)


local timmer = 0
local inSafe = false
Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		s = 1000
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(Config.zones[closestZone].x, Config.zones[closestZone].y, Config.zones[closestZone].z, x, y, z)
	
		if dist <= 100.0 then 
			s = 0

			if not notifIn then																			  
				NetworkSetFriendlyFireOption(false)
				ClearPlayerWantedLevel(PlayerId())
				inSafe = true
				TriggerEvent('codem-notification:Create', 'You are inside the safezone. Protection enabled.', 'info', 'Safezone', 5000)
				--TriggerEvent('codem-notification:Create', 'Estás dentro de uma safezone. Proteção ativada.', 'info', 'Safezone', 5000)

				notifIn = true
				notifOut = false
			end
		else
			if not notifOut then
				NetworkSetFriendlyFireOption(true)
				s = 5
				TriggerEvent('codem-notification:Create', 'You have 5 seconds left with protection.', 'info', 'Safezone', 5000)
				--TriggerEvent('codem-notification:Create', 'Tens 5 segundos restantes com proteção.', 'info', 'Safezone', 5000)
				inSafe = false
				notifOut = true
				notifIn = false
			end
		end
		Citizen.Wait(s)
	end
end)


Citizen.CreateThread(function()	
	while true do
		Citizen.Wait(1000)
	
		if timmer > 0 then
			timmer = timmer - 1
			if timmer == 0 then
				TriggerEvent('codem-notification:Create', 'Protection disabled', 'info', 'Safezone', 5000)
				--TriggerEvent('codem-notification:Create', 'Proteção desativada', 'info', 'Safezone', 5000)
			end
		end
	end
end)

Citizen.CreateThread(function()	
	while true do
		Citizen.Wait(0)
	
		if inSafe or timmer > 0 then
			local player = PlayerId()
			local playerPed = PlayerPedId()
			
			DisablePlayerFiring(player,true)
			DisableControlAction(0,24) -- INPUT_ATTACK
			DisableControlAction(0,69) -- INPUT_VEH_ATTACK
			DisableControlAction(0,70) -- INPUT_VEH_ATTACK2
			DisableControlAction(0,92) -- INPUT_VEH_PASSENGER_ATTACK
			DisableControlAction(0,114) -- INPUT_VEH_FLY_ATTACK
			DisableControlAction(0,257) -- INPUT_ATTACK2
			DisableControlAction(0,331) -- INPUT_VEH_FLY_ATTACK2
			DisableControlAction(0, 140) -- Melee R
			DisableControlAction(0, 44) -- Melee R
			DisableControlAction(0, 52) -- Melee R
			DisableControlAction(0, 120) -- Melee R
			DisableControlAction(0, 154) -- Melee R
			DisableControlAction(0, 105) -- Melee R
			SetPlayerInvincible(player, true)

			local carros = GetGamePool("CVehicle")

			
			for i = 1,#carros ,1 do
				local veh = GetVehiclePedIsIn(playerPed, false)
	
				if veh ~= 0 then
					SetEntityNoCollisionEntity(carros[i], veh, true)
				else
					SetEntityNoCollisionEntity(carros[i], playerPed, true)
				end
			end	

			for _, i in ipairs(GetActivePlayers()) do
				if i ~= PlayerId() then
				  	local closestPlayerPed = GetPlayerPed(i)
		  
				  	SetEntityNoCollisionEntity(closestPlayerPed, playerPed, true)
		  
				end
			end
		else
			local player = PlayerId()
			SetPlayerInvincible(player, false)
		end
	end
end)



function CreateBlipCircle(coords, text, radius, color, sprite)
	local blip = AddBlipForRadius(coords, radius)

	SetBlipHighDetail(blip, true)
	SetBlipColour(blip, 2)
	SetBlipAlpha (blip, 128)

	-- create a blip in the middle
	blip = AddBlipForCoord(coords)

	SetBlipHighDetail(blip, true)
	SetBlipSprite (blip, sprite)
	SetBlipScale  (blip, 0.7)
	SetBlipColour (blip, color)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end