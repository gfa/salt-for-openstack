    cat << EOF > /root/network-builder-gre.sh
#!/bin/sh
# gre
GRE_ID=\`neutron  net-create gre --shared --provider:network-type gre --provider:segmentation_id 66 |grep '| id' |awk '{print $4}'\`
SUBNET_ID=\`neutron  subnet-create  gre 10.1.0.1/24 |head -11 |tail -1 |awk '{print \$4}'\`
for sg in \`neutron  security-group-list |grep default |awk '{print \$2}'\` ; do neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 --direction ingress  \$sg ; neutron security-group-rule-create --protocol tcp --port-range-min 9022 --port-range-max 9022 --direction ingress  \$sg ; done
for sg in \`neutron  security-group-list |grep default |awk '{print \$2}'\` ; do neutron security-group-rule-create --protocol icmp --direction ingress \$sg ; done

# gw to inet
neutron net-create gw --router:external --provider:network_type flat  --provider:physical_network inet
neutron subnet-create gw 192.168.122.0/24 --allocation-pool start=192.168.122.10,end=192.168.122.30
ROUTER_ID=\`neutron router-create  defaultgw | grep '^| id' |awk '{print \$4}'\`
neutron router-interface-add \$ROUTER_ID \$SUBNET_ID
neutron router-gateway-set defaultgw gw
EOF

    cat << EOF > /root/network-builder-flat.sh
# flat
FLAT_ID=\`neutron  net-create flat --shared --provider:network-type flat  --provider:physical_network inet |grep '| id' |awk '{print $4}'\`
SUBNET_ID=\`neutron  subnet-create  flat 10.2.0.1/24 |head -11 |tail -1 |awk '{print \$4}'\`
for sg in \`neutron  security-group-list |grep default |awk '{print \$2}'\` ; do neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 --direction ingress  \$sg ; neutron security-group-rule-create --protocol tcp --port-range-min 9022 --port-range-max 9022 --direction ingress  \$sg ; done
for sg in \`neutron  security-group-list |grep default |awk '{print \$2}'\` ; do neutron security-group-rule-create --protocol icmp --direction ingress \$sg ; done
#ROUTER_ID=\`neutron router-create  flatrouter | grep '^| id' |awk '{print \$4}'\`
#neutron router-interface-add \$ROUTER_ID \$SUBNET_ID
EOF

    cat << EOF > /root/network-builder-vlan.sh
# vlan
VLAN_ID=\`neutron  net-create vlan --shared --provider:network-type vlan  --provider:physical_network inet --provider:segmentation_id 66 |grep '| id' |awk '{print $4}'\`
SUBNET_ID=\`neutron  subnet-create  vlan 10.3.0.1/24 |head -11 |tail -1 |awk '{print \$4}'\`
for sg in \`neutron  security-group-list |grep default |awk '{print \$2}'\` ; do neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 --direction ingress  \$sg ; neutron security-group-rule-create --protocol tcp --port-range-min 9022 --port-range-max 9022 --direction ingress  \$sg ; done
for sg in \`neutron  security-group-list |grep default |awk '{print \$2}'\` ; do neutron security-group-rule-create --protocol icmp --direction ingress \$sg ; done
#ROUTER_ID=\`neutron router-create  vlanrouter | grep '^| id' |awk '{print \$4}'\`
#neutron router-interface-add \$ROUTER_ID \$SUBNET_ID

EOF

