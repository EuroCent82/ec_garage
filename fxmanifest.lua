fx_version 'cerulean'
game 'gta5'

name 'ec_garage'
description 'EC Garage – Fahrzeugverwaltung mit modernem UI'
author 'EuroC'
version '0.0.1'
lua54 'yes'

ui_page 'web/index.html'

shared_scripts {
    'shared/init.lua',
    'config.lua',
    'config/garages.lua',
}

files {
    'web/index.html',
    'web/creator.html',
    'web/css/style.css',
    'web/css/creator.css',
    'web/css/icons.css',
    'web/js/icons.js',
    'web/js/app.js',
    'web/js/creator.js',
    'web/vendor/fontawesome/css/all.min.css',
    'web/vendor/fontawesome/webfonts/*.woff2',
    'web/vendor/fontawesome/webfonts/*.ttf',
    'sql/install.sql',
    'sql/seed_wuerfelpark.sql',
}

server_scripts {
    'server/db_check.lua',
}

-- client_scripts { 'client/*.lua' }
