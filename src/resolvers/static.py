# A synchronous resolver to read static system information

import platform
import getpass
import socket
import psutil
from util.convert import text, integer

state = {
  'release': {
    'name': '',
    'version': '',
    'codename': '',
    'arch': ''
  },
  'login': {
    'user': '',
    'host': ''
  },
  'hardware': {
    'cpu': {
      'cores': 1,
      'threads': 1
    }
  }
}

def reset ():
  state['release']['name'] = ''
  state['release']['version'] = ''
  state['release']['codename'] = ''
  state['release']['arch'] = ''
  state['login']['user'] = ''
  state['login']['host'] = ''
  state['hardware']['cpu']['cores'] = 1
  state['hardware']['cpu']['threads'] = 1

def resolve ():
  dist = platform.linux_distribution()

  name = dist[0]
  version = dist[1]
  codename = dist[2]

  state['release']['name'] = text(name)
  state['release']['version'] = text(version)
  state['release']['codename'] = text(codename)

  architecture = platform.machine()

  state['release']['arch'] = text(architecture)

  user = getpass.getuser()
  host = socket.gethostname()

  state['login']['user'] = text(user)
  state['login']['host'] = text(host)

  cores = psutil.cpu_count(logical=False)
  threads = psutil.cpu_count(logical=True)

  state['hardware']['cpu']['cores'] = integer(cores)
  state['hardware']['cpu']['threads'] = integer(threads)