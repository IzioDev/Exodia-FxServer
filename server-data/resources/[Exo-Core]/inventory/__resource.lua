client_script 'client.lua'
client_script 'gui.lua'
server_scripts{
	'server.lua',
	'@mysql-async/lib/MySQL.lua',
}

--ui_page('html/ui.html') --THIS IS IMPORTENT

--[[The following is for the files which are need for you UI (like, pictures, the HTML file, css and so on) ]]--
--files({
--    'html/ui.html',
--    'html/ui.js',
--    'html/nui.js',
--    'html/style.css',
--    'html/font/pdown.ttf',
--    'html/font/HouseScript.ttf'
-- })
