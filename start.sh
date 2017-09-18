#!/bin/bash

error() {
cat <<EOF

$1

  Available variables:
    - IPADDRESS (example: 1.2.3.4/24)
    - VLAN (example: 100)
    - DEVICE (default: eth0)
    - DROP_INPUT (default: false)
    - VALID_LFS (default: 10)
    - REFFERRED_LFT (default: 7)
    - TIMEOUT (default:7)

EOF
exit 1
}
DEVICE="${DEVICE:-eth0}"

# check variables
[ ! -z "${IPADDRESS}" ]               || error "Variable \$IPADDRESS is not set!"
ip link show "${DEVICE}" &> /dev/null || error "Device ${DEVICE} is not found!"

if [ -z "${VLAN}" ]; then
    IPDEVICE="${DEVICE}"
else
    IPDEVICE="${DEVICE}.${VLAN}"
    if ! ip link show "${IPDEVICE}" &> /dev/null; then
        ip link add link "${DEVICE}" name "${IPDEVICE}" "${DEVICE}" type vlan id "${VLAN}"
    fi
fi

cleanup() {
    ip addr del "${IPADDRESS}" dev "${IPDEVICE}"; 
    [ "${DROP_INPUT}" = "true" ] && iptables -D INPUT ! -p ICMP -d "${IPADDRESS}" -j DROP
}

trap cleanup EXIT

[ "${DROP_INPUT}" = "true" ] && iptables -A INPUT ! -p ICMP -d "${IPADDRESS}" -j DROP

while true; do
    ip addr change "${IPADDRESS}" dev "${IPDEVICE}" preferred_lft "${PREFERRED_LFT:-7}" valid_lft "${VALID_LFS:-10}"
    sleep "${TIMEOUT:-7}"
done
