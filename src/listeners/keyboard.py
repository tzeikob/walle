# A listener module to count cross platform keyboard events

from pynput import keyboard

# The internal state of the listener
state = {
  'counters': {
    'press': 0
  }
}

# Resets the state back to initial values
def reset ():
  state['counters']['press'] = 0

# Counts up the key press event
def on_press (key):
  state['counters']['press'] += 1

# Creating the actual keyboard listener
listener = keyboard.Listener(on_press=on_press)