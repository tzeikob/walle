# A system resolver to resolve user login information

import getpass
import socket
from convert import text

# Returns a data object populated with user login and host attributes
def resolve ():
  user = getpass.getuser()
  host = socket.gethostname()

  data = {
    'user': text(user),
    'host': text(host)
  }

  return data