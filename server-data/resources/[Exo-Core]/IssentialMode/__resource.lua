-- Manifest
resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

description 'IssentialMode By Izio.'

ui_page 'ui.html'

-- Server
server_scripts { 
	'server/util.lua',
	'server/main.lua',
	'server/classes/player.lua',
	'server/classes/groups.lua',
	'server/player/login.lua',
	'server/iFood.lua',
	'@mysql-async/lib/MySQL.lua'
}

-- Client
client_scripts {
	'client/main.lua',
	'client/iFood.lua'
}

-- NUI Files
files {
	'ui.html',
	'pdown.ttf',
	'bank-icon.png',
	'ui/bootstrap.min.css',
	'ui/bootstrap.min.css.map',
	'ui/bootstrap.min.js',
	'ui/panel.css'
}

server_exports {
	'getPlayerFromId',
	'addAdminCommand',
	'addCommand',
	'addGroupCommand'
}