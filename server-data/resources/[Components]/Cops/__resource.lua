-- Last manifest version
resource_manifest_version "77731fab-63ca-442c-a67b-abc70f28dfa5"

-- Loading the component
server_script 'iCops_server.lua'
client_scripts {
	'iCops_client.lua',
	'gui.lua'
}