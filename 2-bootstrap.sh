#!/bin/bash
#set -e
#set -x

echo
echo  "----------------------------"
echo "Kolla nodes bootstrap script"
echo "----------------------------"
echo

SNAPSHOT_NAME='post-bootstrap'
ANSIBLE_PLAYBOOK='kolla-bootstrap.yml'

if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/main.sh"
