From plain CentOS7 minimal image to install ansible:

1. yum install -y epel-release
2. yum install -y python-pip python-devel gcc openssl-devel git redhat-rpm-config libselinux-python
3. pip install ansible netaddr
4. ssh-copy-id localhost
