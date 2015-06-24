#!/bin/bash
logfile=/var/log/cloud-builder.log
exec > $logfile 2>&1
cp -f $0 /tmp/cloud-builder.sh

set -e
set -x
admin_token='{{keystone_admin_token}}'
public_endpoint='{{public_endpoint}}'
admin_endpoint='{{admin_endpoint}}'


su - keystone -s /bin/sh -c "keystone-manage db_sync"


export SERVICE_TOKEN={{keystone_admin_token}}
export SERVICE_ENDPOINT={{admin_endpoint}}
#export SERVICE_ENDPOINT=http://127.0.0.1:35357/v2.0

# admin
ADMIN_TENANT_ID=`keystone tenant-create --name admin |grep id |awk '{print $4}'`
ADMIN_ROLE_ID=`keystone role-create --name admin |grep id |awk '{print $4}'`
ADMIN_USER_ID=`keystone user-create --name admin --pass {{admin_password}} --tenant admin --enabled true |head -6 |grep id | awk '{print $4}'`
keystone user-role-add --user admin --tenant admin --role admin

keystone user-role-list --user admin --tenant admin |grep $ADMIN_ROLE_ID | grep $ADMIN_TENANT_ID |grep $ADMIN_USER_ID

# service
curl --cacert /etc/ssl/certs/ca-certificates.crt -i -X POST ${SERVICE_ENDPOINT}/tenants -H "X-Auth-Token: $SERVICE_TOKEN" -H "User-Agent: python-keystoneclient" -H "Content-Type: application/json" -d '{"tenant": {"enabled": true, "name": "{{service_tenant_name}}", "description": "services tenant", "id": "{{service_tenant_id}}"}}'

keystone tenant-list |grep {{service_tenant_id}}

SERVICE_ROLE_ID=`keystone role-create --name service |grep id |awk '{print $4}'`
keystone role-list |grep $SERVICE_ROLE_ID


# neutron user
keystone user-create --name {{neutron_user}} --pass {{neutron_password}} --tenant {{service_tenant_name}}
keystone user-role-add --user {{neutron_user}} --tenant {{service_tenant_name}} --role service
keystone user-role-list --user {{neutron_user}} --tenant {{service_tenant_name}} |grep $SERVICE_ROLE_ID | grep {{service_tenant_id}}

# nova user
keystone user-create --name {{nova_admin_user}} --pass {{nova_admin_password}} --tenant {{service_tenant_name}}
keystone user-role-add --user {{nova_admin_user}} --tenant {{service_tenant_name}} --role service
keystone user-role-list --user {{nova_admin_user}} --tenant {{service_tenant_name}} |grep $SERVICE_ROLE_ID | grep {{service_tenant_id}}

# glance user
keystone user-create --name {{glance_admin_user}} --pass {{glance_admin_password}} --tenant {{service_tenant_name}}
keystone user-role-add --user {{glance_admin_user}} --tenant {{service_tenant_name}} --role service
keystone user-role-list --user {{glance_admin_user}} --tenant {{service_tenant_name}} |grep $SERVICE_ROLE_ID | grep {{service_tenant_id}}

# user to notify nova
keystone user-create --name {{nova_notify_user}} --pass {{nova_notify_password}} --tenant {{service_tenant_name}}
keystone user-role-add --user {{nova_notify_user}} --tenant service --role admin
keystone user-role-list --user {{nova_notify_user}} --tenant service |grep $ADMIN_ROLE_ID | grep {{service_tenant_id}}

# user to manage neutron
keystone user-create --name {{neutron_admin_user}} --pass {{neutron_admin_password}} --tenant {{service_tenant_name}}
keystone user-role-add --user {{neutron_admin_user}} --tenant service --role admin
keystone user-role-list --user {{neutron_admin_user}} --tenant service |grep $ADMIN_ROLE_ID | grep {{service_tenant_id}}

# user nova-neutron
keystone user-create --name {{nova_neutron_admin_username}} --pass {{nova_neutron_admin_password}} --tenant {{service_tenant_name}}
keystone user-role-add --user {{nova_neutron_admin_username}} --tenant service --role admin
keystone user-role-list --user {{nova_neutron_admin_username}} --tenant service |grep $ADMIN_ROLE_ID | grep {{service_tenant_id}}


