#!/bin/bash

source /etc/kolla/admin-openrc.sh

!
if openstack image list | grep -q cirros; then
    echo "Cirros image already uploaded"
else
  curl -L -o ./cirros http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
  openstack image create --disk-format qcow2 --container-format bare --public \
  --property os_type=linux --file ./cirros cirros
  rm ./cirros
fi

if openstack network list | grep -q demo-net; then
  echo "Network already created"
else
  openstack network create --provider-network-type vxlan demo-net
fi

if openstack subnet list | grep -q demo-subnet; then
  echo "Subnet already created"
else
  openstack subnet create --subnet-range 10.0.0.0/24 --network demo-net \
      --gateway 10.0.0.1 --dns-nameserver 8.8.8.8 demo-subnet
fi

# Get admin user and tenant IDs
ADMIN_USER_ID=$(openstack user list | awk '/ admin / {print $2}')
ADMIN_PROJECT_ID=$(openstack project list | awk '/ admin / {print $2}')
ADMIN_SEC_GROUP=$(openstack security group list --project ${ADMIN_PROJECT_ID} | awk '/ default / {print $2}')

openstack security group rule create --ingress --ethertype IPv4 \
    --protocol icmp ${ADMIN_SEC_GROUP}
openstack security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dst-port 22 ${ADMIN_SEC_GROUP}

openstack flavor create --id 1 --ram 256 --disk 1 --vcpus 1 m1.nano
openstack flavor create --id 2 --ram 512 --disk 1 --vcpus 1 m1.tiny

if openstack server list | grep -q VM1; then
  "VM1 already created"
else
  openstack server create \
    --image cirros \
    --flavor m1.nano \
    --net demo-net \
    VM1
fi
