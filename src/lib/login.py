# # A lib module resolving the current login data

import getpass
import socket

# Returns the name of the logged in user and host name
def resolve ():
  user = getpass.getuser()
  user = user.lower() if user else None

  host = socket.gethostname()
  host = host.lower() if host else None

  return {
    'user': user,
    'host': host
  }