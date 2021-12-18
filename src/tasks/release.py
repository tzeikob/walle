# A resolver module task resolving os release metadata

import platform
from convert import text

data = {}

# Returns distribution name, version, codename and architecture
def resolve ():
  dist = platform.linux_distribution()

  name = dist[0]
  version = dist[1]
  codename = dist[2]

  data['name'] = text(name)
  data['version'] = text(version)
  data['codename'] = text(codename)

  architecture = platform.machine()

  data['arch'] = text(architecture)

  return data