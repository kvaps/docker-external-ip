Docker externalIP image 
=======================

This docker image is assign specific IP-address on the host interface.

```
+-------------+    +-------------+    +-------------+
|    node1    |    |    node2    |    |    node3    |
+-------------+    +-------------+    +-------------+
[ 192.168.1.1 ]----[ 192.168.1.2 ]----[ 192.168.1.3 ]
                                      [   1.2.3.4   ]   <----- additional IP, runned via container
```

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
* `GATEWAY` - Add default gateway for this ip (example: 1.2.3.1)
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

Docker example
--------------

This command can be used for tests withot kubernetes environment:

```bash
docker run --cap-add=NET_ADMIN --net=host -e IPADDRESS=1.2.3.4/24 -e DEVICE=br0 -e VLAN=100 -e DROP_INPUT=true kvaps/external-ip
```
