fx_version 'cerulean'
game 'gta5'

lua54 "yes"

author 'Rusty'
version '0.0.1'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'shared.lua'

dependency "chat"

ui_page "nui/index.html"

files {
    'nui/index.html',
    'nui/index.css',
    'nui/js/index.js'
}
