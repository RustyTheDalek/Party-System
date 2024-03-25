fx_version 'cerulean'
game 'gta5'

lua54 "yes"

author 'Rusty'
version '0.0.1'

client_scripts {
    'client/*.lua',
    'client/**/*.lua'
}
server_scripts {
    'server/*.lua',
    'server.lua'
} 
shared_scripts {
    'shared/*.lua'
}
dependency "chat"

ui_page "nui/index.html"

files {
    'nui/index.html',
    'nui/css/index.css',
    'nui/css/loadingIcon.css',
    'nui/js/index.js',
    'config.json'
}

server_export { 
    'HostingParty',
    'GetPartySources'
}
