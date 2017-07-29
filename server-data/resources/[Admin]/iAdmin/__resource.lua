-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017


-- Manifest
resource_manifest_version 'f15e72ec-3972-4fe4-9c7d-afc5394ae207'

-- Requiring essentialmode
--dependency 'essentialmode'

client_script 'cl_admin.lua'
server_script {
	'sv_admin.lua',
	'@mysql-async/lib/MySQL.lua',
}