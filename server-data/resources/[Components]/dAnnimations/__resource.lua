resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

client_scripts {
    'client.lua',
    'pointing.lua',
    '@mysql-async/lib/MySQL.lua', -- Need this to all resource which use Mysql-Async
}

server_script 'server.lua'
