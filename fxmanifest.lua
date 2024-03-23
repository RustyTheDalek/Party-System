fx_version 'cerulean'
game 'gta5'

lua54 "yes"

author 'Rusty'
version '0.0.1'

client_script 'client.lua'
shared_scripts {
    'shared/*.lua'
}
dependency "chat"

ui_page "nui/index.html"

files {
    'nui/index.html',
    'nui/index.css',
    'nui/js/index.js',
    'config.json'
}
