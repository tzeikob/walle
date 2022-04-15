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

class Window (Gtk.Window):
  def __init__ (self, canvas):
    Gtk.Window.__init__(self)

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

    screen = self.get_screen()
    rgba = screen.get_rgba_visual()
    self.set_visual(rgba)
    self.override_background_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(0, 0, 0, 0))

    drawingarea = Gtk.DrawingArea()
    self.add(drawingarea)

    drawingarea.connect('draw', canvas.draw)
    self.connect('destroy', Gtk.main_quit)

    self.move(0, 0)
    self.show_all()

  def launch (self):
    GLib.timeout_add_seconds(1, self.refresh)
    Gtk.main()

    return True

  def refresh (self):
    self.queue_draw()

    return True