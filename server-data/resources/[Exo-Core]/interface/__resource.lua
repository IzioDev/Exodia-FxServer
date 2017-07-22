client_script "client.lua"
client_script "pedSelector.lua"

exports {
    'CreateComponent',
    'GetComponentById',
    'SetComponentAttribute',
    'GetComponentAttribute',
    'showComponent',
    'hideComponent'
}

ui_page('html/ui.html')

files({
    'html/ui.html',
    'html/style.css',
    'html/ui.js'
})
