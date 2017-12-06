#!/bin/bash
#set -e
#set -x

echo
echo  "----------------------------"
echo "Kolla nodes bootstrap script"
echo "----------------------------"
echo

SNAPSHOT_NAME='post-contrail'
ANSIBLE_PLAYBOOK='kolla-contrail.yml'

if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/main.sh"
