# A system resolver to resolve distro release information

import platform
from convert import text

# Returns a data object populated with distro attributes
def resolve ():
  dist = platform.linux_distribution()

  name = dist[0]
  version = dist[1]
  codename = dist[2]

  architecture = platform.machine()

  data = {
    'name': text(name),
    'version': text(version),
    'codename': text(codename),
    'arch': text(architecture)
  }

  return data