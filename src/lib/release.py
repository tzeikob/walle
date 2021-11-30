# A lib module resolving os release metadata

import platform

# Returns distribution name, version, codename and architecture
def resolve ():
  dist = platform.linux_distribution()

  if not isinstance(dist, tuple):
    raise Exception('release dist resolved to a non tuple value')

  if len(dist) < 3:
    raise Exception('release dist resolved to a tuple with invalid length')

  name = dist[0]
  name = name.lower() if name else None

  version = dist[1]
  version = version.lower() if version else None
  
  codename = dist[2]
  codename = codename.lower() if codename else None

  arch = platform.machine()
  arch = arch.lower() if arch else None

  return {
    'name': name,
    'version': version,
    'codename': codename,
    'arch': arch
  }