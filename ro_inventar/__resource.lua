server_scripts {
  '@async/async.lua',
  '@mysql-async/lib/MySQL.lua',
  '@es_extended/locale.lua',
  'server/main.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'client/main.lua',
  'config.lua'
}

ui_page 'html/ui.html'
files {
  'html/ui.html',
  'html/ui.css',
  'html/img/cursor.png',
  'html/img/backpack.png',
  'html/ui.js',
}