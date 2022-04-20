# A module exposing gui components based on Gtk v3.0

import screeninfo
import gi

try:
  gi.require_version('Gtk', '3.0')
  gi.require_version('Gdk', '3.0')
  gi.require_foreign('cairo')
except ImportError:
  print('No Gtk v3.0 or pycairo integration')

from gi.repository import Gtk, Gdk, GLib
from common import globals

class Window (Gtk.Window):
  def __init__ (self, canvas):
    Gtk.Window.__init__(self, name="main")

    self.set_wmclass("deskget", "deskget")
    self.set_skip_pager_hint(True)
    self.set_skip_taskbar_hint(True)
    self.set_type_hint(Gdk.WindowTypeHint.DESKTOP)
    self.set_decorated(False)
    self.set_keep_below(True)
    self.set_accept_focus(False)
    self.set_can_focus(False)

    width = 500
    height = 500

    for monitor in screeninfo.get_monitors():
      if monitor.is_primary:
        width = monitor.width
        height = monitor.height

    self.set_size_request(width, height)

    css = Gtk.CssProvider()
    css.load_from_path(globals.STYLE_FILE_PATH)

    default_screen = Gdk.Screen.get_default()
    style = Gtk.StyleContext
    style.add_provider_for_screen(default_screen, css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

    screen = self.get_screen()
    visual = screen.get_rgba_visual()
    self.set_visual(visual)

    drawingarea = Gtk.DrawingArea()
    drawingarea.connect('draw', canvas.draw)
    self.add(drawingarea)

    self.connect('destroy', Gtk.main_quit)

    self.move(0, 0)
    self.show_all()
    self.stick()

  def launch (self):
    GLib.timeout_add_seconds(1, self.refresh)
    Gtk.main()

    return True

  def refresh (self):
    self.queue_draw()

    return True