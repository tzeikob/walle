# An asynchronous resolver to monitoring system information

import threading
import time
import statistics
import psutil
import GPUtil
from util.convert import integer, decimal, MB

state = {
  'up': False,
  'data':{
    'cpu': {
      'util': 0,
      'clock': 0,
      'temp': 0
    },
    'memory': {
      'util': 0,
      'used': 0
    },
    'gpu': {
      'util': 0,
      'used': 0,
      'temp': 0
    },
    'disk': {
      'util': 0,
      'used': 0
    }
  }
}

def callback ():
  while state['up']:
    # Read processor data
    utilization = psutil.cpu_percent()
    clock = psutil.cpu_freq().current

    state['data']['cpu']['util'] = decimal(utilization, 1)
    state['data']['cpu']['clock'] = integer(clock)

    # Extract only thermals matching k10temp cpu sensors
    thermals = psutil.sensors_temperatures()['k10temp']

    if thermals:
      temps = []

      # Collect only Tdie thermal data
      for thermal in thermals:
        if thermal.label == 'Tdie':
          temps.append(thermal.current)
      
      if len(temps) > 0:
        mean = statistics.mean(temps)
        state['data']['cpu']['temp'] = decimal(mean, 1)

    # Read memory data
    memory = psutil.virtual_memory()

    utilization = memory.percent
    used = memory.used

    state['data']['memory']['util'] = decimal(utilization, 1)
    state['data']['memory']['used'] = integer(MB(used))

    # Read graphics card data
    gpu = GPUtil.getGPUs()[0]

    utilization = gpu.load * 100
    used = gpu.memoryUsed
    temp = gpu.temperature

    state['data']['gpu']['util'] = decimal(utilization, 1)
    state['data']['gpu']['used'] = integer(used)
    state['data']['gpu']['temp'] = decimal(temp, 1)

    # Read data from root and home disk partitions
    partitions = psutil.disk_partitions()

    used = 0
    free = 0

    for partition in partitions:
      mountpoint = partition.mountpoint

      if mountpoint == '/' or mountpoint == '/home':
        disk = psutil.disk_usage(mountpoint)

        used += disk.used
        free += disk.free

    utilization = used / (used + free)

    state['data']['disk']['util'] = decimal(utilization, 1)
    state['data']['disk']['used'] = integer(MB(used))

    time.sleep(1)

def stop ():
  state['up'] = False

def start ():
  state['up'] = True
  thread.start()

thread = threading.Thread(target=callback, daemon=True)