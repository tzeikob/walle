# A listener module to count cross platform keyboard events

from pynput import keyboard

# The internal state of the listener
state = {
  'counters': {
    'pressed': 0
  }
}

# Resets the state back to initial values
def reset ():
  state['counters']['pressed'] = 0

# Counts up the key press event
def on_press (key):
  state['counters']['pressed'] += 1

# Creating the actual keyboard listener
listener = keyboard.Listener(on_press=on_press)