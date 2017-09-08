resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page 'ui/index.html'

client_scripts {
    'iFuel_client.lua'
}

server_scripts {
	'iFuel_server.lua',
	'@mysql-async/lib/MySQL.lua'
}

files {
	'ui/index.html',
	'ui/icon.png'
}
