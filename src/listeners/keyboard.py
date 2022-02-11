# A listener module to count cross platform keyboard events

from pynput import keyboard

state = {
  'up': False,
  'data': {
    'press': 0
  }
}

# Counts up the key press event
def on_press (key):
  state['data']['press'] += 1

# Stops the listener thread
def stop ():
  listener.stop()
  state['up'] = False

# Spawns the listener thread
def start ():
  listener.start()
  state['up'] = True

# Creating the actual keyboard listener
listener = keyboard.Listener(on_press=on_press)