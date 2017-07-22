-- Manifest
resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

description 'iJob by Izio.'

ui_page 'ui/ui.html'

-- Server
server_scripts { 
	'iJob_server.lua',
	'classe/job.lua',
	'@mysql-async/lib/MySQL.lua',
}

-- Client
client_scripts {
	'iJob_client.lua',
	'gui.lua'
}

-- NUI Files
files {
	'ui/ui.html',
	'ui/scripts.js',
	'ui/style.css',
	'ui/jquery-3.2.1.min.js', --
}
