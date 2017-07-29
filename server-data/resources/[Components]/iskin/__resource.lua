-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

-- Last manifest version
resource_manifest_version "77731fab-63ca-442c-a67b-abc70f28dfa5"

server_script {
	'server/main.lua',
	'@mysql-async/lib/MySQL.lua',
}

client_scripts {
	'skinchanger.net.dll',
	'client/main.lua',
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/bankgothic.ttf',
	'html/pdown.ttf',
	'html/img/keys/enter.png'
}
