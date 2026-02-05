fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Tarti'
description 'Syst�me de permis de conduire avec code de la route ESX'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

server_scripts {
    'server/server.lua'
}

client_scripts {
    'client/client.lua'
}