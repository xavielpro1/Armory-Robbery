local holdingUp = false
local store = ""
local blipRobbery = nil
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function drawTxt(x,y, width, height, scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0,255)
	SetTextDropShadow()
	if outline then SetTextOutline() end

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('xp1robo:Robando')
AddEventHandler('xp1robo:Robando', function(currentStore)
	holdingUp, store = true, currentStore
end)

RegisterNetEvent('xp1robo:QuitarBlip')
AddEventHandler('xp1robo:QuitarBlip', function()
	RemoveBlip(blipRobbery)
end)

RegisterNetEvent('xp1robo:PonerBlip')
AddEventHandler('xp1robo:PonerBlip', function(position)
	blipRobbery = AddBlipForCoord(position.x, position.y, position.z)

	SetBlipSprite(blipRobbery, 161)
	SetBlipScale(blipRobbery, 2.0)
	SetBlipColour(blipRobbery, 3)

	PulseBlip(blipRobbery)
end)

RegisterNetEvent('xp1robo:Alejarse')
AddEventHandler('xp1robo:Alejarse', function()
	holdingUp, store = false, ''
	ESX.ShowNotification(_U('xp1robo_cancelado'))
end)

RegisterNetEvent('xp1robo:RoboCompletado')
AddEventHandler('xp1robo:RoboCompletado', function(award)
	holdingUp, store = false, ''
	ESX.ShowNotification(_U('xp1robo_completado', award))
end)

RegisterNetEvent('xp1robo:IniciarTiempo')
AddEventHandler('xp1robo:IniciarTiempo', function()
	local timer = Stores[store].secondsRemaining

	Citizen.CreateThread(function()
		while timer > 0 and holdingUp do
			Citizen.Wait(1000)

			if timer > 0 then
				timer = timer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		while holdingUp do
			Citizen.Wait(0)
			drawTxt(0.66, 1.44, 1.0, 1.0, 0.4, _U('xp1robo_temporizador', timer), 255, 255, 255, 255)
		end
	end)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPos = GetEntityCoords(PlayerPedId(), true)

		for k,v in pairs(Stores) do
			local storePos = v.position
			local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, storePos.x, storePos.y, storePos.z)

			if distance < Config.Punto.DrawDistance then
				if not holdingUp then
					DrawMarker(Config.Punto.Type, storePos.x, storePos.y, storePos.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Punto.x, Config.Punto.y, Config.Punto.z, Config.Punto.r, Config.Punto.g, Config.Punto.b, Config.Punto.a, false, false, 2, false, false, false, false)

					if distance < 0.5 then
						ESX.ShowHelpNotification(_U('xp1robo_pulsar', v.nameOfStore))

						if IsControlJustReleased(0, 38) then
							if IsPedArmed(PlayerPedId(), 4) then
								TriggerServerEvent('xp1robo:RoboInicado', k)
							else
								ESX.ShowNotification(_U('xp1robo_noarma'))
							end
						end
					end
				end
			end
		end

		if holdingUp then
			local storePos = Stores[store].position
			if Vdist(playerPos.x, playerPos.y, playerPos.z, storePos.x, storePos.y, storePos.z) > Config.DistanciaMaxima then
				TriggerServerEvent('xp1robo:Alejarse', store)
			end
		end
	end
end)
