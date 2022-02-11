# A synchronous resolver to read static system information

import platform
import getpass
import socket
import psutil
from util.convert import text, integer

state = {
  'data':{
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
}

def resolve ():
  dist = platform.linux_distribution()

  name = dist[0]
  version = dist[1]
  codename = dist[2]

  state['data']['release']['name'] = text(name)
  state['data']['release']['version'] = text(version)
  state['data']['release']['codename'] = text(codename)

  architecture = platform.machine()

  state['data']['release']['arch'] = text(architecture)

  user = getpass.getuser()
  host = socket.gethostname()

  state['data']['login']['user'] = text(user)
  state['data']['login']['host'] = text(host)

  cores = psutil.cpu_count(logical=False)
  threads = psutil.cpu_count(logical=True)

  state['data']['hardware']['cpu']['cores'] = integer(cores)
  state['data']['hardware']['cpu']['threads'] = integer(threads)