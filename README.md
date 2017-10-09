From plain CentOS7 minimal image to install ansible:

1. yum install -y epel-release
2. yum install -y python-pip python-devel gcc openssl-devel git redhat-rpm-config libselinux-python
3. pip install -r requirements.txt
4. ssh-copy-id localhost

Any of the default role variables can be easily overidden with group or host variables. For example to change default libvirt emulator from the default `/usr/libexec/qemu-kvm` to `/usr/bin/qemu-kvm` do this:

```
mkdir group_vars
echo "host_qemu_path: \"/usr/bin/qemu-kvm\"" >> group_vars/all.yaml
```
