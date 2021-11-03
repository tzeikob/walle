-- A lua library file for debian gnome ui opertaions

-- Executes a native system command given as string
function string:exec ()
  local file = io.popen (self)
  local output = file:read ("*a")
  file:close ()

  return output
end

-- Updates the system's wallpaper
function updateWallpaper (path)
  if path ~= nil and path ~= "" then
    local background = 'gsettings set org.gnome.desktop.background picture-uri "file://' .. path .. '"'
    background:exec ()
  end
end

-- Updates the system's lock screen wallpaper
function updateLockScreen (path)
  if path ~= nil and path ~= "" then
    local screensaver = 'gsettings set org.gnome.desktop.screensaver picture-uri "file://' .. path .. '"'
    screensaver:exec ()
  end
end

return {
  updateWallpaper = updateWallpaper,
  updateLockScreen = updateLockScreen
}