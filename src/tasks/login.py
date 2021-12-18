# A resolver module task resolving the current login data

import getpass
import socket
from convert import text

data = {}

# Returns the name of the logged in user and host name
def resolve ():
  user = getpass.getuser()
  host = socket.gethostname()

  data['user'] = text(user)
  data['host'] = text(host)

  return data