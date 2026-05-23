local ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterUsableItem(Config.ItemName, function(source)
    TriggerClientEvent('catvex_customplate:useItem', source)
end)

ESX.RegisterServerCallback('catvex_customplate:checkPlate', function(source, cb, plate)

    local result = MySQL.scalar.await(
        'SELECT plate FROM owned_vehicles WHERE TRIM(plate) = TRIM(?)',
        {plate}
    )

    if result then
        cb(false)
    else
        cb(true)
    end
end)

RegisterServerEvent('catvex_customplate:updatePlate')
AddEventHandler('catvex_customplate:updatePlate', function(oldPlate, newPlate)

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    oldPlate = ESX.Math.Trim(oldPlate)
    newPlate = ESX.Math.Trim(newPlate)

    local result = MySQL.single.await(
        'SELECT * FROM owned_vehicles WHERE TRIM(plate) = TRIM(?)',
        {oldPlate}
    )

    if not result then
        TriggerClientEvent('esx:showNotification', src,
            'Fahrzeug nicht gefunden')
        return
    end

    local vehicleProps = json.decode(result.vehicle)

    vehicleProps.plate = newPlate

    local updated = MySQL.update.await(
        'UPDATE owned_vehicles SET plate = ?, vehicle = ? WHERE TRIM(plate) = TRIM(?)',
        {
            newPlate,
            json.encode(vehicleProps),
            oldPlate
        }
    )

    if updated > 0 then

        xPlayer.removeInventoryItem(Config.ItemName, 1)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Kennzeichen',
            description = 'Kennzeichen erfolgreich geändert',
            type = 'success'
        })

    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Kennzeichen',
            description = 'Fehler beim Speichern',
            type = 'error'
        })
    end
end)