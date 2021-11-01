-- UI desktop library for debian gnome operations

-- Executes a native system command given as string
function string:exec ()
  local file = io.popen (self)
  local output = file:read ("*a")
  file:close ()

  return output
end

-- Updates the system's wallpaper
function updateWallpaper (path)
  local background = 'gsettings set org.gnome.desktop.background picture-uri "file://' .. path .. '"'
  background:exec ()
end

-- Updates the system's lock screen wallpaper
function updateLockScreen (path)
  local screensaver = 'gsettings set org.gnome.desktop.screensaver picture-uri "file://' .. path .. '"'
  screensaver:exec ()
end

return {
  updateWallpaper = updateWallpaper,
  updateLockScreen = updateLockScreen
}