#!/bin/sh
set -e
set -x
cp $0 /tmp/

# on cloud nodes, br mac address should be the same as the nic
MAC=`ip link show {{IFACE}} |grep link | awk '{print $2}'`
cp -f /etc/network/interfaces /tmp/interfaces.bkp

systemctl restart openvswitch-switch || service openvswitch-switch restart

ovs-vsctl add-br br-{{NAME}}
ovs-vsctl set bridge br-{{NAME}} other-config:hwaddr=$MAC

cat << EOF >> /etc/network/interfaces

auto {{IFACE}}
iface {{IFACE}} inet manual
pre-up ifconfig {{IFACE}} mtu 8000 up

EOF

ovs-vsctl add-port br-{{NAME}} {{IFACE}}
ifup br-{{NAME}}
