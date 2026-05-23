fx_version 'cerulean'
game 'gta5'

author 'CatVex'
description 'Custom License Plate System'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}