#!/usr/bin/env bash

# Copyright 2016 Alex Dunn <dunn.alex@gmail.com>
#
# This file is part of book-runner.
#
# book-runner is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# book-runner is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with book-runner.  If not, see <http://www.gnu.org/licenses/>.

set -eu

if [[ ! -f "$1" ]]; then
  echo "$1 doesn't exist"
  exit 1
fi

if [[ ! -f "$2" ]]; then
  echo "$2 doesn't exist"
  exit 1
fi

sha_cmd=sha256sum
if [[ ! -x $(which sha256sum) ]]; then
  sha_cmd="shasum -a 256"
fi

TEXT_SHA=$(eval "$sha_cmd $1" | sed 's:\ .*::g')

if [[ $(eval "$sha_cmd $2" | sed 's:\ .*::g') != "$TEXT_SHA" ]]; then
  echo "$2 has the wrong SHA256"
  exit 1
fi

echo 'All outputs are as expected'
exit 0
