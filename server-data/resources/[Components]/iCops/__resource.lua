-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

-- Last manifest version
resource_manifest_version "77731fab-63ca-442c-a67b-abc70f28dfa5"

--Load the UI page
ui_page 'ui/index.html'

-- Loading the component
server_scripts {
	'iCops_server.lua',
	'@mysql-async/lib/MySQL.lua'
}
client_scripts {
	'iCops_client.lua',
	'gui.lua'
}

-- Load the needed files
files {
	'ui/css/bootstrap.css',
	'ui/css/bootstrap.css.map',
	'ui/css/bootstrap.min.css',
	'ui/css/bootstrap.min.css.map',
	'ui/css/bootstrap-theme.css',
	'ui/css/bootstrap-theme.css.map',
	'ui/css/bootstrap-theme.min.css',
	'ui/css/bootstrap-theme.min.css.map',
	'ui/css/panel.css',
	'ui/fonts/glyphicons-halflings-regular.ttf',
	'ui/images/LSPD.png',
	'ui/js/bootstrap.js',
	'ui/js/bootstrap.min.js',
	'ui/js/npm.js',
	'ui/js/script.js',
	'ui/index.html'
}