# A listener module to count cross platform mouse events

from pynput import mouse

state = {
  'up': False,
  'data': {
    'left': 0,
    'right': 0,
    'middle': 0,
    'scroll_x': 0,
    'scroll_y': 0,
    'move': 0
  }
}

# Counts up left, middle and right click events ignoring any releases
def on_click (x, y, button, pressed):
  if not pressed:
    return

  if button == mouse.Button.left:
    state['data']['left'] += 1
  elif button == mouse.Button.right:
    state['data']['right'] += 1
  elif button == mouse.Button.middle:
    state['data']['middle'] += 1

# Counts up vertical and horizontal scroll events
def on_scroll (x, y, dx, dy):
  state['data']['scroll_x'] += abs(dx)
  state['data']['scroll_y'] += abs(dy)

# Counts up move events
def on_move (x, y):
  state['data']['move'] += 1

# Stops the listener thread
def stop ():
  listener.stop()
  state['up'] = False

# Spawns the listener thread
def start ():
  listener.start()
  state['up'] = True

# Creating the actual mouse listener
listener = mouse.Listener(on_click=on_click, on_scroll=on_scroll, on_move=on_move)