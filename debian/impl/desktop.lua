-- A lua library file for debian gnome ui opertaions

util = require "util"

-- Updates the system's wallpaper
function updateWallpaper (path)
  if path ~= nil and path ~= "" then
    local cmd = 'gsettings set org.gnome.desktop.background picture-uri "file://' .. path .. '"'
    util.exec (cmd)
  end
end

-- Updates the system's lock screen wallpaper
function updateLockScreen (path)
  if path ~= nil and path ~= "" then
    local cmd = 'gsettings set org.gnome.desktop.screensaver picture-uri "file://' .. path .. '"'
    util.exec (cmd)
  end
end

return {
  updateWallpaper = updateWallpaper,
  updateLockScreen = updateLockScreen
}