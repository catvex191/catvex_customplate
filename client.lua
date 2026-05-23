local ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('catvex_customplate:useItem', function()

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 4.0, 0, 71)

    if vehicle == 0 then
        lib.notify({
                title = 'Information',
                description = 'Kein Fahrzeug in der Nähe',
                type = 'error'
            })
        return
    end

    local boneIndex = GetEntityBoneIndexByName(vehicle, "platelight")

    if boneIndex == -1 then
        boneIndex = GetEntityBoneIndexByName(vehicle, "boot")
    end

    local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIndex)

    local distance = #(coords - boneCoords)

    if distance > 2.0 then
        lib.notify({
                title = 'Information',
                description = 'Du musst hinten am Fahrzeug stehen',
                type = 'error'
            })
        return
    end

    local oldPlate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'plate_input', {
        title = 'Wunschkennzeichen'
    }, function(data, menu)

        local newPlate = tostring(data.value)

        if not newPlate or newPlate == '' then
            lib.notify({
                title = 'Information',
                description = 'Ungültiges Kennzeichen',
                type = 'error'
            })
            return
        end

        newPlate = string.upper(newPlate)

        if string.len(newPlate) > Config.MaxLetters then
            lib.notify({
                title = 'Information',
                description = 'Zu viele Zeichen maximal 8 Zeichen',
                type = 'error'
            })
            return
        end

        menu.close()

        ESX.TriggerServerCallback('catvex_customplate:checkPlate', function(canUse)

            if not canUse then
                lib.notify({
                    title = 'Kennzeichen',
                    description = 'Dieses Kennzeichen existiert bereits!',
                    type = 'error'
                })
                return
            end

            RequestAnimDict("mini@repair")

            while not HasAnimDictLoaded("mini@repair") do
                Wait(0)
            end

            TaskPlayAnim(
                ped,
                "mini@repair",
                "fixing_a_ped",
                8.0,
                -8.0,
                -1,
                1,
                0,
                false,
                false,
                false
            )

            local success = lib.progressCircle({
                duration = Config.ChangeTime,
                position = 'bottom',
                label = 'Kennzeichen wird montiert...',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    move = true,
                    combat = true,
                    car = true
                }
            })

            ClearPedTasks(ped)

            if success then

                SetVehicleNumberPlateText(vehicle, newPlate)

                TriggerServerEvent(
                    'catvex_customplate:updatePlate',
                    oldPlate,
                    newPlate
                )
            end

        end, newPlate)

    end, function(data, menu)
        menu.close()
    end)
end)