# services
NOVA_SERVICE_ID=`keystone service-create --name nova --type compute |grep id  |awk '{print $4}'`
NEUTRON_SERVICE_ID=`keystone service-create --name neutron --type network |grep id  |awk '{print $4}'`
KEYSTONE_SERVICE_ID=`keystone service-create --name keystone --type identity |grep id  |awk '{print $4}'|head -1`
GLANCE_SERVICE_ID=`keystone service-create --name glance --type image |grep id  |awk '{print $4}'`

#endpoints
NOVA_ENDPOINT_ID=`keystone endpoint-create --region {{pillar_env}} --service $NOVA_SERVICE_ID --publicurl '{{nova_endpoint|e}}' --adminurl '{{nova_endpoint|e}}' --internalurl '{{nova_endpoint|e}}' |head -4 |grep id |awk '{print $4}'`
NEUTRON_ENDPOINT_ID=`keystone endpoint-create --region {{pillar_env}} --service $NEUTRON_SERVICE_ID --publicurl {{neutron_url}} --adminurl {{neutron_url}} --internalurl {{neutron_url}} |head -4 |grep id |awk '{print $4}'`
GLANCE_ENDPOINT_ID=`keystone endpoint-create --region {{pillar_env}} --service $GLANCE_SERVICE_ID --publicurl {{glance_host}}:9292/ --adminurl {{glance_host}}:9292/ --internalurl {{glance_host}}:9292/ |head -4 |grep id |awk '{print $4}'`
KEYSTONE_ENDPOINT_ID=`keystone endpoint-create --region {{pillar_env}} --service $KEYSTONE_SERVICE_ID --publicurl {{auth_uri}} --adminurl {{keystone_admin_endpoint}} --internalurl {{auth_uri}} |head -5 |grep id |awk '{print $4}'`


    cat << EOF > /root/openrc.admin
unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_AUTH_URL
export OS_USERNAME=admin
export OS_PASSWORD={{admin_password}}
export OS_TENANT_NAME=admin
export OS_AUTH_URL={{admin_endpoint}}
export ADMIN_TENANT_ID=$ADMIN_TENANT_ID
export OS_REGION_NAME={{pillar_env}}
export OS_NO_CACHE=1
EOF


    cat << EOF > /root/image-creator.sh
glance image-create --location http://192.168.255.1:9999/misc/cirros-0.3.2.qcow2 --disk-format qcow2 --container-format bare --name cirros  --is-public true
glance image-create --location http://192.168.255.1:9999/misc/wheezy-latest.qcow2 --disk-format qcow2 --container-format bare --name wheezy --is-public true
glance image-create --location http://192.168.255.1:9999/misc/wheezy-lxc.raw --disk-format raw --container-format bare --name wheezy-lxc --property hypervisor_type=lxc  --is-public true
glance image-create --location http://192.168.255.1:9999/misc/cirros-0.3.3-x86_64-rootfs.img --disk-format raw --container-format bare --name cirros-lxc --property hypervisor_type=lxc  --is-public true
glance image-create --location http://192.168.255.1:9999/misc/jessie-systemd.img --disk-format raw --container-format bare --name jessie-systemd --property hypervisor_type=lxc  --is-public true
glance image-create --location http://192.168.255.1:9999/misc/jessie-sysvinit.img --disk-format raw --container-format bare --name jessie-sysvinit --property hypervisor_type=lxc  --is-public true
glance image-create --location http://192.168.255.1:9999/misc/ubuntu-15.04-server-cloudimg-amd64-root.tar.gz --container-format=bare --disk-format=raw --name lxd --property  hypervisor_type=lxd  --is-public true
glance image-create --location http://192.168.255.1:9999/misc/ubuntu-15.04-server-cloudimg-amd64-root.tar.gz --container-format=bare --disk-format=raw --name lxc --property  hypervisor_type=lxc  --is-public true
EOF

    cat << EOF > /root/quota-update.sh
#!/bin/sh
nova quota-update --instances 100 --cores 200 --ram 512000 \$ADMIN_TENANT_ID
neutron quota-update --port 200 --tenant-id \$ADMIN_TENANT_ID
EOF
    cat << EOF > /root/boot-lxc.sh
#!/bin/sh
nova boot --flavor 1 --image cirros-lxc --nic net-id=$GRE_ID gre
EOF

