fx_version 'cerulean'
game 'gta5'

name 'ec_garage'
description 'EC Garage – Fahrzeugverwaltung mit modernem UI'
author 'EuroC'
version '0.0.1'
lua54 'yes'

ui_page 'web/nui.html'

shared_scripts {
    'shared/init.lua',
    'config.lua',
    'config/garages.lua',
    'shared/garage.lua',
}

files {
    'web/nui.html',
    'web/index.html',
    'web/creator.html',
    'web/preview.html',
    'web/css/style.css',
    'web/css/creator.css',
    'web/css/icons.css',
    'web/css/nui.css',
    'web/js/nui-env.js',
    'web/js/nui.js',
    'web/js/icons.js',
    'web/js/app.js',
    'web/js/creator.js',
    'web/vendor/fontawesome/css/all.min.css',
    'web/vendor/fontawesome/webfonts/*.woff2',
    'web/vendor/fontawesome/webfonts/*.ttf',
    'sql/install.sql',
    'sql/seed_wuerfelpark.sql',
}

client_scripts {
    'client/ui.lua',
    'client/commands.lua',
    'client/target.lua',
    'client/world.lua',
    'client/garage.lua',
    'client/creator_bridge.lua',
}

server_scripts {
    'server/mysql.lua',
    'server/bridge.lua',
    'server/vehicles.lua',
    'server/db_check.lua',
}
