#!/bin/bash
set -e
set -x

ansible-playbook kolla-hosts.yml --extra-vars "clean=True"
