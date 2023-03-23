#!/bin/bash
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

set -e

THIS_DIR=$( dirname -- $( readlink -f "${BASH_SOURCE[0]}" ) )

mkdir -p "$HOME/.vim/"{autoload,swap,backup}

function handle_template() {
  if [[ -e $3 ]]; then
    read -p "Overwrite existing $(basename "$3")? (y/N): " do_copy
  else
    do_copy=y
  fi
  if [[ $do_copy == y || $do_copy == Y ]]; then
    if [[ $1 == copy ]]; then
      # Remove the file so if it is a symlink, we don't write to the remote file
      rm -f "$3"
      cat "$2" | sed "s@{{BASE_DIR}}@${THIS_DIR}@g" >"$3"
    else
      ln -sf "$2" "$3"
    fi
  fi
}
# This file is edited by git for local changes
handle_template copy "$THIS_DIR/gitconfig.in" "$HOME/.gitconfig"
# These files can be customized; most code is in imported from files here
handle_template copy "$THIS_DIR/bashrc.in" "$HOME/.bashrc"
handle_template copy "$THIS_DIR/vimrc.in" "$HOME/.vimrc"
# This can be linked since they probably won't change
handle_template link "$THIS_DIR/tmux.conf.in" "$HOME/.tmux.conf"

# Install deps
if which apt >/dev/null; then
  sudo apt install -y \
      python3 python-is-python3 clang curl git silversearcher-ag tmux
fi

# Install vim plugins
curl -fLo "$HOME/.vim/autoload/plug.vim" \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -es -u "$HOME/.vimrc" -i NONE -c PlugInstall -c qa
( cd "$HOME/.vim/plugged/vimproc.vim" && make)

# Install tmux plugins
if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins"
"$HOME/.tmux/plugins/tpm/bin/update_plugins" all
