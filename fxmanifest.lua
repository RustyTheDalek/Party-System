fx_version 'bodacious'
game 'gta5'

author 'Rusty'
version '0.0.1'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'shared.lua'

lua54 "yes"

dependency "chat"

ui_page "nui/index.html"

files {
    'nui/index.html',
    'nui/index.css',
    'nui/index.js'
}
