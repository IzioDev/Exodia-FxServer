-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

-- Last manifest version
resource_manifest_version "77731fab-63ca-442c-a67b-abc70f28dfa5"

-- Loading the component
server_scripts {
	'iLivreur_server.lua',
	'@mysql-async/lib/MySQL.lua'
}
client_scripts {
	'iLivreur_client.lua',
	'gui.lua'
}