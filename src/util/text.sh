#!/usr/bin/env bash
# A source exposing text utility methods

# Escape slashes in paths: path
esc () {
  local path=$1

  echo $path | sed 's/\//\\\//g'
}