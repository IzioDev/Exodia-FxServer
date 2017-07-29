-- Copyright (C) Izio, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Written by Romain Billot <romainbillot3009@gmail.com>, Jully 2017

server_script 
{
	'izone_server.lua',
	'@mysql-async/lib/MySQL.lua',
}

client_script 'izone_client.lua'