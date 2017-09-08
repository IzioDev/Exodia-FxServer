-- Last manifest version
resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

-- Loading the component
server_scripts {
	'testAll_server.lua',
	'@mysql-async/lib/MySQL.lua'
}

client_scripts {
	'testAll_client.lua'
}