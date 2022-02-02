# A listener module to count cross platform mouse events

from pynput import mouse

# The internal state of the listener
state = {
  'counters': {
    'left': 0,
    'right': 0,
    'middle': 0
  }
}

# Resets the state back to initial values
def reset ():
  state['counters']['left'] = 0
  state['counters']['right'] = 0
  state['counters']['middle'] = 0

# Counts up the click press event ignoring releases
def on_click (x, y, button, pressed):
  if not pressed:
    return

  if button == mouse.Button.left:
    state['counters']['left'] += 1
  elif button == mouse.Button.right:
    state['counters']['right'] += 1
  elif button == mouse.Button.middle:
    state['counters']['middle'] += 1

# Creating the actual mouse listener
listener = mouse.Listener(on_click=on_click)