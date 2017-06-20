#!/bin/bash
#set -e
#set -x

echo
echo  "----------------------------"
echo "Kolla containers build script"
echo "----------------------------"
echo

SNAPSHOT_NAME='post-build'
ANSIBLE_PLAYBOOK='kolla-build.yml'

if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/main.sh"
