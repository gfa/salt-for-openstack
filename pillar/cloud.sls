openstack_release: 'kilo'
qemu_version: latest
pillar_env: 'cloud'
openstack_cert_ca: '/usr/local/share/ca-certificates/zumbi.lap'
keystone_admin_endpoint: 'http://controller.zumbi.lap:35357/v2.0'
auth_uri: 'http://controller.zumbi.lap:5000/v2.0'
auth_url: 'http://controller.zumbi.lap:5000'
auth_protocol: 'http'
auth_host: 'controller.zumbi.lap'
auth_port: '35357'
service_tenant_name: 'service'
service_tenant_id: '8070d5b1169246c08d1e18ecc7ceft83'
auth_region: 'cloud'
rabbit_hosts: 'controller:5672'
rabbit_host: 'controller'
rabbit_port: '5672'
rabbit_userid: 'rabbituser'
rabbit_virtual_host: '/vhost'
rabbit_durable: 'True'
mysql_socket: '/var/run/mysqld/mysqld.sock'
mysql_root_user: 'root'
mysql_root_pass: 'root'
rabbit_password: 'rabbitpassword'
neutron_metadata_proxy_shared_secret: 'tIUPeBX55nVG97j4VyKlRqQg2KrUsYJpa45fB71'
neutron_url: 'http://controller.zumbi.lap:9696'
nova_url: 'http://controller.zumbi.lap:8774/v2'
prov-iface: 'eth2'
inet-iface: 'eth1'
ca-certs:
  openstack: |
    -----BEGIN CERTIFICATE-----
    MIIEszCCA5ugAwIBAgIJAIGq6ECgcux+MA0GCSqGSIb3DQEBCwUAMIGXMQswCQYD
    VQQGEwJBUjELMAkGA1UECBMCQkExEDAOBgNVBAcTB05PV0hFUkUxDjAMBgNVBAoT
    BXp1bWJpMRIwEAYDVQQLEwl6dW1iaS5sYXAxETAPBgNVBAMTCHp1bWJpIENBMRAw
    DgYDVQQpEwdFYXN5UlNBMSAwHgYJKoZIhvcNAQkBFhFyb290QHp1bWJpLmNvbS5h
    cjAeFw0xNTAxMTAxMDQ0MzZaFw0yNTAxMDcxMDQ0MzZaMIGXMQswCQYDVQQGEwJB
    UjELMAkGA1UECBMCQkExEDAOBgNVBAcTB05PV0hFUkUxDjAMBgNVBAoTBXp1bWJp
    MRIwEAYDVQQLEwl6dW1iaS5sYXAxETAPBgNVBAMTCHp1bWJpIENBMRAwDgYDVQQp
    EwdFYXN5UlNBMSAwHgYJKoZIhvcNAQkBFhFyb290QHp1bWJpLmNvbS5hcjCCASIw
    DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMaVWkFpEORAGVmeTnnbl+19kFRt
    CMk7udIbi+zlZBzmLiF1aGi6PyrJSBJCoVUPsjZzpSSJxakwsA0HLpDyiy+ME+TF
    iVgpUoDXyHrp7ctFe8Dhp072lRBfdYnhp+heUpGqRKEmxijAXGr4YJukuKitl0wK
    +MKtfquI7aHfs56pEajSRK7/G+Z3z9e5I4Z5bSo4oIZdSpnNFHrKX6+QUmKwUgOc
    7QwJ/42Op1bHz+YJqW7xfKbON3Z43ajD3GnIOCFg4suLnkM/eFjAuch9u84FbenH
    9gka/A1de1HqpvlthLTEg/UBWUs5IFiYFIYfPG0jSA50INxDLZt59QSl3msCAwEA
    AaOB/zCB/DAdBgNVHQ4EFgQUHtNbgYnpGTxV4d84PIOEOfbb6+IwgcwGA1UdIwSB
    xDCBwYAUHtNbgYnpGTxV4d84PIOEOfbb6+KhgZ2kgZowgZcxCzAJBgNVBAYTAkFS
    MQswCQYDVQQIEwJCQTEQMA4GA1UEBxMHTk9XSEVSRTEOMAwGA1UEChMFenVtYmkx
    EjAQBgNVBAsTCXp1bWJpLmxhcDERMA8GA1UEAxMIenVtYmkgQ0ExEDAOBgNVBCkT
    B0Vhc3lSU0ExIDAeBgkqhkiG9w0BCQEWEXJvb3RAenVtYmkuY29tLmFyggkAgaro
    QKBy7H4wDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAmenVxJ5E9aJ/
    CkGqKrq2xZHHr0k4aRCJEHc6LPw82pkDxLsvGAiZLHBZHhwyFsCLM6roeQh4aYHy
    0RlbujiMszhQCPxVdqFGyOzJy2xvoKTcrHj/aZ44FmVfCiLjzUfwQaXOtXL/kILt
    NTDchU37Rp2ppnvmSPLusYvyCm2uBn3dKy4888y9GZ723wnK6y6xbzTw+mvtS0qB
    /XOU9At/BqXcEf1b6/0NUHUVlHVlD3FYA6LODGOSBWjWWJEHlwiWzsOBk7RqFJXF
    LztuCoCcuwzGxV1btUU2/edYuaZKClBrAatPx6PAvEhkwne7mMM550hr0YOcWtUW
    BaEoDngeMg==
    -----END CERTIFICATE-----
  pijar: |
    123
    123
    123
    123
    123
    123
    123

