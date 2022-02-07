# A listener module to count cross platform mouse events

from pynput import mouse

# The internal state of the listener
state = {
  'counters': {
    'left': 0,
    'right': 0,
    'middle': 0,
    'scroll_x': 0,
    'scroll_y': 0,
    'moves': 0
  }
}

# Resets the state back to the initial values
def reset ():
  state['counters']['left'] = 0
  state['counters']['right'] = 0
  state['counters']['middle'] = 0
  state['counters']['scroll_x'] = 0
  state['counters']['scroll_y'] = 0
  state['counters']['moves'] = 0

# Counts up left, middle and right click events ignoring any releases
def on_click (x, y, button, pressed):
  if not pressed:
    return

  if button == mouse.Button.left:
    state['counters']['left'] += 1
  elif button == mouse.Button.right:
    state['counters']['right'] += 1
  elif button == mouse.Button.middle:
    state['counters']['middle'] += 1

# Counts up vertical and horizontal scroll events
def on_scroll (x, y, dx, dy):
  state['counters']['scroll_x'] += abs(dx)
  state['counters']['scroll_y'] += abs(dy)

# Counts up move events
def on_move (x, y):
  state['counters']['moves'] += 1

# Creating the actual mouse listener
listener = mouse.Listener(on_click=on_click, on_scroll=on_scroll, on_move=on_move)