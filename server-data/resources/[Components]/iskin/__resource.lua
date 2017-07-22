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
