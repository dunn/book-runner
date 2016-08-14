#!/usr/bin/env bash

# Copyright 2016 Alex Dunn <dunn.alex@gmail.com>
#
# This file is part of read-thing.
#
# read-thing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# read-thing is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with read-thing.  If not, see <http://www.gnu.org/licenses/>.

set -eu

if [[ ! -d "$1" ]] || [[ ! -d "$2" ]]; then
  echo "Both arguments ($1 and $2) must be directories"
  exit 2
fi

if [[ ! -f "$1/cast.js" ]] || [[ ! -f "$1/text.js" ]] || [[ ! -f "$1/freq.csv" ]]
   [[ ! -f "$2/cast.js" ]] || [[ ! -f "$2/text.js" ]] || [[ ! -f "$2/freq.csv" ]]; then
  echo "Missing files in output directories"
  exit 3
fi

sha_cmd=sha256sum
if [[ ! -x $(which sha256sum) ]]; then
  sha_cmd="shasum -a 256"
fi

CAST_SHA=$(eval "$sha_cmd $1/cast.js" | sed 's:\ .*::g')
TEXT_SHA=$(eval "$sha_cmd $1/text.js" | sed 's:\ .*::g')
FREQ_SHA=$(eval "$sha_cmd $1/freq.csv" | sed 's:\ .*::g')

if [[ $(eval "$sha_cmd $2/cast.js" | sed 's:\ .*::g') != "$CAST_SHA" ]]; then
  echo "$2/cast.js has the wrong SHA256"
  exit 1
fi

if [[ $(eval "$sha_cmd $2/text.js" | sed 's:\ .*::g') != "$TEXT_SHA" ]]; then
  echo "$2/text.js has the wrong SHA256"
  exit 1
fi

if [[ $(eval "$sha_cmd $2/freq.csv" | sed 's:\ .*::g') != "$FREQ_SHA" ]]; then
  echo "$2/freq.csv has the wrong SHA256"
  exit 1
fi

echo 'All outputs are as expected'
exit 0
