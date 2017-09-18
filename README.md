Docker externalIP image 
=======================

This image assign specific IP-address on the host interface.

This is mainly used for Kubernetes externalIP services.

You can run container with IP-address and it will be fully managed by kubenrnetes.
This is very useful if you have many IP-addresses and if you want to manage them like pods.

Container can be migrated to another host, and IP will be migrated too.

Variables
---------
* `IPADDRESS` - IP-address with prefix (example: `1.2.3.4/24`)
* `VLAN` - VLAN number (example: `100`)
* `DEVICE` - Device for IP-address assigning (default: `eth0`)
* `DROP_INPUT` - If `true` will create iptables rule (default: `false`)
* `VALID_LFS` - IP valid lifetime in seconds parameter (default: `10`)
* `REFFERRED_LFT` - IP refferred lifetime in seconds patrameter (default: `7`)
* `TIMEOUT` - Timeout in seconds between each IP assigning (default:`7`)

Example Usage
-------------

```bash
# Download example deployment file
wget https://raw.githubusercontent.com/kvaps/docker-externalIP/master/ip-example.yaml

# Insert your values
vim ip-example.yaml

# Create ip address deployment
kubectl create -f ip-example.yaml

# We will create simple nginx service for example
kubectl run my-nginx --image=nginx --replicas=2 --port=80

# Expose nginx service with externalIP
kubectl expose deployment my-nginx --port=80 --type=LoadBalancer --external-ip=1.2.3.4
```
