# A listener module to count cross platform mouse events

from pynput import mouse

state = {
  'up': False,
  'data': {
    'clicks': 0,
    'scrolls': 0,
    'moves': 0
  }
}

# Counts up left, middle and right click events ignoring any releases
def on_click (x, y, button, pressed):
  if not pressed:
    return

  state['data']['clicks'] += 1

# Counts up vertical and horizontal scroll events
def on_scroll (x, y, dx, dy):
  state['data']['scrolls'] += abs(dx)
  state['data']['scrolls'] += abs(dy)

# Counts up move events
def on_move (x, y):
  state['data']['moves'] += 1

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