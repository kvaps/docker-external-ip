#!/bin/sh

error() {
cat <<EOF

$1

  Available variables:
    - IPADDRESS (example: 1.2.3.4/24)
    - VLAN (example: 100)
    - DEVICE (default: eth0)
    - DROP_INPUT (default: false)
    - GATEWAY (example: 1.2.3.1)
    - POD_NETWORK (default: 10.244.0.0/16)
    - VALID_LFS (default: 10)
    - REFFERRED_LFT (default: 7)
    - TIMEOUT (default:7)

EOF
exit 1
}

check_variables() {
    [ ! -z "${IPADDRESS}" ]               || error "Variable \$IPADDRESS is not set!"
    ip link show "${DEVICE}" &> /dev/null || error "Device ${DEVICE} is not found!"
}

configure_vlan() {
    if [ ! -z "${VLAN}" ]; then
        if ! ip link show "${IPDEVICE}" &> /dev/null; then
            ip link add link "${DEVICE}" name "${IPDEVICE}" "${DEVICE}" type vlan id "${VLAN}"
            ip link set "${IPDEVICE}" up
        fi
    fi
}

configure_ip() {
    ip addr change "${IPADDRESS}" dev "${IPDEVICE}" preferred_lft "${PREFERRED_LFT:-7}" valid_lft "${VALID_LFS:-10}"
}

cleanup_ip() {
    ip addr del "${IPADDRESS}" dev "${IPDEVICE}";
}

configure_gateway() {
    if [ ! -z "${GATEWAY}" ]; then
        ip rule add from "${IPSHORT}" table "${TABLE}"
        ip route add default via "${GATEWAY}" table "${TABLE}"
        ip rule add from "${POD_NETWORK:-10.244.0.0/16}" lookup "${TABLE}" # fix martian source
        ping -c1 "${GATEWAY}"
    fi
}

cleanup_gateway() {
    if [ ! -z "${GATEWAY}" ]; then
        ip rule del from "${IPSHORT}" table "${TABLE}"
        ip rule del from "${POD_NETWORK:-10.244.0.0/16}" lookup "${TABLE}"
    fi
}

configure_iptables() {
    [ "${DROP_INPUT}" = "true" ] && iptables -A INPUT ! -p ICMP -d "${IPSHORT}" -j DROP
}

cleanup_iptables() {
    [ "${DROP_INPUT}" = "true" ] && iptables -D INPUT ! -p ICMP -d "${IPSHORT}" -j DROP

}

cleanup() {
    cleanup_ip
    cleanup_iptables
    cleanup_gateway
}

DEVICE="${DEVICE:-eth0}"
IPSHORT="$(echo ${IPADDRESS} | cut -d/ -f1)"
TABLE="$((0x$(printf '%02X' ${GATEWAY//./ })))"
[ -z "${VLAN}" ] && export IPDEVICE="${DEVICE}" || export IPDEVICE="${DEVICE}.${VLAN}"

check_variables
trap cleanup EXIT
configure_vlan
configure_iptables
configure_ip
configure_gateway

while true; do
    configure_ip
    sleep "${TIMEOUT:-7}"
done