# mysql
sql_master: 'controller'
sql_slave: 'controller'
sql_master_port: '3306'
sql_slave_port: '3306'

novncproxy_base_url: 'http://127.0.0.1:6080/vnc_auto.html'
vncserver_proxyclient_address: '10.21.176.7'
glance_host: 'http://controller.zumbi.lap'
glance_api_servers: 'http://controller.zumbi.lap:9292'
nova_neutron_admin_username: 'neutron-nova'
nova_neutron_admin_password: 'neutron-nova'
nova_notify_user: 'nova-notify'
nova_notify_password: 'nova-notify'
neutron_region_name: 'cloud'
nova_sql_user: 'nova'
nova_sql_pass: 'nova'
nova_sql_db: 'nova'
reserved_host_memory_mb: '128'
nova_admin_user: 'nova'
nova_admin_password: 'nova'
nova_rabbit_user: 'nova'
nova_rabbit_password: 'nova'
nova_rabbit_virtual_host: 'nova'
nova_vif_plugging_is_fatal: 'True'
nova_vif_plugging_timeout: '10'
neutron_default_quota: '-1'


glance_sql_user: 'glance'
glance_sql_db: 'glance'
glance_sql_password: 'glance'
glance_admin_user: 'glance'
glance_admin_password: 'glance'
registry_client_protocol: 'http'
glance_rabbit_user: 'glance'
glance_rabbit_password: 'glance'
glance_rabbit_virtual_host: 'glance'


keystone_admin_token: 'u7xmoffcwve9ugjkcygrnairuu6rt0ut'
keystone_sql_user: 'keystone'
keystone_sql_password: 'keystone'
keystone_sql_db: 'keystone'
keystone_ssl_crt: 'controller.zumbi.lap.crt'
keystone_ssl_key: 'controller.zumbi.lap.key'
keystone_ssl_chain: 'controller.zumbi.lap.crt'
keystone_admin_user: 'keystone'
keystone_admin_password: 'keystone'
keystone_rabbit_user: 'keystone'
keystone_rabbit_password: 'keystone'
keystone_rabbit_virtual_host: 'keystone'



neutron_rabbit_user: 'neutron'
neutron_rabbit_password: 'neutron'
neutron_rabbit_virtual_host: '/neutronvhost'
dhcp_lease_duration: '1577846300'
neutron_core_plugin: 'neutron.plugins.ml2.plugin.Ml2Plugin'
#neutron_service_plugins: 'neutron.services.loadbalancer.plugin.LoadBalancerPlugin,neutron.services.metering.metering_plugin.MeteringPlugin,neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'
neutron_service_plugins: 'neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'
dhcp_agents_per_network: '1'
neutron_user: 'neutron'
neutron_admin_user: 'neutron-admin'
neutron_admin_password: 'neutron'
neutron_password: 'neutron'
neutron_sql_user: 'neutron'
neutron_sql_pass: 'neutron'
neutron_sql_db: 'neutron'
neutron_service_provider: 'LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default'
dhcp_domain: 'zumbi.lap'
dnsmasq_dns_server: '192.168.255.1'
nova_metadata_ip: '192.168.255.56'
neutron_firewall_driver: 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver'
tenant_network_type: 'gre,vlan'
network_vlan_ranges: 'inet:10:190,prov:10:190'
enable_tunneling: 'True'
tunnel_type: 'gre'
tunnel_id_ranges: '1:1000'
bridge_mappings: 'inet:br-inet,prov:br-prov'
neutron_agent_polling_interval: '20'
veth_mtu: '1500'
enable_l2_population: 'False'
neutron_type_driver: 'flat,gre,vlan'
mechanism_drivers: 'openvswitch'
neutron_nova_notify: 'True'
neutron_nova_admin: 'neutron-admin'
neutron_nova_password: 'neutron-admin'
router_distributed: 'False'
l3_ha: 'False'
l3_ha_net_cidr: '169.254.192.0/18'
neutron_api_servers: '2'
neutron_rpc_workers: '2'
