#!/usr/bin/env python
# Copyright 2023 Jacob Trimble
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Helper script to print path info from .bashrc."""

import os
import re
import subprocess
import sys

try:
  # This plugin is used for company-internal code.  It should define a function
  # GetInfo that has the same behavior as the below function.
  import prompt_info_plugin
except ImportError:
  prompt_info_plugin = None


_BASE_DIR = os.path.abspath(os.path.dirname(__file__))

_CYAN = '\033[01;36m'
_BLUE = '\033[01;34m'
_RED = '\033[01;31m'
_RESET = '\033[00m'


def _NormPath(path):
  """Replaces the $HOME part with a '~'."""
  home = os.environ.get('HOME')
  if home:
    # Only replace at the start of the string
    return re.sub('^' + re.escape(home), '~', path)
  return path


def GetInfo(path):
  """Returns info about a git repo at the given path.

  Arguments:
    path: The folder path to get info for.

  Returns:
    The tuple: (name, path, is_dirty), or None.
  """
  with open(os.devnull, 'w') as nul:
    if subprocess.call(['git', '-C', path, 'rev-parse', '--show-toplevel'],
                       stdout=nul, stderr=nul) != 0:
      return None

    try:
      branch = subprocess.check_output(
          ['git', '-C', path, 'rev-parse', '--abbrev-ref', '--verify', 'HEAD'],
          stderr=nul)
      branch = branch.decode('utf8').strip()
    except subprocess.CalledProcessError:
      # This can fail if there are no commits.
      branch = '????'
      is_dirty = True

    if branch == 'HEAD':
      branch = subprocess.check_output(['git', '-C', path, 'rev-parse', 'HEAD'])
      branch = branch.decode('utf8')[:6]

    is_dirty = subprocess.call(['git', '-C', path, 'diff', 'HEAD',
                                '--exit-code'],
                               stdout=nul, stderr=nul) != 0
    return branch, _NormPath(path), is_dirty


def _FormatLine(info):
  """Formats the tuple returned from GetInfo."""
  if not info:
    return None
  return [_CYAN, info[0], _RED, '* ' if info[2] else ' ', _BLUE, info[1]]


def _GetLine():
  """Returns an array of parts for the line."""
  try:
    # Use pwd so we don't resolve symlinks.
    with open(os.devnull, 'wb') as nul:
      path = subprocess.check_output(['pwd', '-L'],
                                     stderr=nul).decode('utf8').strip()
  except (subprocess.CalledProcessError, OSError):
    try:
      path = os.getcwd()
    except OSError:
      path = os.environ['PWD']

  try:
    if prompt_info_plugin:
      line = _FormatLine(prompt_info_plugin.GetInfo(path))
      if line:
        return line

    line = _FormatLine(GetInfo(path))
    if line:
      return line
  except KeyboardInterrupt:
    pass

  return [_BLUE, _NormPath(path)]


if __name__ == '__main__':
  sys.stdout.write(''.join(['['] + _GetLine() + [_RESET, ']\n']))
