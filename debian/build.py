#!/usr/bin/env python3
# A script to build the package for debian systems

import sys
import os
import shutil
import subprocess
import ruamel.yaml
import getpass

# Aborts build process on fatal errors
def abort (message, code):
  print(f'Error: {message}')
  print(f'Process exited with code: {code}')

  sys.exit(code)

# Abort if user in context is root or sudo used
if getpass.getuser() == 'root':
  abort("[Errno 13] Don't run as root user", 1)

# Abort if the script is called outside the root folder
if __file__ != './build.py':
  abort("[Error ] Don't run this script outside the root folder", 1)

# Initialize yaml parser
yaml = ruamel.yaml.YAML()

# Read and load the package file data
with open('../package.yml') as pkg_file:
  pkg = yaml.load(pkg_file)

DIST_DIR = '../dist/debian'
BUILD_DIR = DIST_DIR + '/build'
DEB_FILE = DIST_DIR + '/' + pkg['name'] + '-' + pkg['version'] + '.deb'

META_DIR = BUILD_DIR + '/DEBIAN'
INSTALL_DIR = BUILD_DIR + '/usr/share/' + pkg['name']
BIN_DIR = INSTALL_DIR + '/bin'
LUA_DIR = INSTALL_DIR + '/lua'
FONTS_DIR = INSTALL_DIR + '/fonts'

print(f"Debian build process started for '{pkg['name']} v{pkg['version']}'")

# Delete dist files from old builds
if os.path.exists(DIST_DIR):
  shutil.rmtree(DIST_DIR)

# Create meta and installation folders
os.makedirs(META_DIR)
os.makedirs(INSTALL_DIR)

# Copy meta and hook debian files
shutil.copy2('./meta/control', META_DIR)
shutil.copy2('./hooks/preinst', META_DIR)
shutil.copy2('./hooks/postinst', META_DIR)
shutil.copy2('./hooks/postrm', META_DIR)
shutil.copy2('./hooks/prerm', META_DIR)

print('Debian meta files have been added')

# Copy binary files
os.makedirs(BIN_DIR)

shutil.copy2('../src/bin.py', BIN_DIR + '/' + pkg['name'] + '.py')
shutil.copy2('../src/resolver.py', BIN_DIR)

print('Binary files have been added')

# Copy common and utility files
shutil.copytree('../src/common', BIN_DIR + '/common')
shutil.copytree('../src/util', BIN_DIR + '/util')

print('Common and utility modules have been added')

# Copy resolve module files
shutil.copytree('../src/resolvers', BIN_DIR + '/resolvers')

print('Resolver modules have been added')

# Copy listener module files
shutil.copytree('../src/listeners', BIN_DIR + '/listeners')

print('Listener modules have been added')

# Copy lua files
shutil.copytree('../src/lua', LUA_DIR)

print('Lua files have been added')

# Copy the resources files
shutil.copy2('../resources/.conkyrc', INSTALL_DIR)
shutil.copy2('../resources/config.yml', INSTALL_DIR)

print('Resources files have been added')

# Copy font files
os.makedirs(FONTS_DIR)

shutil.copy2('../fonts/glyphs.ttf', FONTS_DIR)
shutil.copy2('../fonts/digits.ttf', FONTS_DIR)

print('Font files have been added')

# Set file size to zero bytes
pkg['size'] = 0

# Iterate recursively across any build files
for path, dirs, files in os.walk(BUILD_DIR):
  for f in files:
    file_path = os.path.join(path, f)

    # Add file size to the total build size
    pkg['size'] += os.path.getsize(file_path)

    # Do not apply package props injection to binary files
    if file_path.endswith('ttf'):
      continue

    # Read file contents
    with open(file_path, 'rt') as f:
      contents = f.read()

    # Inject globals package props
    contents = contents.replace("#PKG_NAME", pkg['name'])
    contents = contents.replace("#PKG_VERSION", pkg['version'])

    # Inject package props in the control meta file
    if file_path.endswith('control'):
      contents = contents.replace("#PKG_ARCHITECTURE", pkg['builds']['debian']['arch'])
      contents = contents.replace("#PKG_MAINTAINER", pkg['author'])
      contents = contents.replace("#PKG_HOMEPAGE", pkg['homepage'])
      contents = contents.replace("#PKG_DESCRIPTION", pkg['description'])
      contents = contents.replace("#PKG_FILE_SIZE", str(pkg['size']))

      deps = pkg['dependencies']['system']
      deps = ', '.join([x for x in deps])

      contents = contents.replace("#PKG_DEPENDS", deps)

    # Inject python and lua dependencies in pre installation hook
    if file_path.endswith('preinst'):
      deps = pkg['dependencies']['python']
      deps = ' '.join([x for x in deps])

      contents = contents.replace('#PKG_PYTHON_DEPS', deps)

      deps = pkg['dependencies']['lua']
      deps = '\n'.join(['luarocks install ' + x for x in deps])

      contents = contents.replace('#PKG_LUA_DEPS', deps)

    # Overwrite file contents
    with open(file_path, 'wt') as f:
      f.write(contents)

print(f"Package file size is {pkg['size']} bytes")

# Build the deb file
subprocess.run(['dpkg-deb', '--build', '--root-owner-group', BUILD_DIR, DEB_FILE])

print(f"Package file saved to '{DEB_FILE}'")
print('Build process has completed successfully')

sys.exit(0)