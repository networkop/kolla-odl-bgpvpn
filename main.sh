

#  "------------------------------------"
# "Main script (do not execute directly)"
# "-------------------------------------"


SNAPSHOT_EXISTS=false
MYNAME="$(basename $0)"
MYDIR="${BASH_SOURCE%/*}"
KOLLA_NODES=( controller-1 compute-1 )

usage () {
  echo
  echo "Usage: ${MYNAME} [do|save|rollback|show|rm|destroy]"
  echo "                  do       - Build new environment"
  echo "                  save     - Save current snapshots"
  echo "                  rollback - Revert current snapshots"
  echo "                  show     - Show current snapshots"
  echo "                  clear    - Delete current snapshots"
  echo "                  destroy  - Destroy current environment"
  echo
}

# Check to make sure we've got exactly one argument
check_if_one_arg () {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi
}

snapshot_exists () {
  check_if_one_arg "$@"
  DOMAIN_ID=$1
  res=$(sudo virsh snapshot-list ${DOMAIN_ID})
  if [[ $? -eq 0 ]] && [[ "$res" == *"$SNAPSHOT_NAME"* ]]; then
    echo -e "\nSnapshot for domain ${DOMAIN_ID} exists."
    SNAPSHOT_EXISTS=true
  else
    echo -e "\nSnapshot for domain ${DOMAIN_ID} doesn't exist."
  fi
}


snapshot_save () {
  check_if_one_arg "$@"
  DOMAIN_ID=$1
  res=$(sudo virsh snapshot-create-as --domain ${DOMAIN_ID} --name ${SNAPSHOT_NAME})
  if [[ $? -eq 0 ]]; then
    echo -e "\nSnapshot for domain ${DOMAIN_ID} created."
    SNAPSHOT_EXISTS=true
  else
    echo -e "\nFail to create snapshot for domain ${DOMAIN_ID}."
  fi
}

snapshot_delete () {
  check_if_one_arg "$@"
  DOMAIN_ID=$1
  snapshot_exists $DOMAIN_ID
  if [[ $SNAPSHOT_EXISTS == "true" ]]; then
    res=$(sudo virsh snapshot-delete ${DOMAIN_ID} ${SNAPSHOT_NAME})
    if [[ $? -eq 0 ]]; then
      echo -e "\nSnapshot ${SNAPSHOT_NAME} for domain ${DOMAIN_ID} deleted."
      SNAPSHOT_EXISTS=false
    fi
  fi
}

snapshot_revert () {
  check_if_one_arg "$@"
  DOMAIN_ID=$1
  snapshot_exists $DOMAIN_ID
  if [[ $SNAPSHOT_EXISTS == "true" ]]; then
    res=$(sudo virsh snapshot-revert --domain ${DOMAIN_ID} --snapshotname ${SNAPSHOT_NAME} --running)
    if [[ $? -eq 0 ]]; then
      echo -e "\nSnapshot ${SNAPSHOT_NAME} for domain ${DOMAIN_ID} rolled back."
      SNAPSHOT_EXISTS=true
    fi
  fi
}

snapshot_do_all () {
  check_if_one_arg "$@"
  action=$1
  echo -e "\nExecuting ${action} action..."
  for node in "${KOLLA_NODES[@]}"; do
    snapshot_${action} $node
  done
}



check_if_one_arg "$@"

ACTION=$1

case $ACTION in
  save)     snapshot_do_all 'save'   ;;
  clear)    snapshot_do_all 'delete' ;;
  show)     snapshot_do_all 'exists' ;;
  rollback) snapshot_do_all 'revert' ;;
  destroy)
	  echo "Destroying all VMs and docker registry"
    read -p "Are you sure?[y/n]: " choice
    case "$choice" in
      y|Y )
        echo "Good bye!"
        snapshot_do_all 'delete'
        ansible-playbook $ANSIBLE_PLAYBOOK -e "clean=True"
        ;;
      n|N )
        echo "No worries";;
      * )
        echo "Invalid input";;
    esac
	  ;;
  do)
    snapshot_do_all 'exists'
    if [[ SNAPSHOT_EXISTS == 'true' ]]; then
      echo "Looks like environment has been built and saved"
      read - p "Do you want to continue?[y/n]: " choice
      case "$choice" in
        y|Y )
          echo "Re-building the environment"
          snapshot_do_all 'delete'
          ansible-playbook $ANSIBLE_PLAYBOOK -e "action=create"
          ;;
        n|N ) echo "Not doing anything" ;;
        * )   echo "Error: Unrecognised input";;
      esac
    else
      echo "Building new environment"
      ansible-playbook $ANSIBLE_PLAYBOOK -e "action=create"
    fi
    ;;
  *)
	  echo "Error: Unrecognised input"
    usage
esac

echo
