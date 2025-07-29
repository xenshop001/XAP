
fx_version 'cerulean'
game 'gta5'
author 'Xen '
lua54 'yes'

support 'https://discord.gg/43QuRqqUgV'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

server_script 'server.lua'
client_script 'client.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependency 'es_extended'